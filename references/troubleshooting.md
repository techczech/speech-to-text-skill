# Speech-to-Text Troubleshooting

Use this when environment, model, timestamp, diarization, or quality checks fail.

## Contents
- Troubleshooting
- Related Skills

## Troubleshooting

- **Requires macOS 15+** on Apple Silicon (M1/M2/M3/M4)
- **ffmpeg needed**: `brew install ffmpeg`
- **Slow first load**: Models download from HuggingFace (Parakeet ~1.2GB, VibeVoice ~18GB). Set `HF_TOKEN` for faster access
- **Out of memory with VibeVoice**: VibeVoice 4-bit peaks at ~60GB during prefill on long audio (the model's self-reported 30GB is roughly half the actual). Either use shorter clips, or fall back to Parakeet + Sortformer (much lighter).
- **Truncated VibeVoice transcript**: The default `max-tokens=8192` ≈ 25 min of audio. Bump to `16384` for hour-long files.
- **VibeVoice 60-minute cap**: Hard limit per invocation. Split longer files with overlapping segments and merge.
- **Non-European languages**: Use Voxtral instead of Parakeet
- **Poor accuracy**: Try beam search (`--decoding beam --beam-size 5`), or use a different engine. For VibeVoice, pass `--context "Name1, Name2, ..."` to bias the decoder toward proper nouns.
- **Long audio files**: Parakeet handles hours of audio natively. VibeVoice handles up to 60 minutes per invocation.

## Related Skills

- **text-to-speech**: Companion skill for audio generation (TTS) using Qwen3-TTS via mlx-audio
