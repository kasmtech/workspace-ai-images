#!/bin/bash
set -ex
chown kasm-user:kasm-user "$(dirname "$0")/install_agentic_as_user.sh"
chmod +x "$(dirname "$0")/install_agentic_as_user.sh"
/bin/su -c "HOME=/home/kasm-default-profile $(dirname "$0")/install_agentic_as_user.sh" kasm-user
