# About This Image

This Image contains a Kasm workspace for NVIDIA CUDA accelerated AI development.

It includes:
* Standard Kasm Core Workspaces for Ubuntu 24.04 (Noble)
* [NVIDIA CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)
* [VSCode](https://code.visualstudio.com/)
* [Google Chrome](https://www.google.com/chrome/)
* [pyenv](https://github.com/pyenv/pyenv/tree/master) for Python version management
* [Python](https://python.org) - 3.10 (performance optimized)
* [PyTorch](https://pytorch.org/) with CUDA support
* Additional packages including:
  * [Jupyter](https://jupyter.org/)
  * [Weights & Biases](https://wandb.ai)
  * [Pandas](pandas.pydata.org)
  * [BROKEN] [Polars](https://pola.rs/) including optional dependencies
  * [Numpy](https://numpy.org)
  * [TensorBoard](https://www.tensorflow.org/tensorboard)

# Getting started

The image includes a pyenv virtual environment with the above listed dependencies. To get started open a terminal and execute `cd ~/torch` - the Python virtual environment should automatically activate.

To start Jupyter run `jupyter lab` and it should start and open a web browser.