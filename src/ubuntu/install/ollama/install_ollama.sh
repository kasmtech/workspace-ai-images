#!/bin/bash
set -exo pipefail

# Install Ollama to /opt so it stays out of the user profile.
# Kasm copies $HOME (kasm-default-profile) into persistent user profiles on launch,
# so the ~1.3GB Ollama bundle must not live there.
# The tarball's bin/ + lib/ollama/ layout is preserved so that the binary's
# RPATH ($ORIGIN/../lib/ollama) resolves correctly from /opt/ollama/bin/.
apt-get update
apt-get install -y zstd

mkdir -p /opt/ollama
curl -fsSL "https://github.com/ollama/ollama/releases/latest/download/ollama-linux-amd64.tar.zst" \
  | tar -x --zstd -C /opt/ollama
