#!/bin/bash
set -ex

source "$HOME/.bashrc"

cd ~
mkdir tensorflow
cd tensorflow

env PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto' PYTHON_CFLAGS='-march=native -mtune=native' pyenv install 3.10
pyenv virtualenv 3.10 tensorflow
pyenv local tensorflow

python -m pip install --upgrade pip
pip install jupyterlab wandb pandas tensorboard numpy
pip install 'tensorflow[and-cuda]'

python -m pip cache purge