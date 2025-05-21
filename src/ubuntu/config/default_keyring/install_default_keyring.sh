#!/bin/bash

mkdir -p "$HOME/.local/share"
cp -R "$(dirname "$0")/keyrings" "$HOME/.local/share"
chown -R 1000:0 "$HOME/"
chmod 0700 "$HOME/.local/share/keyrings/Default_keyring.keyring"
chmod 0744 "$HOME/.local/share/keyrings/default"
