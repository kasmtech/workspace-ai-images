#!/usr/bin/env bash
set -ex

PYTHON_VERSION="$(jq -r '.python_version // empty' /tmp/launch_selections.json)"
export EXTRA_PACKAGES="$(jq -r '.pip_packages // empty' /tmp/launch_selections.json)"

source ~/.bashrc || echo "Warning: Failed to source .bashrc" >> /tmp/setup.log

if [ -n "$PYTHON_VERSION" ]; then
  xfce4-terminal -e "bash -c '/dockerstartup/restore_python.sh restore \"${PYTHON_VERSION}\" >> /tmp/setup.log; exec bash'"  -T "Restore Python"
fi
