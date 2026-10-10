# speech-to-text

A Claude Code skill that transcribes audio and video files **locally** on Apple Silicon (MLX). Nothing is uploaded: you get plain text, SRT, VTT or JSON transcripts with timestamps, optional speaker labels, and an optional Claude-powered cleanup pass. It is for anyone who wants private, offline transcription of meetings, interviews, lectures or podcasts.

## Requirements

- Apple Silicon Mac (M1 or later) running a recent macOS. Models run on the MLX framework, which needs Apple Silicon.
- Python 3.10+ and `ffmpeg` (`brew install ffmpeg`). `uv` is needed only for the optional Gemma 4 / LiteRT route.
- Disk: about 1.2 to 6 GB per model (Qwen3-ASR 0.6B ~1.2 GB, 1.7B ~4.4 GB, Whisper Large V3 Turbo ~1.6 GB, Voxtral Realtime ~3.1 GB, VibeVoice-ASR 4-bit ~5.7 GB).
- RAM: 8 GB is enough for Parakeet or Whisper (~2 to 3 GB resident). VibeVoice-ASR (diarization in one pass) needs about 18 GB resident and peaks near 60 GB on long audio, so use Qwen3-ASR `--diarize` on smaller machines.
- A Hugging Face account and access token **only** for speaker diarization with `--diarize`: accept the terms for the gated model `pyannote/speaker-diarization-community-1`, then run `hf auth login`.
- Models download from Hugging Face on first use into the standard cache (`$HF_HUB_CACHE`, else `$HF_HOME/hub`, else `~/.cache/huggingface/hub`). Set `HF_HOME` to keep them on another volume.

## Install

```bash
git clone https://github.com/techczech/speech-to-text-skill ~/.claude/skills/speech-to-text
cd ~/.claude/skills/speech-to-text
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install parakeet-mlx
pip install git+https://github.com/Blaizzy/mlx-audio.git   # Whisper / Voxtral / VibeVoice
pip install "mlx-qwen3-asr[aligner,diarize]"               # Qwen3-ASR with context biasing
./download-models.sh                                        # optional: pre-download Whisper + Voxtral (~4.7 GB)
```

Then ask Claude to transcribe a file ("transcribe meeting.m4a with speaker labels"), or run an engine directly, for example `parakeet-mlx audio.wav --output-format srt`. Recipes per engine are in `references/commands.md`; `references/engines.md` helps you choose.

To smoke-test without your own recording, run `./scripts/make_synthetic_test_clip.sh` (macOS `say` + ffmpeg) and transcribe `test-fixtures/synthetic.wav`. No audio or third-party transcripts ship with this repo.

## Models and licences

This skill wraps third-party models and tools; their licences are theirs. Where the skill's own notes do not state a licence, check the model card.

| Model | Source | Licence / terms |
|---|---|---|
| Qwen3-ASR 1.7B (and 0.6B) | `Qwen/Qwen3-ASR-1.7B` | See the model card |
| Parakeet TDT 0.6B v3 / v2 | `mlx-community/parakeet-tdt-0.6b-v3`, `mlx-community/parakeet-tdt-0.6b-v2` (converted from NVIDIA Parakeet) | See the model card |
| Whisper Large V3 Turbo | `mlx-community/whisper-large-v3-turbo-asr-fp16` (converted from OpenAI Whisper) | See the model card |
| Voxtral Realtime 4B | `mlx-community/Voxtral-Mini-4B-Realtime-2602-4bit` | Apache 2.0 (as noted in `references/commands.md`) |
| VibeVoice-ASR 4-bit | `mlx-community/VibeVoice-ASR-4bit` (Microsoft VibeVoice-ASR) | MIT (as noted in `references/commands.md`) |
| Sortformer v2.1 diarizer | `mlx-community/diar_streaming_sortformer_4spk-v2.1-fp32` | See the model card |
| pyannote diarization (used by `--diarize`) | `pyannote/speaker-diarization-community-1` (gated) | Accept the terms on the model page; see the model card |
| Voxtral Mini 3B | `mlx-community/Voxtral-Mini-3B-2507-bf16` | Broken MLX conversion; listed only to warn you off it |

Check each model's terms before commercial use.

## Layout

- `SKILL.md`: the skill entry point Claude reads.
- `references/`: engine choice, command recipes, setup, troubleshooting, cleanup prompts.
- `scripts/`: `parakeet_to_srt.py` and the synthetic test-clip builder.
- `download-models.sh`: optional model pre-download.

## Licence

MIT. See `LICENSE`.
