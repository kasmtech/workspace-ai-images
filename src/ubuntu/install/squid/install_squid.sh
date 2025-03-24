#!/bin/bash
set -ex

# Install openssl
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')
apt-get update
apt-get install -y openssl wget libexpat1 dnsutils curl iproute2

SQUID_COMMIT='c45537169794a16029e06d7d456edb21b9ce7d12'
wget -qO- https://kasmweb-build-artifacts.s3.amazonaws.com/kasm-squid-builder/${SQUID_COMMIT}/output/kasm-squid-builder_ubuntu_${ARCH}.tar.gz | tar -xzf - -C /



