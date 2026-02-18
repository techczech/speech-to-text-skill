---
name: speech-to-text
description: |
  Transcribe audio files to text locally on Apple Silicon using MLX. Produces time-coded transcripts with optional speaker diarization and Claude-powered cleanup. No cloud APIs required for transcription.

  TRIGGERS: Use when:
  - User asks to transcribe audio, a recording, a meeting, or a podcast
  - User wants speech-to-text, STT, or automatic speech recognition (ASR)
  - User wants a time-coded or timestamped transcript (SRT, VTT, JSON)
  - User asks for speaker diarization (who said what)
  - User mentions parakeet, voxtral, mlx-audio, or local transcription
  - User has a .wav, .mp3, .m4a, .flac, .ogg, or other audio file to transcribe
  - Companion skill to text-to-speech (TTS)
---

# Speech-to-Text (Local ASR on MLX)

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

## Quick Start

For the fastest path to a transcript, use parakeet-mlx CLI:

```bash
source venv/bin/activate
parakeet-mlx audio.wav
```

This prints the transcript to stdout. For time-coded output:

```bash
parakeet-mlx audio.wav --output-format srt --output-dir ./output
parakeet-mlx audio.wav --output-format vtt --highlight-words --output-dir ./output
parakeet-mlx audio.wav --output-format all --output-dir ./output  # txt, srt, vtt, json
```

## Workflow

### 1. Choose a Transcription Engine

| Engine | Package | Best For | Diarization |
|--------|---------|----------|-------------|
| **Parakeet v3** | `parakeet-mlx` | English + 25 EU languages, fastest (~110x RT), most accurate (6% WER) | No (add separately) |
| **Whisper Large V3 Turbo** | `mlx-audio` | Best non-English accuracy (99 languages), excellent Czech (~9x RT) | No |
| **Parakeet v2** | `parakeet-mlx` | English only, slightly better English accuracy | No (add separately) |
| **Voxtral Realtime 4B** | `mlx-audio` | Streaming/realtime, 13 languages (not Czech), ~2x RT | No |
| ~~Voxtral Mini 3B~~ | `mlx-audio` | **BROKEN** — corrupted MLX conversion, produces only `<unk>` | No |
| **VibeVoice-ASR** | `mlx-audio` | Built-in speaker diarization + timestamps in one pass | **Yes (built-in)** |

**Default recommendation:** Use **Parakeet v3** for English/European languages. Use **Whisper Large V3 Turbo** when you need the widest language coverage or best non-English accuracy. Use **VibeVoice-ASR** when you need speaker diarization.

### 2. Basic Transcription with Parakeet (Default)

#### CLI

```bash
# Default (Parakeet v3, multilingual)
parakeet-mlx audio.wav

# English-only (slightly more accurate for English)
parakeet-mlx audio.wav --model mlx-community/parakeet-tdt-0.6b-v2

# All output formats with word-level timestamps
parakeet-mlx audio.wav --output-format all --highlight-words --output-dir ./output

# Beam search for potentially better accuracy
parakeet-mlx audio.wav --decoding beam --beam-size 5
```

#### Python

```python
#!/usr/bin/env python3
from parakeet_mlx import from_pretrained

model = from_pretrained("mlx-community/parakeet-tdt-0.6b-v3")
result = model.transcribe("audio.wav")

# Full text
print(result.text)

# Time-coded sentences
for sentence in result.sentences:
    print(f"[{sentence.start:.1f}s - {sentence.end:.1f}s] {sentence.text}")

# Word-level timestamps
for word in result.words:
    print(f"  [{word.start:.2f}s] {word.text}")
```

### 3. Transcription with Whisper

OpenAI Whisper Large V3 Turbo provides the widest language coverage (99 languages) and excellent non-English accuracy. Slower than Parakeet (~9x realtime vs ~110x) but produces higher-quality transcripts for non-English audio.

**Important:** Use the `-asr-fp16` model variant — the plain `whisper-large-v3-turbo` is missing processor files needed by mlx-audio.

