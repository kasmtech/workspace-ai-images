#!/bin/bash
set -ex

apt-get update
apt-get -y  install pciutils lshw

sh "$(dirname "$0")/install.sh"
echo "sudo systemctl start ollama" >> $STARTUPDIR/custom_startup.sh


if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi