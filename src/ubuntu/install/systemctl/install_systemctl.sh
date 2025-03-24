#!/bin/bash
set -ex

# See https://github.com/gdraheim/docker-systemctl-replacement/ for more info & license (EUPL v1.2)
cp "$(dirname "$0")/systemctl3.py" /usr/bin/systemctl
chmod +x /usr/bin/systemctl
mkdir -p /etc/sudoers.d
echo "ALL ALL=NOPASSWD: /usr/bin/systemctl" > /etc/sudoers.d/systemctl
