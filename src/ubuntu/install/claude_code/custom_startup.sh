#!/usr/bin/env bash
set -ex
START_COMMAND="xfce4-terminal --maximize --title Claude -e claude"
PGREP="claude"
export MAXIMIZE="false"
export MAXIMIZE_NAME="Claude"
MAXIMIZE_SCRIPT=$STARTUPDIR/maximize_window.sh
DEFAULT_ARGS=""
ARGS=${APP_ARGS:-$DEFAULT_ARGS}

# Process non-option arguments.
for arg; do
    echo "arg! $arg"
done

FORCE=$2

# run with vgl if GPU is available
if [ -f /opt/VirtualGL/bin/vglrun ] && [ ! -z "${KASM_EGL_CARD}" ] && [ ! -z "${KASM_RENDERD}" ] && [ -O "${KASM_RENDERD}" ] && [ -O "${KASM_EGL_CARD}" ] ; then
    START_COMMAND="/opt/VirtualGL/bin/vglrun -d ${KASM_EGL_CARD} $START_COMMAND"
fi

# Claude Code requires a browser login flow even when an API key is provided via env variable. The API key is only parsed after the login flow is completed once. As a workaround, we create a helper script that provides the API key directly to Claude Code, bypassing the login flow. The API key can either be passed via the ANTHROPIC_API_KEY env variable or via launch form data stored in /tmp/launch_selections.json (https://github.com/anthropics/claude-code/issues/1084#issuecomment-3059222035)
claude_api_helper(){
    # check if ANTHROPIC_API_KEY is set, if not try to parse from launch_selections.json
    if [ -z "$ANTHROPIC_API_KEY" ] ; then
        ANTHROPIC_API_KEY=$(jq -r '.anthropic_api_key // empty' /tmp/launch_selections.json)
        if [ -z "$ANTHROPIC_API_KEY" ] ; then
            echo "ANTHROPIC_API_KEY is not set and not found in launch_selections.json. Skipping API Key helper configuration"
            return 1
        fi
        export ANTHROPIC_API_KEY
        echo "Loaded ANTHROPIC_API_KEY from launch_selections.json"
    fi

    # Create API Key helper to parse api keys from either env variables or launch form without prompting a browser login flow
    cat <<EOF > $HOME/.claude/claude_api_key_helper.sh
#!/usr/bin/env bash
echo $ANTHROPIC_API_KEY
EOF

    chmod +x $HOME/.claude/claude_api_key_helper.sh
    # unset ANTHROPIC_API_KEY env variable to avoid "auth conflict" warning on claude code
    unset ANTHROPIC_API_KEY

    # Override settings.json to parse API key from env variable
    cat > $HOME/.claude/settings.json << 'EOF'
{
  "apiKeyHelper": "$HOME/.claude/claude_api_key_helper.sh",
  "hasCompletedOnboarding": true,
  "customApiKeyResponses": {
    "approved": [],
    "rejected": []
  }
}
EOF

    echo "Configured claude to use API Key helper"
    return 0
}

kasm_startup() {
    if [ -n "$KASM_URL" ] ; then
        URL=$KASM_URL
    elif [ -z "$URL" ] ; then
        URL=$LAUNCH_URL
    fi

    if [ -z "$DISABLE_CUSTOM_STARTUP" ] ||  [ -n "$FORCE" ] ; then
        claude_api_helper || true
        echo "Entering process startup loop"
        set +x
        while true
        do
            if ! pgrep -f $PGREP > /dev/null
            then
                /usr/bin/filter_ready
                /usr/bin/desktop_ready
                set +e
                bash ${MAXIMIZE_SCRIPT} &
                $START_COMMAND $ARGS $URL
                set -e
            fi
            sleep 1
        done
        set -x

    fi
}


kasm_startup