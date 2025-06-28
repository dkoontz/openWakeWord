# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Testing
- `pytest` - Run all tests with coverage, linting, and type checking
- `pip install -e .[test]` - Install package in development mode with test dependencies

### Installation Options
- `pip install -e .` - Install in development mode (basic dependencies)
- `pip install -e .[full]` - Install with all dependencies for training and development
- `pip install -e .[test]` - Install with testing dependencies

### Platform-Specific Setup
On Linux systems, install SpeexDSP for noise suppression:
```bash
sudo apt-get install libspeexdsp-dev
pip install https://github.com/dscripka/openWakeWord/releases/download/v0.1.1/speexdsp_ns-0.1.2-cp38-cp38-linux_x86_64.whl
```

## Project Architecture

### Core Components
- **`openwakeword/model.py`** - Main Model class for wake word detection, handles audio preprocessing and inference
- **`openwakeword/train.py`** - Training pipeline using PyTorch for custom wake word models
- **`openwakeword/utils.py`** - Audio feature extraction, bulk prediction utilities, and helper functions
- **`openwakeword/data.py`** - Data processing, augmentation, and synthetic data generation
- **`openwakeword/vad.py`** - Voice Activity Detection using Silero VAD model
- **`openwakeword/custom_verifier_model.py`** - Custom voice verification for speaker-specific wake words

### Model Architecture
Three-stage inference pipeline:
1. **Melspectrogram computation** (ONNX model) - Audio preprocessing 
2. **Feature extraction** (TensorFlow Lite) - Google's pre-trained speech embedding backbone
3. **Classification** (TensorFlow Lite/ONNX) - Wake word/phrase detection models

### Pre-trained Models
Available models in `openwakeword.MODELS`:
- `alexa` - "alexa"
- `hey_mycroft` - "hey mycroft" 
- `hey_jarvis` - "hey jarvis"
- `hey_rhasspy` - "hey rhasspy"
- `timer` - Timer-related phrases
- `weather` - Weather-related phrases

### Key Features
- **Synthetic training data** - Models trained entirely on TTS-generated speech
- **Multi-framework support** - TensorFlow Lite (default) and ONNX inference
- **Noise suppression** - Optional SpeexDSP integration
- **Voice Activity Detection** - Silero VAD for reducing false positives
- **Custom verifier models** - Speaker-specific second-stage filtering

### Training Workflow
1. Generate synthetic positive examples using TTS models
2. Collect/prepare negative examples (speech, noise, music)
3. Extract features using frozen Google embedding model
4. Train small classification head using PyTorch
5. Convert to TensorFlow Lite/ONNX for inference

### Example Usage Patterns
- `examples/detect_from_microphone.py` - Real-time microphone detection
- `examples/web/` - Web streaming examples with WebSocket integration
- `notebooks/` - Training tutorials and automated model training

### Performance Testing
Models evaluated on:
- False-reject rates using realistic noisy/reverberant conditions
- False-accept rates using Dinner Party Corpus (~5.5 hours far-field speech)
- Target: <5% false-reject, <0.5/hour false-accept rates