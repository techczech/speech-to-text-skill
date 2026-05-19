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

Models are stored in `~/local-models` (set via `HF_HUB_CACHE` in `.zshrc`, symlinked from `~/.cache/huggingface/hub`). This is shared with the text-to-speech skill and all other HuggingFace-based tools.

A reference setup lives at `~/gitrepos/02_workskills/speech-to-text/`.

## Supported Audio Formats

Any format supported by ffmpeg: WAV, MP3, M4A, FLAC, OGG, OPUS, WMA, AAC, WebM, etc. Parakeet-mlx and mlx-audio use ffmpeg internally for decoding.

## Test Fixtures

Reference transcripts and engine outputs are included for testing and comparing engines:

- `test-fixtures/podcast_episode_reference.srt`: TTS-generated English podcast; clean synthetic speech; ~87s.
- `test-fixtures/Kozik_a_deda_reference.md`: archival Czech radio recording; canonical reference transcript; ~24 min.
- `test-fixtures/Kozik_a_deda_eval.md`: Czech evaluation criteria; scoring rubric for transcript comparison.
- `test-fixtures/Kozik_a_deda_whisper_v3_turbo.md`: Czech Whisper Large V3 Turbo output; excellent quality; 159s (~9x RT).

**Test audio locations:**
- English: `~/gitrepos/x-experiments/podcast-test/output/podcast_episode.wav`
- Czech: `~/Library/CloudStorage/OneDrive-Personal/0 Documents/1. Big writing projects/Czech Language Project/Y Misc/Na poslouchání/O pohádkové babičce/Kozik a deda.mp3`

Use these to compare engines or verify new model downloads produce equivalent or better results.
