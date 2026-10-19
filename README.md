# ComfyUI-CUDA
Dependency fixes for nvidia CUDA. Found while looking at the SwarmUI logs. Some are for custom nodes (ComfyUI-3D-Pack).

## ComfyUI-CUDA/hotfixes

1. **ComfyUI-3D-Pack/mesh_fixed.py:** Fixing missing imports
2. **kiui/op_fixed.py:** Fixing missing imports
3. **ComfyUI/requirements_fixed.txt:** Fixing missing dependencies

## ComfyUI-CUDA/fix_dependencies_cuda.sh

- SWUI_PATH: Manually set SwarmUI or ComfyUI installation folder.
- Copies the fixes to their supposed location assuming they have been properly installed.
- (Fedora DNF) Adds the RPMFusion free and non-free repo as well as install nvidia runtime drivers. Then adds the nvidia dev repo to install the cuda-toolkit.
- Creates required environment variables for nvdiffrast.
- Activates the python venv and install ninja and nvdiffrast.

## To-Do

- SWUI_PATH initialization need to be changed to an automatic detection of SwarmUI or ComfyUI installation folder.
- Add support for RPM/YUM/APT/Conda/Powershell
- Fix: ModuleNotFoundError: No module named 'diff_gaussian_rasterization' (SwarmUI/dlbackend/ComfyUI/custom_nodes/ComfyUI-3D-Pack/MVs_Algorithms/GaussianSplatting/main_3DGS_renderer.py", line 24)
  - unable to build the module from https://github.com/graphdeco-inria/diff-gaussian-rasterization, subprocess.CalledProcessError: Command '['ninja', '-v']' returned non-zero exit status 2.
  - Seems I'm better off reinstalling all the custom nodes from source instead of trying to fix every dependencies
