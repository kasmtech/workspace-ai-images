#!/usr/bin/env bash
set -ex

# Install CUDA Toolkit
ubuntu_version="$(cat /etc/lsb-release | grep RELEASE | cut -d= -f2 | tr -d '.')" && \
arch_name=$(arch) && \
case "$arch_name" in \
    x86_64) arch_path="x86_64" ;; \
    aarch64) arch_path="sbsa" ;; \
    *) echo "Unsupported architecture: $arch_name" && exit 1 ;; \
esac && \
wget "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${ubuntu_version}/${arch_path}/cuda-keyring_1.1-1_all.deb"

dpkg -i cuda-keyring_1.1-1_all.deb
rm cuda-keyring_1.1-1_all.deb
apt-get update

apt-get -y install pciutils

cuda_toolkit_version=${CUDA_TOOLKIT_VERSION:-"12-6"} && \
apt-get -y install cuda-toolkit-"${cuda_toolkit_version}" cudnn-cuda-12

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi

