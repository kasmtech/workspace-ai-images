#!/usr/bin/env bash
set -xe

# Download and Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# move claude binary to /usr/local/bin
mv $HOME/.local/bin/claude /usr/local/bin/claude

# Copy icon to system location
cp ${INST_DIR}/ubuntu/install/claude_code/claude.png /usr/share/pixmaps/claude.png

# Create Desktop Shortcut
CLAUDE_CLI_PATH="/usr/local/bin/claude"

cat <<EOF > /usr/share/applications/claude_code.desktop
[Desktop Entry]
Name=Claude Code CLI
Comment=Claude Code Command Line Interface
Exec=${CLAUDE_CLI_PATH}
Icon=/usr/share/pixmaps/claude.png
Terminal=true
Type=Application
Categories=Utility;Development;
EOF
chmod +x /usr/share/applications/claude_code.desktop
chown 1000:1000 /usr/share/applications/claude_code.desktop

cp /usr/share/applications/claude_code.desktop $HOME/Desktop/claude_code.desktop
chown 1000:1000 $HOME/Desktop/claude_code.desktop

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi