#!/usr/bin/env bash
set -ex

cd "$(dirname "$0")"
wget -O install.sh https://zed.dev/install.sh
/bin/su -c "HOME=/home/kasm-default-profile $(dirname "$0")/install.sh" kasm-user
