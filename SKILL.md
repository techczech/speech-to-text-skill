---
name: speech-to-text
description: "Transcribe audio locally."
---

# Speech-to-Text

## First Move

- Choose engine from `references/engines.md`, then load commands for that engine.

## Use

- Transcribe audio locally on Apple Silicon.
- Use Parakeet by default for English and European languages.
- Use Whisper for broad language coverage; use VibeVoice when speaker labels matter.
- Gemma 4 (LiteRT-LM) for more-than-transcription tasks is documented but NOT yet usable on macOS (tested 2026-06-05) — check commands §7 status before routing audio there; Eloquent app is the working Gemma 4 option (GUI).

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
