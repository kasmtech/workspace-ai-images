#!/usr/bin/env bash
set -xe

# Install Codex CLI with npm
npm i -g @openai/codex

# Copy icon to system location
cp ${INST_DIR}/ubuntu/install/codex/codex.png /usr/share/pixmaps/codex.png

# Create Desktop Shortcut
CODEX_CLI_PATH="/usr/bin/codex"
cat <<EOF > $HOME/Desktop/codex.desktop
[Desktop Entry]
Name=Codex CLI
Comment=Codex Command Line Interface
Exec=${CODEX_CLI_PATH}
Icon=/usr/share/pixmaps/codex.png
Terminal=true
Type=Application
Categories=Utility;Development;
EOF
chmod +x $HOME/Desktop/codex.desktop
chown 1000:1000 $HOME/Desktop/codex.desktop

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
