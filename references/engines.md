# Speech-to-Text Engine Selection

Use this before choosing Parakeet, Whisper, VibeVoice, Sortformer, Voxtral, or Gemma 4.

## Contents
- Workflow
  - 1. Choose a Transcription Engine
- Model Comparison
- Performance Notes

## Workflow

### 1. Choose a Transcription Engine

- **Qwen3-ASR 1.7B**: package `mlx-qwen3-asr`; **most accurate** open ASR (4.25% WER, #1 HF Open
  ASR Leaderboard, beats Parakeet ~6% and Whisper-lv3 ~7.4%); ~3.6-4.8x RT with `--timestamps`;
  30 languages + 22 Chinese dialects. **Killer feature: `--context "Technical terms: ..."`** biases
  decoding toward supplied vocabulary — feed it the domain's own names/jargon and proper-noun errors
  drop sharply (tested 2026-07-23: lava-blades->Lovable, Timik->Kimi, Norwick->Norvig, VGX->DGX).
  Also `--diarize`, `--forced-aligner`. Use when transcript quality matters and you have a term list
  (slides, glossary). Word-level timestamps via native MLX aligner. 0.6B variant is faster/lighter.
- **Parakeet v3**: package `parakeet-mlx`; best for English plus 25 European languages; fastest (~110x RT); most accurate (~6% WER); no built-in diarization. Faster than Qwen3-ASR but no context biasing — worse on dense proper nouns.
- **Whisper Large V3 Turbo**: package `mlx-audio`; best non-English accuracy across 99 languages; excellent Czech; ~9x RT; no built-in diarization.
- **Parakeet v2**: package `parakeet-mlx`; English-only; slightly better English accuracy; no built-in diarization.
- **Voxtral Realtime 4B**: package `mlx-audio`; streaming/realtime; 13 languages, not Czech; ~2x RT; no built-in diarization.
- **Voxtral Mini 3B**: package `mlx-audio`; broken MLX conversion; produces only `<unk>`; do not use.
- **VibeVoice-ASR 4-bit**: package `mlx-audio`; built-in speaker diarization, timestamps, hotwords; 50+ languages; ~7x RT.
- **Gemma 4 12B (LiteRT-LM)**: tool `litert-lm` (uv tool); audio *understanding* (speech translation, audio Q&A, tone/content) rather than bulk ASR; 30s/clip limit (25 tokens/s of audio). **Re-tested 2026-07-23 on 0.14.0: STILL not usable on macOS** — 20+ min of 99% CPU on a 20s clip, no output, same pathology as 0.13.1. QAT checkpoints don't fix it (memory, not the audio path); Gemma-4 audio gives no timestamps/diarization anyway. llama.cpp now has native Gemma-4 audio (PR #21421) but independent tests report looping/hallucination. Do not route audio here.

**Default recommendation:** Use **Qwen3-ASR 1.7B** when transcript quality matters and you can
supply a term list (`--context`) — it is the accuracy leader and the only local engine with context
biasing. Use **Parakeet v3** when you need raw speed and names don't matter. Use **Whisper Large V3
Turbo** for the widest language coverage / best non-English. Use **VibeVoice-ASR** or Qwen3-ASR
`--diarize` when you need speaker labels (but see the diarization caveat in commands §8). **Gemma 4**
audio remains unusable on macOS as of 2026-07-23; the Eloquent app covers Gemma-4-quality file
transcription interactively if ever needed.

## Model Comparison

- Parakeet v3: 0.6B; ~110x RT on M3 Pro; 25 EU languages; ~2 GB memory; no diarization; tested good.
- Whisper Large V3 Turbo: 0.8B; ~9x RT on M3 Pro; 99 languages; ~3 GB memory; no diarization; tested excellent.
- Parakeet v2: 0.6B; ~110x RT; English only; ~2 GB memory; no diarization; tested.
- Sortformer v2.1: small; fast; language-agnostic; ~1 GB memory; diarization up to 4 speakers; untested.
- VibeVoice-ASR 4-bit: 7B; ~7x RT; 50+ languages; 5.71 GB download, ~18 GB resident, ~60 GB prefill peak; built-in diarization; see test fixtures.
- Voxtral Realtime 4B: 4B; ~2x RT; 13 languages; ~3 GB memory at 4-bit; no diarization; tested poor Czech.
- Voxtral Mini 3B: broken; do not use.
- Gemma 4 12B LiteRT: 12B; 6.5 GB download to `~/local-models/litert-lm-models` (symlinked from `~/.litert-lm/models`); 30s audio max per call; no diarization; audio understanding + translation, not bulk ASR.

## Performance Notes

- **Parakeet v3** is the fastest and most accurate for English/European languages. A 1-hour file transcribes in ~30-60 seconds on M3/M4.
- **Whisper Large V3 Turbo** is the best all-rounder for non-English languages. ~9x realtime on M3 Pro (24min Czech audio in 159s). Excellent accuracy, proper punctuation, good handling of archaic/dialectal speech.
- **Voxtral Realtime 4B** is slow (~2x RT) and only supports 13 languages. Czech audio produced mixed Czech/Russian transliteration. Best for its supported languages only.
- **VibeVoice-ASR** is heavy (9B/18GB) but does everything in one pass. Best for meetings where you need speaker labels.
- **Sortformer** is lightweight and can be paired with Parakeet for diarization without the memory cost of VibeVoice.
- First model load downloads from HuggingFace. Subsequent loads use cache at `~/.cache/huggingface/hub/`.
- **mlx-audio version:** Install v0.3.2+ from GitHub (`pip install git+https://github.com/Blaizzy/mlx-audio.git`). PyPI v0.3.1 lacks Voxtral Realtime and Whisper ASR support.
