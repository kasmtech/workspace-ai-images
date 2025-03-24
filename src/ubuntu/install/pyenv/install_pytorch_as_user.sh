#!/bin/bash
set -ex

source "$HOME/.bashrc"

cd ~
mkdir torch
cd torch

env PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto' PYTHON_CFLAGS='-march=native -mtune=native' pyenv install 3.10
pyenv virtualenv 3.10 torch
pyenv local torch

python -m pip install --upgrade pip
pip install jupyterlab wandb pandas 'polars[all]' tensorboard numpy
# TODO Read Cuda version and adjust automatically
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

python -m pip cache purge