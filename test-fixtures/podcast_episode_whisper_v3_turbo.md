# Whisper Large V3 Turbo — English Podcast Test

- **Model:** `mlx-community/whisper-large-v3-turbo-asr-fp16`
- **Engine:** mlx-audio 0.3.2
- **Audio:** `~/gitrepos/x-experiments/podcast-test/output/podcast_episode.wav` (~87s, TTS-generated)
- **Language:** English (auto-detected)
- **Processing time:** 2.02 seconds (~43x realtime)
- **Peak memory:** 2.47 GB

## Transcript

[00:00.000 --> 00:06.820] Welcome to the Silicon Pulse, your weekly deep dive into the world of artificial intelligence and machine learning.

[00:07.300 --> 00:12.160] I'm your host, Ryan, and today we have a fascinating episode lined up for you.

[00:12.920 --> 00:19.320] Today we're talking about something truly exciting, running large language models right on your laptop.

[00:19.820 --> 00:24.600] No cloud, no API calls, just pure local inference.

[00:25.200 --> 00:28.160] Apple Silicon has completely changed the game here.

[00:28.160 --> 00:37.840] Think about it. Just two years ago, running a 7 billion parameter model locally would have been unthinkable for most developers.

[00:38.480 --> 00:49.840] Now, with frameworks like MLX optimized specifically for Apple's unified memory architecture, you can run these models at incredible speeds on a MacBook.

[00:49.840 --> 00:53.680] And it's not just text models.

[00:54.520 --> 01:04.520] We're now seeing text-to-speech, speech recognition, image generation, all running locally with remarkable quality.

[01:05.580 --> 01:10.780] The democratization of AI is happening right before our eyes.

[01:10.780 --> 01:14.420] That's all for today's episode of the Silicon Pulse.

[01:14.740 --> 01:18.200] If you enjoyed this, make sure to subscribe and leave a review.

[01:18.740 --> 01:24.940] Until next time, keep experimenting, keep building, and keep pushing the boundaries of what's possible.

[01:25.420 --> 01:26.380] See you next week!

## Notes

- Perfect transcription — every word matches the reference SRT
- Whisper hallucinated a duplicate "See you next week!" on trailing silence (segment 14, 86s-116s) — common Whisper behavior on padding/silence
- ~43x realtime on M3 Pro (vs ~110x for Parakeet on same hardware), but still very fast for an 87s clip
- Auto-detected language as English correctly
