#!/bin/bash
# Download STT models for evaluation
# Run this when on a fast connection:
#   cd ~/gitrepos/02_workskills/speech-to-text && ./download-models.sh

set -e
export HF_HUB_CACHE=~/local-models

echo "=== Whisper Large V3 Turbo ASR fp16 (~1.6 GB) ==="
echo "Use -asr-fp16 variant (has preprocessor_config.json needed by mlx-audio)"
python3 -c "
from huggingface_hub import snapshot_download
snapshot_download('mlx-community/whisper-large-v3-turbo-asr-fp16', cache_dir='$HOME/local-models')
print('Done: whisper-large-v3-turbo-asr-fp16')
"

echo ""
echo "=== Voxtral Realtime 4B 4-bit (~3.1 GB) ==="
echo "Voxtral 2 (Feb 2026), Apache 2.0, 13 languages, streaming architecture"
python3 -c "
from huggingface_hub import snapshot_download
snapshot_download('mlx-community/Voxtral-Mini-4B-Realtime-2602-4bit', cache_dir='$HOME/local-models')
print('Done: Voxtral-Mini-4B-Realtime-2602-4bit')
"

echo ""
echo "=== All downloads complete ==="
echo "Total: ~4.7 GB"
