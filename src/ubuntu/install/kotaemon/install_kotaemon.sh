#!/bin/bash
set -ex
chown kasm-user:kasm-user "$(dirname "$0")/install_kotaemon_as_user.sh"
chmod +x "$(dirname "$0")/install_kotaemon_as_user.sh"
/bin/su -c "HOME=/home/kasm-default-profile $(dirname "$0")/install_kotaemon_as_user.sh" kasm-user

echo "grep -q 'export USE_LIGHTRAG' ~/.bashrc || export USE_LIGHTRAG=true >> ~/.bashrc" >> $STARTUPDIR/custom_startup.sh


cat "$(dirname "$0")/kotaemon_startup.sh" >> $STARTUPDIR/custom_startup.sh

cat >"$HOME/kotaemon/launch_kotaemon.sh"<<EOL
#!/bin/bash
cd "$HOME/kotaemon"
python app.py "$@"
EOL
chmod +x "$HOME/kotaemon/launch_kotaemon.sh"
chown kasm-user:kasm-user "$HOME/kotaemon/launch_kotaemon.sh"

kotaemon_icon=/home/kasm-default-profile/kotaemon/libs/ktem/ktem/assets/img/favicon.svg
cat >/usr/share/applications/kotaemon.desktop<<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Kotaemon
Icon=${kotaemon_icon}
Path="/home/kasm-user/kotaemon"
Exec="/home/kasm-user/kotaemon/launch_kotaemon.sh" %f
Comment=Kotaemon LLM
Categories=Development;IDE;
Terminal=true
StartupNotify=true
EOL
chmod +x /usr/share/applications/kotaemon.desktop
chown kasm-user:kasm-user /usr/share/applications/kotaemon.desktop

