#!/usr/bin/env bash
set -ex

# Install vsCode
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/x64/g')
wget -q https://update.code.visualstudio.com/latest/linux-deb-${ARCH}/stable -O vs_code.deb
apt-get update
apt-get install -y ./vs_code.deb

# Desktop icon and launcher
DESKTOP_NAME=com.microsoft.VSCode.desktop
DESKTOP_FILE=/usr/share/applications/${DESKTOP_NAME}

mkdir -p /usr/share/icons/hicolor/apps
wget -O /usr/share/icons/hicolor/apps/vscode.svg https://kasm-static-content.s3.amazonaws.com/icons/vscode.svg

if [ -f "$DESKTOP_FILE" ]; then
  sed -i '/Icon=/c\Icon=/usr/share/icons/hicolor/apps/vscode.svg' "$DESKTOP_FILE"
  sed -i 's#/usr/share/code/code#/usr/share/code/code --no-sandbox#' "$DESKTOP_FILE"
  mkdir -p "$HOME/Desktop"
  cp "$DESKTOP_FILE" "$HOME/Desktop/${DESKTOP_NAME}"
  chmod +x "$HOME/Desktop/${DESKTOP_NAME}"
  chown 1000:1000 "$HOME/Desktop/${DESKTOP_NAME}"
else
  echo "WARNING: $DESKTOP_FILE not found; skipping desktop launcher setup"
fi

rm vs_code.deb

if [[ -n "${VSCODE_EXTENSIONS:-}" ]]; then
  "$(dirname "$0")/install_extensions.sh" "$VSCODE_EXTENSIONS"
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