![Logo][logo]
# Images for AI Workloads - GPU Setup

This page describes the steps required to support GPU-accelerated workloads on Kasm.

## Pre-requisites

1. NVIDIA CUDA-capable graphics card
2. [NVIDIA drivers](https://www.nvidia.com/en-gb/drivers/) (for AI workspaces the minimum required version is currently `560.28.03`). Note: NVIDIA recommends installing the driver by using the package manager for your distribution and Kasm also recommend the same.
3. [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

**Warning:** Installing NVIDIA drivers via multiple installation methods can result in your system not booting correctly.

## Ubuntu 24.04 LTS

For Ubuntu 24.04 systems we provide the following script that will add the Ubuntu PPA repository, install the latest NVIDIA driver through the `ubuntu-drivers` tool and install the NVIDIA Container Toolkit.


```shell
#!/bin/bash

# Check for NVIDIA cards
if ! lspci | grep -i nvidia > /dev/null; then
    echo "No NVIDIA GPU detected"
    exit 0
fi

add-apt-repository -y ppa:graphics-drivers/ppa

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt update
apt install -y ubuntu-drivers-common

# Run ubuntu-drivers and capture the output
DRIVER_OUTPUT=$(ubuntu-drivers list 2>/dev/null)
# Extract server driver versions using grep and regex
# Pattern looks for nvidia-driver-XXX-server
SERVER_VERSIONS=$(echo "$DRIVER_OUTPUT" | grep -o 'nvidia-driver-[0-9]\+-server' | grep -o '[0-9]\+' | sort -n)
# Check if any server versions were found
if [ -z "$SERVER_VERSIONS" ]; then
    echo "Error: No NVIDIA server driver versions found." >&2
    exit 1
fi
# Find the highest version number
LATEST_VERSION=$(echo "$SERVER_VERSIONS" | tail -n 1)
# Validate that the version is numeric
if ! [[ "$LATEST_VERSION" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid version number: $LATEST_VERSION" >&2
    exit 2
fi
# Output only the version number
echo "Latest version is: $LATEST_VERSION"
ubuntu-drivers install "nvidia:$LATEST_VERSION-server"
apt install -y "nvidia-utils-$LATEST_VERSION-server"
# Install NVIDIA toolkit + configure for docker
apt-get install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker


```

Once the steps are completed the system should be rebooted.

# Accelerating workspaces

Please ensure to set the correct enivronment variables in your Workspace configuration by modifying your Docker Run configuration to include:
```json
{
  "environment": {
    "NVIDIA_DRIVER_CAPABILITIES": "all"
  }
}
```

For more details on the available environment settings please see https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html.

Images in the AI workspaces do not require this step as they are pre-baked into the image.
