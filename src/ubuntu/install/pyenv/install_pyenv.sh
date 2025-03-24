#!/usr/bin/env bash
set -ex


apt-get update
# Install Python build tools
apt-get --no-install-recommends -y install build-essential gdb lcov pkg-config \
                   libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
                   libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
                   lzma lzma-dev tk-dev uuid-dev zlib1g-dev \
                   curl git jq

# Install pyenv
# Install outside home directory so we don't end up with huge persistent profiles
export PYENV_ROOT=${PYENV_ROOT:-/opt/pyenv}

curl -fsSL https://pyenv.run | bash

chown -R 1000:0 "$PYENV_ROOT"

# Setup shell integration into kasm-default-profile
cat "$(dirname "$0")/pyenv_startup.sh" >> $STARTUPDIR/custom_startup.sh
cp "$(dirname "$0")/restore_python.sh" /dockerstartup/restore_python.sh
cp "$(dirname "$0")/package_python.sh" /dockerstartup/package_python.sh

# Exec here in case we need pyenv later in build
bash "$(dirname "$0")/pyenv_startup.sh"

# Cleanup for app layer
chown -R 1000:0 $HOME
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi

