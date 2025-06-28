# Docker Setup for openWakeWord Training

This Docker setup provides a complete environment for running the openWakeWord automatic model training notebook with GPU acceleration.

## Prerequisites

- Docker and Docker Compose installed
- NVIDIA Docker runtime (nvidia-docker2) for GPU support
- NVIDIA GPU with CUDA support

### Install NVIDIA Docker Runtime

```bash
# Ubuntu/Debian
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

## Quick Start

1. **Build and start the container:**
   ```bash
   docker-compose up -d
   ```

2. **Access Jupyter Lab:**
   - Open your browser to `http://localhost:8888` (or `http://your-server-ip:8888` from another computer)
   - No password required (configured for development use)

3. **Open the training notebook:**
   - Navigate to `notebooks/automatic_model_training.ipynb`
   - All dependencies are pre-installed and ready to use

4. **Stop the container:**
   ```bash
   docker-compose down
   ```

## What's Included

### Pre-installed Dependencies
- PyTorch with CUDA 12.1 support
- All Python packages required by the notebook:
  - piper-phonemize, webrtcvad
  - speechbrain, audiomentations
  - tensorflow-cpu, onnx_tf
  - datasets, deep-phonemizer
  - And many more...

### Pre-configured Components
- **piper-sample-generator**: Cloned and configured with TTS model
- **openWakeWord models**: Pre-trained models automatically downloaded
- **Jupyter Lab**: Configured for external access without authentication
- **GPU Support**: Full NVIDIA CUDA runtime access

## Usage Notes

### File Persistence
- Your project files are mounted at `/workspace` in the container
- Changes to notebooks and code are automatically persisted
- Training outputs and generated models will be saved to your local directory

### GPU Acceleration
- The container has full access to your NVIDIA GPU(s)
- PyTorch will automatically detect and use CUDA when available
- Training operations will be significantly faster with GPU support

### Network Access
- Jupyter is accessible from any network interface on port 8888
- For production use, consider adding authentication and HTTPS

### Large Files
- The notebook will download several GB of training data
- Consider the storage requirements when running training jobs
- Model files and datasets are excluded from Docker build context via `.dockerignore`

## Troubleshooting

### GPU Not Detected
```bash
# Test GPU access in container
docker-compose exec openwakeword-jupyter nvidia-smi
docker-compose exec openwakeword-jupyter python -c "import torch; print(torch.cuda.is_available())"
```

### Memory Issues
- Training requires significant RAM (8GB+ recommended)
- Adjust batch sizes in the notebook if you encounter memory errors

### Port Conflicts
- If port 8888 is already in use, modify the port mapping in `docker-compose.yml`:
  ```yaml
  ports:
    - "8889:8888"  # Use port 8889 instead
  ```

## Customization

### Adding Dependencies
Add new packages to the `Dockerfile` and rebuild:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Changing Jupyter Configuration
Modify the Jupyter settings in the `Dockerfile` and rebuild the container.

## Security Considerations

This setup is configured for development use with:
- No Jupyter authentication
- Root user access
- External network access

For production use, implement proper security measures including authentication, HTTPS, and user restrictions.