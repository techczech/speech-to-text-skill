#!/bin/bash
# Build a tiny synthetic test clip with macOS `say` + ffmpeg, plus its reference text.
# Output goes to test-fixtures/ (audio is gitignored). Use it to smoke-test an engine
# without supplying your own recording:
#   ./scripts/make_synthetic_test_clip.sh
#   python -m mlx_qwen3_asr test-fixtures/synthetic.wav --language English
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p test-fixtures
TEXT="The quick brown fox jumps over the lazy dog. Today we are testing local speech recognition on a laptop. Numbers such as forty two and seventeen should come out cleanly."
say -o test-fixtures/synthetic.aiff "$TEXT"
ffmpeg -y -loglevel error -i test-fixtures/synthetic.aiff -ar 16000 -ac 1 test-fixtures/synthetic.wav
echo "$TEXT" > test-fixtures/synthetic_reference.txt
echo "Wrote test-fixtures/synthetic.wav and test-fixtures/synthetic_reference.txt"
