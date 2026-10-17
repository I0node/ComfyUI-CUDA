#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Base environment paths
SWUI_PATH="$HOME/SwarmUI"

# Target original file locations
KIUI_OP_FILE="$SWUI_PATH/dlbackend/ComfyUI/venv/lib/python3.11/site-packages/kiui/op.py"
MESH_FILE="$SWUI_PATH/dlbackend/ComfyUI/custom_nodes/ComfyUI-3D-Pack/mesh_processer/mesh.py"
REQ_FILE="$SWUI_PATH/dlbackend/ComfyUI/requirements.txt"

# Source hotfix patch locations
KIUI_OP_FIX="$SWUI_PATH/hotfixes/kiui/op_fixed.py"
MESH_FIX="$SWUI_PATH/hotfixes/ComfyUI-3D-Pack/mesh_fixed.py"
REQ_FIX="$SWUI_PATH/hotfixes/ComfyUI/requirements_fixed.txt"

echo "=== 1. Deploying Overwrite Hotfixes ==="
# Overwrite kiui/op.py with your fixed file
if [ -f "$KIUI_OP_FIX" ]; then
    echo "Overwriting target file with hotfix: $KIUI_OP_FILE"
    # Ensure directory framework tree paths exist before copying
    mkdir -p "$(dirname "$KIUI_OP_FILE")"
    cp -f "$KIUI_OP_FIX" "$KIUI_OP_FILE"
else
    echo "Error: Source hotfix missing at $KIUI_OP_FIX"
    exit 1
fi

# Overwrite mesh.py with your fixed file
if [ -f "$MESH_FIX" ]; then
    echo "Overwriting target file with hotfix: $MESH_FILE"
    mkdir -p "$(dirname "$MESH_FILE")"
    cp -f "$MESH_FIX" "$MESH_FILE"
else
    echo "Error: Source hotfix missing at $MESH_FIX"
    exit 1
fi

# Overwrite mesh.py with your fixed file
if [ -f "$REQ_FIX" ]; then
    echo "Overwriting target file with hotfix: $REQ_FILE"
    mkdir -p "$(dirname "$REQ_FILE")"
    cp -f "$REQ_FIX" "$REQ_FILE"
else
    echo "Error: Source hotfix missing at $REQ_FIX"
    exit 1
fi

echo "=== 2. Configuring Fedora Repositories ==="
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf clean all
sudo dnf makecache


echo "=== 3. Ensuring Core NVIDIA Driver System Runtime ==="
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda


echo "=== 4. Setting up NVIDIA Official Development Repo ==="
sudo dnf config-manager addrepo --from-repofile=https://developer.download.nvidia.com/compute/cuda/repos/fedora44/$(uname -m)/cuda-fedora44.repo

# Explicitly isolate driver packages to preserve the existing RPM Fusion setup
sudo dnf config-manager setopt cuda-fedora44-$(uname -m).exclude=nvidia-driver*,cuda-drivers*,nvidia-modprobe,nvidia-persistenced,nvidia-settings,nvidia-libXNVCtrl*,nvidia-xconfig,nvidia-open,nvidia-imex,nvidia-kmod-common,libnvidia-fbc,kmod-nvidia-*-dkms,nvidia-fs*,nvidia-gds*,xorg-x11-nvidia*

sudo dnf clean all


echo "=== 5. Installing CUDA Toolkit ==="
sudo dnf -y install cuda-toolkit


echo "=== 6. Compiling nvdiffrast inside ComfyUI Venv ==="
# Exporting target binary variables globally for compilation mapping
export CUDA_HOME="/usr/local/cuda"
export PATH="${CUDA_HOME}/bin:${PATH}"
export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"

# Activating the project's designated virtual environment sandbox
SWUI_VENV="$SWUI_PATH/dlbackend/ComfyUI/venv"
if [ -d "$SWUI_VENV" ]; then
    source "$SWUI_VENV/bin/activate"

    # Ensure build dependencies (like ninja) are available for local C++ extensions compilation
    pip install --upgrade setuptools wheel pip
    pip install ninja
    # Compile and bind nvdiffrast extension securely into the local workspace environment context
    pip install --no-build-isolation git+https://github.com/NVlabs/nvdiffrast.git

    deactivate
    echo "=== Setup complete! nvdiffrast is compiled and active ==="
else
    echo "Error: Virtual environment directory at $SWUI_VENV does not exist. Please check your path configuration settings."
    exit 1
fi