#### CLI

```bash
python -m mlx_audio.stt.generate \
  --model mlx-community/whisper-large-v3-turbo-asr-fp16 \
  --audio audio.wav \
  --verbose
```

#### Python

```python
#!/usr/bin/env python3
from mlx_audio.stt.utils import load

model = load("mlx-community/whisper-large-v3-turbo-asr-fp16")
result = model.generate(audio="audio.wav")
print(result.text)
```

### 4. Transcription with Speaker Diarization

#### Option A: VibeVoice-ASR (Recommended -- Single Model, MLX-native)

Microsoft's VibeVoice-ASR (9B parameters) does transcription AND diarization in a single pass. Best for meetings, interviews, and multi-speaker audio.

```python
#!/usr/bin/env python3
from mlx_audio.stt.utils import load

model = load("mlx-community/VibeVoice-ASR-bf16")
result = model.generate(audio="meeting.wav", max_tokens=8192, temperature=0.0)

# result contains speaker-labeled segments with timestamps
print(result.text)
```

CLI:
```bash
python -m mlx_audio.stt.generate \
  --model mlx-community/VibeVoice-ASR-bf16 \
  --audio meeting.wav \
  --max-tokens 8192 \
  --temp 0.0 \
  --verbose
```

**Note:** VibeVoice-ASR is a 9B model (~18GB in bf16). It handles up to 60 minutes of audio. First load downloads from HuggingFace.

#### Option B: Parakeet + Sortformer (Two-Model Pipeline)

Use Parakeet for accurate transcription and NVIDIA Sortformer for diarization (up to 4 speakers), then merge timestamps.

```python
#!/usr/bin/env python3
import json
from parakeet_mlx import from_pretrained

# Step 1: Transcribe with Parakeet (word-level timestamps)
asr_model = from_pretrained("mlx-community/parakeet-tdt-0.6b-v3")
result = asr_model.transcribe("meeting.wav")

# Step 2: Diarize with Sortformer via mlx-audio
from mlx_audio.stt.utils import load as load_diar
diar_model = load_diar("mlx-community/diar_streaming_sortformer_4spk-v2.1-fp32")
diar_result = diar_model.generate(audio="meeting.wav")

# Step 3: Merge — assign speaker labels to transcribed words
# Match each word's timestamp to the overlapping diarization segment
def assign_speakers(words, diar_segments):
    labeled = []
    for word in words:
        mid = (word.start + word.end) / 2
        speaker = "Unknown"
        for seg in diar_segments:
            if seg["start"] <= mid <= seg["end"]:
                speaker = seg["speaker"]
                break
        labeled.append({"start": word.start, "end": word.end,
                        "text": word.text, "speaker": speaker})
    return labeled

# Output merged transcript
labeled_words = assign_speakers(result.words, diar_result.segments)
current_speaker = None
for w in labeled_words:
    if w["speaker"] != current_speaker:
        current_speaker = w["speaker"]
        print(f"\n[{w['start']:.1f}s] {current_speaker}:")
    print(f"  {w['text']}", end="")
print()
```

**Note:** Sortformer supports up to 4 speakers and is language-agnostic. It's much lighter than VibeVoice-ASR.

### 5. Transcription with Voxtral

#### Voxtral Realtime 4B (Streaming)

Voxtral Realtime 4B (Voxtral 2, Feb 2026, Apache 2.0) supports 13 languages: English, French, German, Spanish, Italian, Portuguese, Dutch, Russian, Chinese, Japanese, Korean, Arabic, Hindi. Runs at ~2x realtime in 4-bit quantization (~3GB memory).

**Note:** Czech is NOT in the supported language list. Voxtral Realtime produces mixed Czech/Russian transliteration for Czech audio. Use Parakeet v3 or Whisper for Czech.

```bash
pip install voxmlx
# Transcribe from microphone:
voxmlx
# Transcribe a file:
voxmlx --audio audio.wav
```

Or via mlx-audio (requires v0.3.2+):
```bash
python -m mlx_audio.stt.generate \
  --model mlx-community/Voxtral-Mini-4B-Realtime-2602-4bit \
  --audio audio.wav
```

Python:
```python
#!/usr/bin/env python3
from mlx_audio.stt.utils import load

model = load("mlx-community/Voxtral-Mini-4B-Realtime-2602-4bit")
result = model.generate("audio.wav", max_tokens=8192)
print(result.text)
```

#### Voxtral Mini 3B (Batch) -- BROKEN

**Do not use.** `mlx-community/Voxtral-Mini-3B-2507-bf16` has corrupted weights (~half the LLM layers are zeros). Produces only `<unk>` tokens. This is a broken mlx-community conversion, not fixable locally. Wait for a corrected conversion or use Whisper for broad language coverage instead.

### 6. Generate Time-Coded Transcript File

Write a Python script to produce SRT or VTT from any engine:

```python
#!/usr/bin/env python3
"""Generate time-coded transcript from audio using Parakeet."""
import sys
from pathlib import Path
from parakeet_mlx import from_pretrained

def format_timestamp_srt(seconds):
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    ms = int((seconds % 1) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

def transcribe_to_srt(audio_path, output_path=None):
    model = from_pretrained("mlx-community/parakeet-tdt-0.6b-v3")
    result = model.transcribe(audio_path)

    if output_path is None:
        output_path = Path(audio_path).with_suffix(".srt")

    lines = []
    for i, sentence in enumerate(result.sentences, 1):
        start = format_timestamp_srt(sentence.start)
        end = format_timestamp_srt(sentence.end)
        lines.append(f"{i}")
        lines.append(f"{start} --> {end}")
        lines.append(sentence.text.strip())
        lines.append("")

    Path(output_path).write_text("\n".join(lines), encoding="utf-8")
    print(f"Saved SRT: {output_path} ({len(result.sentences)} segments)")
    return result

if __name__ == "__main__":
    audio = sys.argv[1] if len(sys.argv) > 1 else "audio.wav"
    transcribe_to_srt(audio)
```

### 7. Claude Cleanup Pass

After generating a raw transcript, use Claude to produce a clean, readable version. This is the standard two-step pipeline:

**Step 1:** Generate raw time-coded transcript (any method above)
**Step 2:** Pass the raw transcript to Claude with a cleanup prompt

The cleanup prompt pattern:

```
Clean up this raw speech-to-text transcript. Preserve the meaning exactly but:
- Fix speech recognition errors and mis-transcriptions
- Add proper punctuation and capitalization
- Remove filler words (um, uh, you know, like) unless they convey meaning
- Fix obvious word boundary errors
- Split into logical paragraphs
- If speaker labels are present, preserve them
- Keep timestamps on paragraph boundaries (not every sentence)

Do NOT summarize, rephrase, or add content. The goal is a faithful, readable
version of what was said.

Raw transcript:
---
{raw_transcript}
---
```

For meeting notes, use a more structured prompt:

```
Convert this diarized meeting transcript into clean meeting notes:
- Identify speakers by their labels (Speaker 1, Speaker 2, etc.)
- Group by topic/agenda item where possible
- Fix transcription errors
- Remove filler words and false starts
- Preserve all substantive content and decisions
- Add a brief summary at the top

Transcript:
---
{raw_transcript}
---
```

## Supported Audio Formats

Any format supported by ffmpeg: WAV, MP3, M4A, FLAC, OGG, OPUS, WMA, AAC, WebM, etc. Parakeet-mlx and mlx-audio use ffmpeg internally for decoding.

## Model Comparison

| Model | Size | Speed (M3 Pro) | Languages | Memory | Diarization | Status |
|-------|------|---------------|-----------|--------|-------------|--------|
| Parakeet v3 | 0.6B | ~110x RT | 25 EU languages | ~2GB | No | Tested, good |
| Whisper Large V3 Turbo | 0.8B | ~9x RT | 99 languages | ~3GB | No | Tested, excellent |
| Parakeet v2 | 0.6B | ~110x RT | English only | ~2GB | No | Tested |
| Sortformer v2.1 | small | fast | Language-agnostic | ~1GB | Yes (up to 4 speakers) | Untested |
| VibeVoice-ASR | 9B | ~5-10x RT | Multi | ~18GB | Yes (built-in) | Untested |
| Voxtral Realtime 4B | 4B | ~2x RT | 13 languages | ~3GB (4bit) | No | Tested, poor Czech |
| ~~Voxtral Mini 3B~~ | 3B | N/A | 13 languages | ~9GB (bf16) | No | BROKEN |

## Performance Notes

- **Parakeet v3** is the fastest and most accurate for English/European languages. A 1-hour file transcribes in ~30-60 seconds on M3/M4.
- **Whisper Large V3 Turbo** is the best all-rounder for non-English languages. ~9x realtime on M3 Pro (24min Czech audio in 159s). Excellent accuracy, proper punctuation, good handling of archaic/dialectal speech.
- **Voxtral Realtime 4B** is slow (~2x RT) and only supports 13 languages. Czech audio produced mixed Czech/Russian transliteration. Best for its supported languages only.
- **VibeVoice-ASR** is heavy (9B/18GB) but does everything in one pass. Best for meetings where you need speaker labels.
- **Sortformer** is lightweight and can be paired with Parakeet for diarization without the memory cost of VibeVoice.
- First model load downloads from HuggingFace. Subsequent loads use cache at `~/.cache/huggingface/hub/`.
- **mlx-audio version:** Install v0.3.2+ from GitHub (`pip install git+https://github.com/Blaizzy/mlx-audio.git`). PyPI v0.3.1 lacks Voxtral Realtime and Whisper ASR support.

## Output Formats

- **TXT**: Plain text transcript
- **SRT**: SubRip subtitle format with timestamps
- **VTT**: WebVTT format with optional word-level highlights
- **JSON**: Structured output with word-level timestamps and metadata

## Troubleshooting

- **Requires macOS 15+** on Apple Silicon (M1/M2/M3/M4)
- **ffmpeg needed**: `brew install ffmpeg`
- **Slow first load**: Models download from HuggingFace (Parakeet ~1.2GB, VibeVoice ~18GB). Set `HF_TOKEN` for faster access
- **Out of memory with VibeVoice**: Use Parakeet + Sortformer instead (much lighter)
- **Non-European languages**: Use Voxtral instead of Parakeet
- **Poor accuracy**: Try beam search (`--decoding beam --beam-size 5`), or use a different engine
- **Long audio files**: Parakeet handles hours of audio natively. VibeVoice handles up to 60 minutes

## Test Fixtures

Reference transcripts and engine outputs are included for testing and comparing engines:

| File | Source | Language | Notes |
|------|--------|----------|-------|
| `test-fixtures/podcast_episode_reference.srt` | TTS-generated podcast (Qwen3-TTS) | English | Clean synthetic speech, ~87s |
| `test-fixtures/Kozik_a_deda_reference.md` | Archival Czech radio recording | Czech | ~24min, canonical reference transcript |
| `test-fixtures/Kozik_a_deda_eval.md` | Evaluation criteria | Czech | Scoring rubric for Czech transcript comparison |
| `test-fixtures/Kozik_a_deda_whisper_v3_turbo.md` | Whisper Large V3 Turbo output | Czech | Excellent quality, 159s (~9x RT) |

**Test audio locations:**
- English: `~/gitrepos/x-experiments/podcast-test/output/podcast_episode.wav`
- Czech: `~/Library/CloudStorage/OneDrive-Personal/0 Documents/1. Big writing projects/Czech Language Project/Y Misc/Na poslouchání/O pohádkové babičce/Kozik a deda.mp3`

Use these to compare engines or verify new model downloads produce equivalent or better results.

## Related Skills

- **text-to-speech**: Companion skill for audio generation (TTS) using Qwen3-TTS via mlx-audio
