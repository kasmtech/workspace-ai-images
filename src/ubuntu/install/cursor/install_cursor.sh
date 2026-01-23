#!/usr/bin/env bash
set -xe

ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

if grep -q "ID=ubuntu" /etc/os-release; then
    if [ "$ARCH" = "amd64" ]; then
        # Not mentioning the version in the url defaults to latest
        CURSOR_DOWNLOAD_URL="https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/"
    else
        CURSOR_DOWNLOAD_URL="https://api2.cursor.sh/updates/download/golden/linux-arm64-deb/cursor/"
    fi
    # Download and install Cursor
    curl -Lo /tmp/cursor.deb ${CURSOR_DOWNLOAD_URL}
    apt-get install -y /tmp/cursor.deb
    rm /tmp/cursor.deb

    # Run with sandboxing disabled to avoid issues - add --no-sandbox after cursor binary in all Exec lines
    sed -i 's|Exec=/usr/share/cursor/cursor |Exec=/usr/share/cursor/cursor --no-sandbox |g' /usr/share/applications/cursor.desktop

    # Copy to Desktop and fix icon path 
    cp /usr/share/applications/cursor.desktop $HOME/Desktop/
    sed -i 's|Icon=co.anysphere.cursor|Icon=/usr/share/pixmaps/co.anysphere.cursor.png|g' $HOME/Desktop/cursor.desktop
    chmod +x $HOME/Desktop/cursor.desktop

    # Install Cursor Agent
    curl -fsSL https://cursor.com/install -fsS | bash
    # Copy the symlink to /usr/local/bin
    cp -P $HOME/.local/bin/cursor-agent /usr/local/bin/cursor-agent

fi


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
