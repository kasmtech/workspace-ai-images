#!/bin/bash
set -ex

mkdir /opt/easy-diffusion
cp -R "$(dirname "$0")/scripts" /opt/easy-diffusion
cp -R "$(dirname "$0")/start.sh" /opt/easy-diffusion
# For some reason the easy diffusion installer will download models relative to the cwd..
cd /opt/easy-diffusion/scripts
export INSTALL_ONLY=1
/opt/easy-diffusion/start.sh

chown -R 1000:0 /opt/easy-diffusion

cat >/usr/share/applications/easydiffusion.desktop<<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Easy Diffusion
Icon=/opt/easy-diffusion/ui/media/images/icon-512x512.png
Path="/opt/easy-diffusion/"
Exec="/opt/easy-diffusion/start.sh"
Comment=
Categories=
Terminal=true
StartupNotify=true
EOL
chmod +x /usr/share/applications/easydiffusion.desktop
chown kasm-user:kasm-user /usr/share/applications/easydiffusion.desktop
ln -s /usr/share/applications/easydiffusion.desktop "$HOME/Desktop/easydiffusion.desktop"


# Cleanup for app layer
chown -R 1000:0 $HOME
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi

