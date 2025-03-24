#!/bin/bash
set -ex

# Install openssl
apt-get update
apt-get install -y p11-kit p11-kit-modules libnss3


find /usr -type f -name "libnssckbi.so" 2>/dev/null | while read -r line; do
    rm "$line"
    ln -s "/usr/lib/$(arch)-linux-gnu/pkcs11/p11-kit-trust.so" "$line"
done



if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi

