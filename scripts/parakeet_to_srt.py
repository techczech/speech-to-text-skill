#!/usr/bin/env python3
"""Generate SRT subtitles from audio using Parakeet MLX."""
from __future__ import annotations

import argparse
from pathlib import Path

def format_timestamp_srt(seconds: float) -> str:
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    ms = int((seconds % 1) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def transcribe_to_srt(audio_path: Path, output_path: Path | None = None, model_id: str = "mlx-community/parakeet-tdt-0.6b-v3"):
    from parakeet_mlx import from_pretrained

    model = from_pretrained(model_id)
    result = model.transcribe(str(audio_path))
    output_path = output_path or audio_path.with_suffix(".srt")

    lines: list[str] = []
    for i, sentence in enumerate(result.sentences, 1):
        lines.append(str(i))
        lines.append(f"{format_timestamp_srt(sentence.start)} --> {format_timestamp_srt(sentence.end)}")
        lines.append(sentence.text.strip())
        lines.append("")

    output_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Saved SRT: {output_path} ({len(result.sentences)} segments)")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate SRT subtitles from audio with Parakeet MLX.")
    parser.add_argument("audio", type=Path, help="Input audio file")
    parser.add_argument("-o", "--output", type=Path, help="Output .srt path")
    parser.add_argument("--model", default="mlx-community/parakeet-tdt-0.6b-v3", help="Parakeet model ID")
    args = parser.parse_args()
    transcribe_to_srt(args.audio, args.output, args.model)


if __name__ == "__main__":
    main()
