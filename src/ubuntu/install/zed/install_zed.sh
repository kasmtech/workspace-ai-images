#!/usr/bin/env bash
set -ex

cd "/home/kasm-default-profile"
wget -O install.sh https://zed.dev/install.sh
chown 1000:0 "/home/kasm-default-profile/install.sh"
/bin/su -c "HOME=/home/kasm-default-profile /home/kasm-default-profile/install.sh" kasm-user
rm "/home/kasm-default-profile/install.sh"