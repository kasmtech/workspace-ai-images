#!/bin/bash
set -ex

echo "deb [arch=amd64] https://updates.talon-sec.com/linux/prisma-access-browser/deb/ stable main" | tee /etc/apt/sources.list.d/prisma-access-browser.list
wget -q -O - https://updates.talon-sec.com/linux/prisma-access-browser/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/pab.asc >/dev/null

apt update
apt install -y prisma-access-browser-stable