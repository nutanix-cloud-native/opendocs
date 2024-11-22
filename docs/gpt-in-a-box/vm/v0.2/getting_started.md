# Getting Started
This is a guide on getting started with GPT-in-a-Box 1.0 deployment on a Virtual Machine. You can find the open source repository for the virtual machine version [here](https://github.com/nutanix/nai-llm).

Tested Specifications: 

| Specification | Tested Version |
| --- | --- |
| Python | 3.10 |
| Operating System | Ubuntu 20.04 |
| GPU | NVIDIA A100 40G |
| CPU | 8 vCPUs |
| System Memory | 32 GB |

Follow the steps below to install the necessary prerequisites.

### Install openjdk, pip3
Run the following command to install pip3 and openjdk
```
sudo apt-get install openjdk-17-jdk python3-pip
```

### Install NVIDIA Drivers
To install the NVIDIA Drivers, refer to the official [Installation Reference](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#runfile).

Proceed to downloading the latest [Datacenter NVIDIA drivers](https://www.nvidia.com/download/index.aspx) for your GPU type.

For NVIDIA A100, Select A100 in Datacenter Tesla for Linux 64 bit with CUDA toolkit 11.7, latest driver is 515.105.01.

```
curl -fSsl -O https://us.download.nvidia.com/tesla/515.105.01/NVIDIA-Linux-x86_64-515.105.01.run
sudo sh NVIDIA-Linux-x86_64-515.105.01.run -s
```
!!! note
    We don’t need to install CUDA toolkit separately as it is bundled with PyTorch installation. Just NVIDIA driver installation is enough.

### Download Nutanix package
Download the **v0.2** release version from the [NAI-LLM Releases](https://github.com/nutanix/nai-llm/releases/tag/v0.2) and untar the release on the node. Set the working directory to the root folder containing the extracted release.

```
export WORK_DIR=absolute_path_to_empty_release_directory
mkdir $WORK_DIR
tar -xvf <release tar file> -C $WORK_DIR --strip-components=1
```

### Install required packages
Run the following command to install the required python packages.
```
pip install -r $WORK_DIR/llm/requirements.txt
```