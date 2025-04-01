#!/bin/bash
set -ex

runuser -l kasm-user -c "HOME=/tmp bash -c 'curl -fsSL https://cdn.anythingllm.com/latest/installer.sh | sh'"
mv /tmp/AnythingLLMDesktop /opt/AnythingLLMDesktop
chown -R 1000:1000 "/opt/AnythingLLMDesktop"

cat >/usr/share/applications/anythingllm.desktop<<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=AnythingLLM
Icon=/opt/AnythingLLMDesktop/anythingllm-desktop/anythingllm-desktop.png
Path="/opt/AnythingLLMDesktop/anythingllm-desktop"
Exec=env APPDIR=/opt/AnythingLLMDesktop/anythingllm-desktop "/opt/AnythingLLMDesktop/start" --no-sandbox %f
Comment=AnythingLLM LLM
Categories=
Terminal=false
StartupNotify=true
EOL
chmod +x /usr/share/applications/anythingllm.desktop
chown 1000:1000 /usr/share/applications/anythingllm.desktop
ln -s /usr/share/applications/anythingllm.desktop "$HOME/Desktop/anythingllm.desktop"