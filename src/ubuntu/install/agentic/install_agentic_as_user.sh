#!/bin/bash
set -ex

source "$HOME/.bashrc"

cd ~
mkdir agentic

curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

git clone https://github.com/TheAgenticAI/TheAgenticBrowser

uv venv --python=3.11
source .venv/bin/activate

cd TheAgenticBrowser

uv pip install -r requirements.txt

playwright install

uv cache clean