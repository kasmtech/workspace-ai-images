#!/usr/bin/env bash
set -xe

# Install Gemini CLI with npm
npm install -g @google/gemini-cli

# Copy icon to system location
cp ${INST_DIR}/ubuntu/install/gemini/gemini.png /usr/share/pixmaps/gemini.png

# Create Desktop Shortcut
GEMINI_CLI_PATH="/usr/bin/gemini"
cat <<EOF > $HOME/Desktop/gemini.desktop
[Desktop Entry]
Name=Gemini CLI
Comment=Gemini Command Line Interface
Exec=${GEMINI_CLI_PATH}
Icon=/usr/share/pixmaps/gemini.png
Terminal=true
Type=Application
Categories=Utility;Development;
EOF
chmod +x $HOME/Desktop/gemini.desktop
chown 1000:1000 $HOME/Desktop/gemini.desktop

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
