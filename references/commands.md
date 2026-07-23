# Speech-to-Text Command Recipes

Use this for concrete CLI and Python transcription commands.

## Contents
- Quick Start
  - 2. Basic Transcription with Parakeet (Default)
  - 3. Transcription with Whisper
  - 4. Transcription with Speaker Diarization
  - 5. Transcription with Voxtral
  - 6. Generate Time-Coded Transcript File
  - 7. Audio Understanding with Gemma 4 (LiteRT-LM)

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

Microsoft's VibeVoice-ASR (7B parameters, MIT licensed) does transcription AND diarization in a single pass with timestamps and speaker IDs. Supports 50+ languages and customized hotwords. Best for meetings, interviews, and multi-speaker audio.

**Use the 4-bit MLX conversion** (`mlx-community/VibeVoice-ASR-4bit`, 5.71GB). The bf16 variant (~17GB) costs more bandwidth and RAM for no real accuracy gain on the MLX-quantized weights.

```python
#!/usr/bin/env python3
from mlx_audio.stt.utils import load

model = load("mlx-community/VibeVoice-ASR-4bit")
result = model.generate(audio="meeting.wav", max_tokens=16384, temperature=0.0)

# result contains speaker-labeled segments with timestamps
print(result.text)
```

CLI (with JSON output to preserve speaker labels):
```bash
python -m mlx_audio.stt.generate \
  --model mlx-community/VibeVoice-ASR-4bit \
  --audio meeting.wav \
  --output-path output/meeting \
  --format json \
  --max-tokens 16384 \
  --verbose
```

**Hotwords / context:** Pass domain-specific proper nouns or terminology via `--context` to bias the decoder. Useful for names, company-specific jargon, place names, or non-English terms the base model may garble:

```bash
python -m mlx_audio.stt.generate \
  --model mlx-community/VibeVoice-ASR-4bit \
  --audio meeting.wav \
  --output-path output/meeting \
  --format json \
  --context "Kožík, Lukeš, Riegler, Nechálov, Romega" \
  --max-tokens 16384
```

**Notes:**
- Reference: Simon Willison's [27 Apr 2026 writeup](https://simonwillison.net/2026/Apr/27/vibevoice/) on running this on an M5 — 60 min audio in ~9 min (~7× RT).
- **RAM:** ~18GB resident during generation, but **peaks ~60GB during prefill** for long audio. The model self-reports 30GB; actual is roughly double.
- **Hard cap:** ~1 hour of audio per invocation. Longer files need splitting with overlapping segments for alignment.
- **Default `max-tokens=8192`** ≈ 25 min audio. Bump to `16384` for hour-long files or you will silently get a truncated transcript.

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

Use the bundled helper when Parakeet SRT output needs to be deterministic or reused:

```bash
python scripts/parakeet_to_srt.py audio.wav -o output/audio.srt
```

Options:
- `audio`: input audio path.
- `-o, --output`: optional `.srt` output path; default is beside the input file.
- `--model`: optional Parakeet model ID; default `mlx-community/parakeet-tdt-0.6b-v3`.

### 7. Audio Understanding with Gemma 4 (LiteRT-LM)

**Status (tested 2026-06-05, litert-lm 0.13.1, M4 Max):** text generation works; the audio
path does NOT — ~30 min per call regardless of clip length (a 4s clip churned 16+ min at 95%
CPU before being killed; a 30s clip took 32 min warm), and what little output appears is
mangled channel-control tokens (`<|channel>thought`). The pathology is per-call, not
per-second-of-audio. macOS support landed in v0.13 (2026-06-03); the Metal audio path is not ready. Keep using Parakeet (§2); for Gemma-4-quality file
transcription use the Eloquent app (below). Re-test on litert-lm releases after 0.13.x;
the recipes below are correct per Google's docs and should work once the runtime catches up.

Not a bulk transcriber — use when the task is more than ASR: translate speech, answer a
question about a clip, summarise tone/content, or transcribe+reason in one pass.
Constraints: **30s max audio per call** (25 tokens/s), 16kHz mono best, engine reloads
(~6.1GB) on every CLI invocation — chunked long files are slow; prefer Parakeet for those.
The model is GPU-only: every run needs `--backend gpu`, audio attachments additionally
need `--audio-backend gpu`. Missing `--backend gpu` fails with
"Main backend constraint mismatch. Model requires one of [gpu]". First run compiles
artifacts to a disk cache next to the model; later runs start faster.

#### Setup (once per machine)

