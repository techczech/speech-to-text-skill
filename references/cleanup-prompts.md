# Transcript Cleanup Prompts

Use this after raw transcription when the user wants readable transcript or meeting notes.

## Contents
  - 7. Claude Cleanup Pass

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
