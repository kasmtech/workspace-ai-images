#!/usr/bin/env bash
set -ex

# Install vsCode
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/x64/g')
wget -q https://update.code.visualstudio.com/latest/linux-deb-${ARCH}/stable -O vs_code.deb
apt-get update
apt-get install -y ./vs_code.deb

# Desktop icon
mkdir -p /usr/share/icons/hicolor/apps
wget -O /usr/share/icons/hicolor/apps/vscode.svg https://kasm-static-content.s3.amazonaws.com/icons/vscode.svg
sed -i '/Icon=/c\Icon=/usr/share/icons/hicolor/apps/vscode.svg' /usr/share/applications/code.desktop
sed -i 's#/usr/share/code/code#/usr/share/code/code --no-sandbox##' /usr/share/applications/code.desktop
cp /usr/share/applications/code.desktop $HOME/Desktop
chmod +x $HOME/Desktop/code.desktop
chown 1000:1000 $HOME/Desktop/code.desktop
rm vs_code.deb


# Check if VSCODE_EXTENSIONS is set
if [ -z "$VSCODE_EXTENSIONS" ]; then
  echo "No VSCODE_EXTENSIONS environment variable found."
else
  echo "Installing VS Code extensions..."
  # Split by comma, trim whitespace, and install each extension
  IFS=',' read -ra EXTENSIONS <<< "$VSCODE_EXTENSIONS"
  for ext in "${EXTENSIONS[@]}"; do
    # Trim leading and trailing whitespace
    EXTENSION=$(echo "$ext" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [ -n "$EXTENSION" ]; then
      echo "Installing: $EXTENSION"
      runuser -l kasm-user -c "HOME=$HOME -c 'code --install-extension \"$EXTENSION\"'"
    fi
  done
fi

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
