
if [ ! -d "$HOME/kotaemon" ]; then
    cp -r /home/kasm-default-profile/kotaemon "$HOME/kotaemon"
fi

if [ ! -d "$HOME/Desktop/kotaemon.desktop" ]; then
  cp /usr/share/applications/kotaemon.desktop "$HOME/Desktop/"
fi
