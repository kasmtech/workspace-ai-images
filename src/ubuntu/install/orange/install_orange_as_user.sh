#!/bin/bash
set -ex

source "$HOME/.bashrc"

cd /opt/orange

env PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto' PYTHON_CFLAGS='-march=native -mtune=native' pyenv install 3.10
pyenv virtualenv 3.10 orange
pyenv local orange

python -m pip install --upgrade pip
pip install pip install PyQt5 PyQtWebEngine
pip install orange3

python -m pip cache purge