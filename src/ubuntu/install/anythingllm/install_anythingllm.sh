#!/bin/bash
set -ex

APPIMAGE_URL="https://cdn.anythingllm.com/latest/AnythingLLMDesktop.AppImage"

# Download AppImage
mkdir -p /opt/AnythingLLMDesktop
cd /opt/AnythingLLMDesktop
curl -fsSL "$APPIMAGE_URL" -o /opt/AnythingLLMDesktop/AnythingLLMDesktop.AppImage
chmod +x /opt/AnythingLLMDesktop/AnythingLLMDesktop.AppImage

# Extract AppImage
./AnythingLLMDesktop.AppImage --appimage-extract
rm /opt/AnythingLLMDesktop/AnythingLLMDesktop.AppImage
chown -R 1000:1000 "/opt/AnythingLLMDesktop"

# Create launcher script
cat >/opt/AnythingLLMDesktop/squashfs-root/launcher <<EOL
#!/usr/bin/env bash
export APPDIR=/opt/AnythingLLMDesktop/squashfs-root/
/opt/AnythingLLMDesktop/squashfs-root/AppRun --no-sandbox "\$@"
EOL
chmod +x /opt/AnythingLLMDesktop/squashfs-root/launcher

# Modify desktop file
sed -i 's@^Exec=.*@Exec=/opt/AnythingLLMDesktop/squashfs-root/launcher@g' /opt/AnythingLLMDesktop/squashfs-root/*anythingllm*.desktop
sed -i 's@^Icon=.*@Icon=/opt/AnythingLLMDesktop/squashfs-root/anythingllm-desktop.png@g' /opt/AnythingLLMDesktop/squashfs-root/*anythingllm*.desktop

# Copy desktop file to appropriate locations
cp /opt/AnythingLLMDesktop/squashfs-root/*anythingllm*.desktop $HOME/Desktop/anythingllm.desktop
cp /opt/AnythingLLMDesktop/squashfs-root/*anythingllm*.desktop /usr/share/applications/anythingllm.desktop
chmod +x $HOME/Desktop/anythingllm.desktop
chmod +x /usr/share/applications/anythingllm.desktop

# Ollama must already be installed (by src/ubuntu/install/ollama/install_ollama.sh,
# which runs earlier in the Dockerfile). Fail fast with a clear message if it isn't.
if [ ! -x /opt/ollama/bin/ollama ]; then
  echo "ERROR: Ollama binary not found at /opt/ollama/bin/ollama." >&2
  echo "       Run src/ubuntu/install/ollama/install_ollama.sh before install_anythingllm.sh." >&2
  exit 1
fi

# AnythingLLM's OllamaProcessManager looks for the binary named 'llm', not 'ollama'.
# Keep the real 'ollama' binary in place and expose 'llm' as a symlink so the manager
# finds it. 
ln -s ollama /opt/ollama/bin/llm
chmod +x /opt/ollama/bin/ollama
chown -R 1000:0 /opt/ollama

# Expose 'ollama' on PATH so it can be invoked independently from the terminal.
ln -s /opt/ollama/bin/ollama /usr/local/bin/ollama

# Symlink the expected path in the default profile into /opt.
# HOME is /home/kasm-default-profile at build time; Kasm seeds /home/kasm-user from it on launch.
# Only the symlink (a few bytes) ends up in the user profile — not the Ollama bundle itself.
OLLAMA_BIN_DIR="$HOME/.config/anythingllm-desktop/storage/engines/ollama/bin"
mkdir -p "$OLLAMA_BIN_DIR"
ln -s /opt/ollama/bin/llm "$OLLAMA_BIN_DIR/llm"


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

