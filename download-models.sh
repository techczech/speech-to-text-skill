#!/bin/bash
# Optional: pre-download two STT models (~4.7 GB total) so the first transcription does not stall.
# Models go to Hugging Face's cache: $HF_HUB_CACHE or $HF_HOME/hub if set, else ~/.cache/huggingface/hub.
#   cd <skill-dir> && ./download-models.sh
# Requires: huggingface_hub (installed with the packages in references/setup.md).

set -e

echo "=== Whisper Large V3 Turbo ASR fp16 (~1.6 GB) ==="
echo "Use -asr-fp16 variant (has preprocessor_config.json needed by mlx-audio)"
python3 -c "
from huggingface_hub import snapshot_download
snapshot_download('mlx-community/whisper-large-v3-turbo-asr-fp16')
print('Done: whisper-large-v3-turbo-asr-fp16')
"

echo ""
echo "=== Voxtral Realtime 4B 4-bit (~3.1 GB) ==="
python3 -c "
from huggingface_hub import snapshot_download
snapshot_download('mlx-community/Voxtral-Mini-4B-Realtime-2602-4bit')
print('Done: Voxtral-Mini-4B-Realtime-2602-4bit')
"

echo ""
echo "=== All downloads complete ==="
