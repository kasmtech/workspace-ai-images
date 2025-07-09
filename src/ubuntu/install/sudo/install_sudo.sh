#!/bin/bash
set -ex

# Has support for sudo command logging
sudo_version_path=${SUDO_VERSION_PATH:-"v1.9.17p1/sudo_1.9.17-2_"}

ubuntu_version="$(cat /etc/lsb-release | grep RELEASE | cut -d= -f2 | tr -d '.')" && \
arch_name=$(arch) && \
case "$arch_name" in \
    x86_64) arch_path="amd64" ;; \
    aarch64) arch_path="arm64" ;; \
    *) echo "Unsupported architecture: $arch_name" && exit 1 ;; \
esac

wget -O sudo.deb "https://github.com/sudo-project/sudo/releases/download/${sudo_version_path}ubu${ubuntu_version}_${arch_path}.deb"
echo "Defaults intercept_type=dso" >> /etc/sudoers && \
dpkg --force-confold -i sudo.deb
rm sudo.deb


echo 'Defaults env_keep += "http_proxy https_proxy no_proxy"' > /etc/sudoers.d/proxy_env