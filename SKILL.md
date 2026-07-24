---
name: speech-to-text
description: "Transcribe audio locally."
---

# Speech-to-Text

## First Move

- Choose engine from `references/engines.md`, then load commands for that engine.

## Use

- Transcribe audio locally on Apple Silicon.
- Use **Qwen3-ASR** (`mlx-qwen3-asr`) when transcript quality matters and you can supply a term list — accuracy leader + `--context` biasing kills proper-noun errors (commands §8).
- Use Parakeet for raw speed on English/European when names don't matter.
- Use Whisper for broad language coverage; use VibeVoice or Qwen3-ASR `--diarize` when speaker labels matter (diarization caveat in §8: Mac torchcodec broken, use Sortformer on CUDA) — SOLVED 2026-07-24, see commands §8.
- Gemma 4 (LiteRT-LM) audio is NOT usable on macOS (re-tested 2026-07-23 on 0.14.0, same hang) — do not route audio there; Eloquent app is the GUI fallback.

## References

- `references/workflow.md`: choose which reference to load
- `references/setup.md`: install packages, confirm formats, or use fixtures
- `references/engines.md`: choose ASR or diarization engine
- `references/commands.md`: run transcription, diarization, or timestamp recipes
- `references/cleanup-prompts.md`: clean raw transcripts faithfully
- `references/troubleshooting.md`: debug model, memory, language, or output issues

## Scripts

- `scripts/parakeet_to_srt.py`: deterministic Parakeet-to-SRT helper

## Verification

- Check audio path, `ffmpeg`, venv, and model cache.
- Spot-check transcript quality against a few audio segments.
- For long diarized audio, check truncation and token limits.
