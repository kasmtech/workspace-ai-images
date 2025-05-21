#!/usr/bin/env bash
set -ex

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
      su -c "HOME=$HOME code --install-extension \"$EXTENSION\"" kasm-user
    fi
  done
fi

