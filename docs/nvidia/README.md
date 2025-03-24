# About This Image

This Image contains a Kasm workspace for NVIDIA CUDA accelerated AI development.

It includes:
* Standard Kasm Desktop Workspaces for Ubuntu 24.04 (Noble)
* [NVIDIA CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)
* [pyenv](https://github.com/pyenv/pyenv/tree/master) for Python version management

# Image build environment variables

* `CUDA_TOOLKIT_VERSION` - Version of NVIDIA CUDA Toolkit to install. Defaults to `12.6`
* `PYENV_GIT_TAG` - Version of pyenv to install. Defaults to `v2.5.1`

# Building optimised python builds offline

With this image it is possible to build an optimised Python version with pre-configured packages. These builds can be stored on the Kasm Agent Server (Docker host) to save time when Workspace users need to load a particular version. To do this run the following on the Agent Host

To build a Python version and package you can use the following command:

```shell
mkdir -p /var/spool/python_versions
chown kasm:kasm /var/spool/python_versions
PYTHON_VERSION="3.13"
EXTRA_PACKAGES="jupyterlab wandb pandas tensorboard numpy tensorflow[and-cuda]"
IMAGE="kasmweb/ubuntu-noble-nvidia-private:KASM-6818-cuda"
docker run --rm -it \
       --user=root \
       --entrypoint /bin/bash \
       --network=kasm_default_network\
       -v /var/spool/python_versions:/var/spool/python_versions:rw \
       "$IMAGE" \
       -c "echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/tmp_sudo && runuser -u kasm-user -- /dockerstartup/package_python.sh prepare $PYTHON_VERSION"
```