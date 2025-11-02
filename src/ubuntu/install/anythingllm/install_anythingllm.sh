#!/bin/bash
set -ex

APPIMAGE_URL="https://cdn.anythingllm.com/latest/AnythingLLMDesktop.AppImage"

# Download AppImage
mkdir -p /opt/AnythingLLMDesktop
cd /opt/AnythingLLMDesktop
curl -fsSL "$APPIMAGE_URL" -o /opt/AnythingLLMDesktop/AnythingLLMDesktop.AppImage
chmod +x /opt/AnythingLLMDesktop/AnythingLLMDesktop.AppImage

# Extract AppImage
./AnythingLLMDesktop.AppImage --appimage-extract
rm /opt/AnythingLLMDesktop/AnythingLLMDesktop.AppImage
chown -R 1000:1000 "/opt/AnythingLLMDesktop"

# Create launcher script
cat >/opt/AnythingLLMDesktop/squashfs-root/launcher <<EOL
#!/usr/bin/env bash
export APPDIR=/opt/AnythingLLMDesktop/squashfs-root/
/opt/AnythingLLMDesktop/squashfs-root/AppRun --no-sandbox "\$@"
EOL
chmod +x /opt/AnythingLLMDesktop/squashfs-root/launcher

# Modify desktop file
sed -i 's@^Exec=.*@Exec=/opt/AnythingLLMDesktop/squashfs-root/launcher@g' /opt/AnythingLLMDesktop/squashfs-root/*anythingllm*.desktop
sed -i 's@^Icon=.*@Icon=/opt/AnythingLLMDesktop/squashfs-root/anythingllm-desktop.png@g' /opt/AnythingLLMDesktop/squashfs-root/*anythingllm*.desktop

# Copy desktop file to appropriate locations
cp /opt/AnythingLLMDesktop/squashfs-root/*anythingllm*.desktop $HOME/Desktop/anythingllm.desktop
cp /opt/AnythingLLMDesktop/squashfs-root/*anythingllm*.desktop /usr/share/applications/anythingllm.desktop
chmod +x $HOME/Desktop/anythingllm.desktop
chmod +x /usr/share/applications/anythingllm.desktop


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

