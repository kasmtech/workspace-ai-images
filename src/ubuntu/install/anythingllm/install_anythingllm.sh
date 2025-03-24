#!/bin/bash
set -ex
chown kasm-user:kasm-user "$(dirname "$0")/install_anythingllm_as_user.sh"
chmod +x "$(dirname "$0")/install_anythingllm_as_user.sh"
/bin/su -c "HOME=/home/kasm-default-profile $(dirname "$0")/install_anythingllm_as_user.sh" kasm-user

cat >/usr/share/applications/anythingllm.desktop<<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=AnythingLLM
Icon=/home/kasm-user/AnythingLLMDesktop/anythingllm-desktop/anythingllm-desktop.png
Path="/home/kasm-user/AnythingLLMDesktop/anythingllm-desktop"
Exec=env APPDIR=/home/kasm-user/AnythingLLMDesktop/anythingllm-desktop "/home/kasm-user/AnythingLLMDesktop/start" --no-sandbox %f
Comment=AnythingLLM LLM
Categories=
Terminal=false
StartupNotify=true
EOL
chmod +x /usr/share/applications/anythingllm.desktop
chown kasm-user:kasm-user /usr/share/applications/anythingllm.desktop
ln -s /usr/share/applications/anythingllm.desktop "$HOME/Desktop/anythingllm.desktop"