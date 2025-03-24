#!/bin/bash
set -ex

nvm_version=${NVM_VERSION:-"v0.40.1"}
node_version=${NODE_VERSION:-"22"}

curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

nvm install "${node_version}"
