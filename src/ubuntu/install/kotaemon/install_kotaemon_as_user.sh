#!/bin/bash
set -ex

kotaemon_version=${KOTAEMON_VERSION:-"v0.10.3"}

source "$HOME/.bashrc"

cd ~
mkdir kotaemon
wget -O kotaemon.zip "https://github.com/Cinnamon/kotaemon/archive/refs/tags/$kotaemon_version.zip"
unzip kotaemon.zip && mv kotaemon-*/* kotaemon/ && rm -rf kotaemon-*/ && rm kotaemon.zip
cd kotaemon

env PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto' PYTHON_CFLAGS='-march=native -mtune=native' pyenv install 3.10
pyenv virtualenv 3.10 kotaemon
pyenv local kotaemon

chmod +x scripts/download_pdfjs.sh
export PDFJS_PREBUILT_DIR="$(pwd)/libs/ktem/ktem/assets/prebuilt/pdfjs-dist"
bash scripts/download_pdfjs.sh "$PDFJS_PREBUILT_DIR"

python -m pip install --upgrade pip
pip install -e "libs/kotaemon" \
    && pip install -e "libs/ktem" \
    && pip install "pdfservices-sdk@git+https://github.com/niallcm/pdfservices-python-sdk.git@bump-and-unfreeze-requirements"

if [[ $(uname -m) == "x86_64" ]]; then
    pip install "graphrag<=0.3.6"
fi

# Full version of kotaemon
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install -e "libs/kotaemon[adv]"
pip install unstructured[all-docs]


export USE_LIGHTRAG=true
pip install aioboto3 nano-vectordb ollama xxhash "lightrag-hku<=0.0.8"

pip install "docling<=2.5.2"

python -m pip cache purge