```bash
UV_EXCLUDE_NEWER=$(date -v+1d +%Y-%m-%d) uv tool install litert-lm   # released <7d ago; uv gate override
# keep big models on the shared volume:
mkdir -p ~/local-models/litert-lm-models ~/.litert-lm
ln -sfn ~/local-models/litert-lm-models ~/.litert-lm/models
# hf-xet stalls on some networks — remove from the tool venv:
uv pip uninstall --python ~/.local/share/uv/tools/litert-lm/bin/python hf_xet
# model (~6.5GB, resumes on failure):
HF_HUB_DOWNLOAD_TIMEOUT=30 litert-lm import \
  --from-huggingface-repo=litert-community/gemma-4-12B-it-litert-lm \
  gemma-4-12B-it.litertlm gemma4-12b
```

#### Transcribe a clip (≤30s)

```bash
ffmpeg -y -i input.m4a -ac 1 -ar 16000 -t 30 clip.wav
litert-lm run gemma4-12b --backend gpu --audio-backend gpu --attachment clip.wav \
  --prompt "Transcribe this audio verbatim. Use digits for numbers. Output the transcript only."
```

#### Translate speech directly

```bash
litert-lm run gemma4-12b --backend gpu --audio-backend gpu --attachment clip.wav \
  --prompt "Transcribe this audio, then translate it into English. Format: Original: ... / English: ..."
```

#### Ask about a clip

```bash
litert-lm run gemma4-12b --backend gpu --audio-backend gpu --attachment clip.wav \
  --prompt "What is the speaker's tone and main point? One sentence each."
```

#### Long file (chunked — slow, engine reloads per chunk)

```bash
ffmpeg -y -i input.mp3 -ac 1 -ar 16000 -f segment -segment_time 28 /tmp/g4chunk_%03d.wav
for f in /tmp/g4chunk_*.wav; do
  litert-lm run gemma4-12b --backend gpu --audio-backend gpu --attachment "$f" \
    --prompt "Transcribe this audio verbatim. Output the transcript only."
done
```

For plain transcription of anything over ~2 minutes, Parakeet (§2) is faster and better.

#### Related local Gemma 4 audio options

- **Eloquent.app** (Google, installed via App Store): GUI transcription of audio/video files
  + system-wide dictation with Gemma 4 12B; zero setup, not scriptable; models app-internal.
- **video-analysis skill**: visual lane for the same clips; pair per its Recipe 4.

### 8. Qwen3-ASR with context biasing (mlx-qwen3-asr) — accuracy leader

Install (skill venv). NOTE: the venv's `pip`/activate may have a stale shebang after a repo move —
call it as `python -m`:

```bash
V=~/gitrepos/05_skills/speech-to-text/venv
$V/bin/python -m pip install "mlx-qwen3-asr[aligner,diarize]"
```

Transcribe with a term list — the whole point. Wrap terms as `"Technical terms: a, b, c"`
(a bare space/comma-joined list REGRESSES accuracy; the prefix form gives ~2x WER improvement,
per TypeWhisper #321):

```bash
$V/bin/python -m mlx_qwen3_asr audio.wav \
  --model Qwen/Qwen3-ASR-1.7B \
  --context "Technical terms: Claude Code, Codex, Qwen, Kimi, Lovable, Andreessen Horowitz" \
  --timestamps --output-format json --language English
```

- `--model` default is 0.6B (faster, ~1.2GB); `Qwen/Qwen3-ASR-1.7B` (~4.4GB) is more accurate.
- Output JSON: word-level `segments` [{text,start,end}] in SECONDS + a `chunks` list + `text`.
  Group words into sentence segments and convert to ms for TalkWeaver's transcript schema.
- Build the context string from the domain's own material. For TalkWeaver, each talk's
  `structure.json` (slide titles/markdown/OCR) is the ideal source — see the York re-transcription
  runner referenced in `_COORDINATION/presentations/_TASK-LOG/2026-07-23-york-transcript-cleaning.md`.
- ~3.6-4.8x realtime on M-series with `--timestamps`.

**Diarization caveat (macOS, 2026-07-23):** `--diarize` uses gated
`pyannote/speaker-diarization-community-1` (accept terms + HF_TOKEN) AND depends on `torchcodec`,
which fails to load `libavutil.56.dylib` against Homebrew ffmpeg 7.x — it finds the right speaker
COUNT but thrashes word-level labels (timelines misalign). Do not ship Mac diarization as-is. Clean
route: NeMo Sortformer on a CUDA box (DGX Spark, `~/asr/.venv2`; not gated, no torchcodec) — merge
speaker turns onto ASR segments by time overlap.
