# Use PyTorch base image with CUDA support
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-devel

# Set working directory
WORKDIR /workspace

# Set timezone to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    libspeexdsp-dev \
    ffmpeg \
    libsndfile1 \
    tzdata \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
# Install piper-phonemize and other core dependencies first
RUN pip install --no-cache-dir \
    piper-phonemize \
    webrtcvad \
    mutagen==1.47.0 \
    torchinfo==1.8.0 \
    torchmetrics==1.2.0 \
    speechbrain==0.5.14 \
    audiomentations==0.33.0 \
    torch-audiomentations==0.11.0 \
    acoustics==0.2.6 \
    pyyaml \
    datasets==2.14.6 \
    pronouncing==0.2.0 \
    deep-phonemizer==0.0.19

# Install TensorFlow and related packages
RUN pip install --no-cache-dir \
    tensorflow-cpu==2.8.1 \
    tensorflow_probability==0.16.0 \
    "protobuf>=3.20,<4" \
    onnx==1.14.0 \
    onnx_tf==1.10.0

# Install Jupyter Lab and other development tools
RUN pip install --no-cache-dir \
    jupyterlab \
    ipywidgets \
    matplotlib \
    seaborn

# Clone piper-sample-generator
RUN git clone https://github.com/rhasspy/piper-sample-generator /workspace/piper-sample-generator

# Download the TTS model for piper-sample-generator
RUN mkdir -p /workspace/piper-sample-generator/models && \
    wget -O /workspace/piper-sample-generator/models/en_US-libritts_r-medium.pt \
    'https://github.com/rhasspy/piper-sample-generator/releases/download/v2.0.0/en_US-libritts_r-medium.pt'

# Copy the project files
COPY . /workspace/

# Install openWakeWord in development mode
RUN pip install -e .[full]

# Create directories for pre-trained models
RUN mkdir -p /workspace/openwakeword/resources/models

# Download pre-trained openWakeWord models
RUN wget https://github.com/dscripka/openWakeWord/releases/download/v0.5.1/embedding_model.onnx \
    -O /workspace/openwakeword/resources/models/embedding_model.onnx && \
    wget https://github.com/dscripka/openWakeWord/releases/download/v0.5.1/embedding_model.tflite \
    -O /workspace/openwakeword/resources/models/embedding_model.tflite && \
    wget https://github.com/dscripka/openWakeWord/releases/download/v0.5.1/melspectrogram.onnx \
    -O /workspace/openwakeword/resources/models/melspectrogram.onnx && \
    wget https://github.com/dscripka/openWakeWord/releases/download/v0.5.1/melspectrogram.tflite \
    -O /workspace/openwakeword/resources/models/melspectrogram.tflite

# Configure Jupyter Lab
RUN jupyter lab --generate-config
RUN echo "c.ServerApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.open_browser = False" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = True" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /root/.jupyter/jupyter_lab_config.py

# Expose Jupyter port
EXPOSE 8888

# Set environment variables for CUDA
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Start Jupyter Lab
CMD ["jupyter", "lab", "--allow-root"]