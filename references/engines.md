# Speech-to-Text Engine Selection

Use this before choosing Parakeet, Whisper, VibeVoice, Sortformer, or Voxtral.

## Contents
- Workflow
  - 1. Choose a Transcription Engine
- Model Comparison
- Performance Notes

## Workflow

### 1. Choose a Transcription Engine

- **Parakeet v3**: package `parakeet-mlx`; best for English plus 25 European languages; fastest (~110x RT); most accurate (~6% WER); no built-in diarization.
- **Whisper Large V3 Turbo**: package `mlx-audio`; best non-English accuracy across 99 languages; excellent Czech; ~9x RT; no built-in diarization.
- **Parakeet v2**: package `parakeet-mlx`; English-only; slightly better English accuracy; no built-in diarization.
- **Voxtral Realtime 4B**: package `mlx-audio`; streaming/realtime; 13 languages, not Czech; ~2x RT; no built-in diarization.
- **Voxtral Mini 3B**: package `mlx-audio`; broken MLX conversion; produces only `<unk>`; do not use.
- **VibeVoice-ASR 4-bit**: package `mlx-audio`; built-in speaker diarization, timestamps, hotwords; 50+ languages; ~7x RT.

**Default recommendation:** Use **Parakeet v3** for English/European languages. Use **Whisper Large V3 Turbo** when you need the widest language coverage or best non-English accuracy. Use **VibeVoice-ASR** when you need speaker diarization.

## Model Comparison

- Parakeet v3: 0.6B; ~110x RT on M3 Pro; 25 EU languages; ~2 GB memory; no diarization; tested good.
- Whisper Large V3 Turbo: 0.8B; ~9x RT on M3 Pro; 99 languages; ~3 GB memory; no diarization; tested excellent.
- Parakeet v2: 0.6B; ~110x RT; English only; ~2 GB memory; no diarization; tested.
- Sortformer v2.1: small; fast; language-agnostic; ~1 GB memory; diarization up to 4 speakers; untested.
- VibeVoice-ASR 4-bit: 7B; ~7x RT; 50+ languages; 5.71 GB download, ~18 GB resident, ~60 GB prefill peak; built-in diarization; see test fixtures.
- Voxtral Realtime 4B: 4B; ~2x RT; 13 languages; ~3 GB memory at 4-bit; no diarization; tested poor Czech.
- Voxtral Mini 3B: broken; do not use.

## Performance Notes

- **Parakeet v3** is the fastest and most accurate for English/European languages. A 1-hour file transcribes in ~30-60 seconds on M3/M4.
- **Whisper Large V3 Turbo** is the best all-rounder for non-English languages. ~9x realtime on M3 Pro (24min Czech audio in 159s). Excellent accuracy, proper punctuation, good handling of archaic/dialectal speech.
- **Voxtral Realtime 4B** is slow (~2x RT) and only supports 13 languages. Czech audio produced mixed Czech/Russian transliteration. Best for its supported languages only.
- **VibeVoice-ASR** is heavy (9B/18GB) but does everything in one pass. Best for meetings where you need speaker labels.
- **Sortformer** is lightweight and can be paired with Parakeet for diarization without the memory cost of VibeVoice.
- First model load downloads from HuggingFace. Subsequent loads use cache at `~/.cache/huggingface/hub/`.
- **mlx-audio version:** Install v0.3.2+ from GitHub (`pip install git+https://github.com/Blaizzy/mlx-audio.git`). PyPI v0.3.1 lacks Voxtral Realtime and Whisper ASR support.
