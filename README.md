![Logo][logo]
# Images for AI Workloads
This repository contains Kasm workspaces for AI workloads. 

See workspace specific documentation:

[NVIDIA CUDA base image](./docs/nvidia/README.md) - CUDA-enabled base image.

[PyTorch Image](./docs/pytorch/README.md) - CUDA-enabled base image with [PyTorch](https://pytorch.org/).

[Tensorflow Image](./docs/tensorflow/README.md) - CUDA-enabled base image with [Tensorflow](http://tensorflow.org/).

# Setting up the Agent servers for running GPU accelerated workloads

Please refer to the [GPU Setup](./GPU_SETUP.md) page for details on pre-requisites.

# Manual Deployment

To build the provided images:

    sudo docker build -t kasmweb/ubuntu-noble-nvidia:dev -f dockerfile-kasm-ubuntu-nvidia .


While these image are primarily built to run inside the Workspaces platform, they can also be executed manually.  Please note that certain functionality, such as audio, uploads, downloads, and microphone pass-through are only available within the Kasm platform.

```
sudo docker run --rm  -it --shm-size=512m -p 6901:6901 -e VNC_PW=password kasmweb/ubuntu-noble-nvidia:dev
```

The container is now accessible via a browser : `https://<IP>:6901`

 - **User** : `kasm_user`
 - **Password**: `password`


# About Workspaces
Kasm Workspaces is a docker container streaming platform that enables you to deliver browser-based access to desktops, applications, and web services. Kasm uses a modern DevOps approach for programmatic delivery of services via Containerized Desktop Infrastructure (CDI) technology to create on-demand, disposable, docker containers that are accessible via web browser. The rendering of the graphical-based containers is powered by the open-source project   [**KasmVNC**](https://github.com/kasmtech/KasmVNC?utm_campaign=Github&utm_source=github)

![Screenshot][Kasm_Workflow]

Kasm Workspaces was developed to meet the most demanding secure collaboration requirements that is highly scalable, customizable, and easy to maintain.  Most importantly, Kasm provides a solution, rather than a service, so it is infinitely customizable to your unique requirements and includes a developer API so that it can be integrated with, rather than replace, your existing applications and workflows. Kasm can be deployed in the cloud (Public or Private), on-premise (Including Air-Gapped Networks), or in a hybrid configuration.

# Live Demo
A self-guided on-demand demo is available at [**kasm.com**](https://app.kasm.com/#/cast/kasmos)

# Building Images

Build scripts for creating workspace images locally are in `scripts/` and require
[`yq`](https://github.com/mikefarah/yq) v4.53.3 (downloaded and sha256-verified automatically on first run; cached at `~/.cache/kasm/yq/`).

All commands must be run from the repository root.

## List available images

```
./scripts/build-image.sh --list-images
```

## Build an image

To build an image directly (tagged `local_build` by default):

```
./scripts/build-image.sh --build kasmweb/claude-code
```

To inspect the `docker build` command before running it:

```
./scripts/build-image.sh --list-image-build-command kasmweb/claude-code
```

To list build commands for all images:

```
./scripts/build-image.sh --list-images-build-commands
```

Override the image tag with `-t`:

```
./scripts/build-image.sh --build kasmweb/claude-code -t my-tag
```


[logo]: https://5856039.fs1.hubspotusercontent-na1.net/hubfs/5856039/Kasm_Workspaces_Logo.png "Kasm Logo"
[Kasm_Workflow]: https://5856039.fs1.hubspotusercontent-na1.net/hubfs/5856039/dockerhub/launching_ubuntu_jammy.gif "Kasm Workflow"

# Reporting Issues

To report any issues for this repository, please use our central issue tracker: **[Kasm Workspaces Issue Tracker](https://github.com/kasmtech/workspaces-issues/issues)**
