# Speech-to-Text Setup and Fixtures

Use this when preparing the environment or comparing model outputs.

## Contents
- Prerequisites
- Supported Audio Formats
- Test Fixtures

Transcribe audio files locally on Apple Silicon using NVIDIA Parakeet (via parakeet-mlx), OpenAI Whisper, or Mistral Voxtral (via mlx-audio). Supports time-coded output, speaker diarization, and Claude-powered transcript cleanup.

## Prerequisites

Ensure the environment is set up. Create a venv with the required packages:

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install parakeet-mlx
pip install git+https://github.com/Blaizzy/mlx-audio.git  # v0.3.2+ needed for Whisper/Voxtral Realtime
```

Also ensure ffmpeg is installed: `brew install ffmpeg`

Models are downloaded from Hugging Face on first use into the standard Hugging Face cache: `$HF_HUB_CACHE` if set, otherwise `$HF_HOME/hub`, otherwise `~/.cache/huggingface/hub`. To keep models on another volume, `export HF_HOME=/path/to/models` in your shell profile. The cache is shared with any other Hugging Face-based tool, including the text-to-speech skill.

Optional: `./download-models.sh` pre-downloads Whisper Large V3 Turbo and Voxtral Realtime (~4.7 GB).

## Supported Audio Formats

Any format supported by ffmpeg: WAV, MP3, M4A, FLAC, OGG, OPUS, WMA, AAC, WebM, etc. Parakeet-mlx and mlx-audio use ffmpeg internally for decoding.

## Test Fixtures

No real recordings or third-party transcripts ship with this skill. To smoke-test an engine, either supply your own audio or build a synthetic clip:

```bash
./scripts/make_synthetic_test_clip.sh   # macOS `say` + ffmpeg -> test-fixtures/synthetic.wav (gitignored)
```

`test-fixtures/synthetic_reference.txt` holds the text the clip speaks, so you can eyeball or diff the transcript against it. Audio files in `test-fixtures/` are gitignored and never committed.
