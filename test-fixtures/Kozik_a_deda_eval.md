# Kožík a děda — Evaluation Reference

This file documents canonical proper nouns, speaker diarization, and common ASR error patterns for evaluating transcription quality against `Kozik_a_deda_reference.md`.

## Proper Nouns — People

| Canonical Form | Role | Timestamps | Common ASR Errors |
|---|---|---|---|
| František Kožík | Writer, "zasloužilý umělec" | throughout | Košík, Kozík, Kožik |
| Josef Lukeš | Teacher, "Romega", Kožík's collaborator | throughout | Lukas, Lukáš, Lukesh |
| Boris Riegler | Moderator, author of the radio program | 3:42, 11:42, 24:00 | Rýgr, Řígler, Řezníček |
| Romega / Ondřej Romega | Literary character based on Lukeš | 7:39, 10:47, 11:27 | Omega, Romeo, Romiga |
| Jaroslav Seifert | National artist (mentioned) | 4:16 | Zajfert, Saifert |
| Marie Majerová | Writer (mentioned) | 4:16 | Majerova, Majerové |
| Václav Kaplický | Writer (mentioned) | 4:16 | Kaplicický, Kaplický |
| Karel Drbohlav | Headmaster, "zasloužilý učitel" | 12:46 | Drbolav, Trbohlav |
| Marie Zvoníčková | Former student at reunion | 1:43 | Zvoničková |
| Jan Amos Komenský | Historical figure (referenced) | 6:05, 23:17 | Komenského |
| Jakub | Lukeš's grandson (mentioned) | 19:11 | |

### Characters from *Zákon věrných strážců* (dramatized section, performed by actors)

| Character | Performed by | Notes |
|---|---|---|
| Stáňa | Dívka (female actor) | Student who challenges Romega about grading |
| Vašek | Male actor | Outspoken student, short interjections |
| Romega | Male actor | The teacher being challenged |
| Vypravěč | Male actor | Narrator, also voices inner thoughts |
| Gerhard | mentioned only | Student in grading dispute |
| Miloš | mentioned only | Student in grading dispute |
| Pavel | mentioned only | Student in grading dispute |
| Jana | mentioned only | Student in grading comparison |
| Vlasta | mentioned only | Student in grading comparison (not Vlastík) |
| Zorka | mentioned only | Student who improved from 11 to 5 errors |

### Names mentioned only in the dramatized section

| Name | Context |
|---|---|
| Vildové (od Vildů) | Family allegedly giving Romega gifts — accusation |
| Čihákovi (k Čihákům) | Family Romega allegedly visits — accusation |

## Proper Nouns — Places

| Canonical Form | Context | Common ASR Errors |
|---|---|---|
| Čapajevova ulice (v Čapajevově ulici) | Street in Prague where Kožík lived | Čapkova, Čapkově, Čapájeva, Čapájevova |
| Český Dub | Town where Lukeš taught after Nechálov | |
| Nechálov / na Nechálově | Village/school where Lukeš and Kožík collaborated | Nechvíl, Nechvíle, Nechálova (varies by case) |
| Světlá pod Ještědem | Town where Lukeš also worked | Světlá, Svetlá |
| Praha | Mentioned re: Dům československých dětí | |
| Dům československých dětí | Venue in Prague for readers' congress | |

## Proper Nouns — Works, Programs, and Institutions

| Canonical Form | Type | Timestamps | Common ASR Errors |
|---|---|---|---|
| *Zákon věrných strážců* | Book by Kožík about school life, won Albatros competition | 10:11, 10:47, 12:46 | Zákon věrných, strážců |
| *Zelená princezna* | Play by Kožík for children, based on *Pírinka* | 0:36 | |
| *Pírinka* | Book by Kožík, source for *Zelená princezna* | 0:36 | knížky, knížka (misheard as generic "book") |
| *Ani tygři, ani lvi* | Book by Kaplický about animals | 4:16 | |
| *Zlatý máj* | Journal about children's literature, hosted debates on grading | 18:11 | ve zlatém máji (lowercased), missing entirely |
| Autorstop | Author visit program organized by Lukeš | 0:05, 3:57, 6:05 | autobus, autorů stop, autor stop |
| Albatros | Publisher (formerly different name), ran the writing competition | 7:39 | |

## Speaker Diarization — Canonical Attribution

### General Pattern

The recording has three interview speakers plus actors in a dramatized insert:
- **Kožík** — initiates topics, reflections, shorter turns
- **Lukeš** — longer narratives, anecdotes, the primary storyteller
- **Moderátor (Boris Riegler)** — brief transitions and closing
- **Herci (actors)** — dramatized excerpt [13:48–17:53], completely different voices

### Key Diarization Challenges

#### 1. The Dramatized Section [13:48–17:53]

This is the hardest section to diarize correctly. The recording switches from the interview to a **dramatized audio excerpt from *Zákon věrných strážců*** performed by **professional actors** (not Kožík or Lukeš). The voices are completely different from the interview speakers.

Voices in the dramatized section:
- **Dívka** — reads Stáňa's dialogue (female voice, distinctive)
- **Vypravěč** — narrator, also voices Stáňa's inner thoughts and some Romega lines
- **Romega** — the teacher character (male actor)
- **Vašek** — short interjections only (male actor)

ASR engines frequently:
- Attribute actor dialogue to Kožík or Lukeš (wrong — these are different people)
- Assign each character voice a new "speaker" label, fragmenting the section
- Fold short character lines (especially Vašek's interjections at 16:13, 16:52) into adjacent speakers
- Miss the transition boundaries where the dramatization begins and ends
- Merge the Vypravěč's narration with Romega's dialogue

**Canonical attribution:** The entire section from [13:48] to [17:53] is a **dramatized recording with actors**, distinct from the interview speakers. Lukeš at [12:46] *introduces* the play excerpt but is still the live interview speaker. Lukeš resumes at [17:53].

#### 2. Short Interjections and Backchanneling

Throughout the conversation, one speaker makes brief affirmations or reactions while the other is speaking. ASR engines often fold these into the main speaker's text. Known instances:

| Timestamp | Speaker | Interjection | Often misattributed to |
|---|---|---|---|
| [11:42] | Moderátor | "Ano. Ano, to je velmi dobře..." (empathy comment) | Kožík or Lukeš |
| [18:11] | Kožík | "No bylo o tom plno debat ve Zlatém máji." | Merged into Lukeš |
| [18:13] | Lukeš | "Ano, ano." | Merged into Kožík |
| [18:14] | Kožík | "A učitelé psali, dramatizovali to..." | Merged into Lukeš |
| [19:10] | Kožík | "Ano." | Merged into Lukeš |
| [23:17] | Kožík | "Čili jdeme proti Komenskému." | Merged into Lukeš |

#### 3. Speaker Attribution Swaps

Some sections are commonly attributed to the wrong main speaker. The corrected attributions:

| Timestamp | Correct Speaker | Often misattributed to | Key indicator |
|---|---|---|---|
| [0:00] | Kožík | Lukeš | Kožík says "ke mně" (to me) — children came to his flat |
| [0:36] | Kožík | — | Continues: tells apple anecdote (he received the apples) |
| [1:43] | Lukeš | — | Continues from the motto, tells reunion story |
| [10:11] | Kožík | Lukeš | "já jsem vás potřeboval" — Kožík needed Lukeš as collaborator |
| [10:47] | Lukeš | Kožík | "jakou popularitu jste mi připravil" — Lukeš was asked for Romega's autograph |
| [12:04] | Kožík | Moderátor | Kožík asks about modern schooling AND gives his own view |
| [17:53] | Lukeš | Moderátor | Lukeš asks the grading question (not the moderator) |

#### 4. Moderator Appearances

The moderator (Boris Riegler) speaks only at:
- [3:42] — transition with music reference
- [11:42] — brief comment about empathy (often misattributed!)
- [24:00] — closing credits (identifies himself by name)

**Note:** The moderator does NOT speak at [12:04] (that's Kožík) or [17:53] (that's Lukeš).

### Canonical Speaker Sequence

```
[0:00]  Kožík (opening — children came to his flat)
[0:05]  Lukeš (Čapajevova ulice, Autorstop, children's visit)
[0:36]  Kožík (friendship, Zelená princezna/Pírinka, apple anecdote)
[1:43]  Lukeš (motto, reunion after 30 years, Marie Zvoníčková)
[3:42]  Moderátor (transition)
[3:57]  Kožík (Autorstop in Český Dub, broader scale)
[4:16]  Lukeš (visiting authors — Seifert, Majerová, Kaplický, animal chaos)
[6:05]  Kožík (Lukeš's teaching method, children running events, Komenský)
[6:51]  Lukeš (preparation philosophy, children loving books)
[7:39]  Kožík (Romega character origin, Zákon věrných strážců, Albatros)
[8:46]  Lukeš (reaction to being literary character, accepted reluctantly)
[10:11] Kožík (mutual need — "já jsem vás potřeboval", book won first prize)
[10:47] Lukeš (Romega autograph anecdote in Prague)
[11:42] Moderátor (empathy comment)
[12:04] Kožík (question about modern schooling, Czech language concerns)
[12:46] Lukeš (school changed, Drbohlav, experiments, introduces Romega's trial)
[13:48] DRAMATIZED EXCERPT — actors perform scene from Zákon věrných strážců:
        [13:48] Dívka/Stáňa
        [13:51] Vypravěč
        [13:59] Dívka/Stáňa (grading complaints)
        [14:24] Vypravěč
        [14:30] Romega (responds)
        [14:40] Vypravěč (Stáňa's thoughts)
        [14:48] Romega (explains grading philosophy, Zorka)
        [15:30] Vypravěč
        [15:34] Dívka/Stáňa
        [15:36] Vypravěč
        [15:38] Dívka/Stáňa
        [15:39] Vypravěč
        [15:46] Dívka/Stáňa
        [15:49] Vypravěč (long narration)
        [16:13] Vašek (interjection)
        [16:16] Vypravěč
        [16:19] Romega
        [16:25] Vypravěč
        [16:39] Dívka/Stáňa (accusations — Vildové, Čihákovi)
        [16:49] Vypravěč
        [16:52] Vašek (interjection — "známičky")
        [16:55] Vypravěč (long closing narration — Romega's speech about crossroads)
[17:53] Lukeš (grading classification question)
[18:05] Lukeš (svéráz, condemned by authorities)
[18:11] Kožík (interjection — "debaty ve Zlatém máji")
[18:13] Lukeš ("Ano, ano.")
[18:14] Kožík ("A učitelé psali...")
[18:20] Lukeš (grading philosophy — Stáňa in the book vs. practice)
[19:10] Kožík ("Ano.")
[19:11] Lukeš (grading examples, radost z práce, grandson Jakub, romegovská cesta)
[21:00] Lukeš (modern textbook critique — umývadlo word analysis)
[22:24] Kožík (purpose of Czech education, children don't read)
[22:56] Lukeš (teacher as "probírač", no room for emotional education)
[23:17] Kožík ("Čili jdeme proti Komenskému.")
[23:20] Kožík (100+ titles, never did word analysis, loves Czech language)
[24:00] Moderátor (closing credits — identifies Boris Riegler)
```

## Evaluation Metrics

When comparing a new transcription against the reference, evaluate:

### 1. Proper Noun Accuracy

For each name/place/work listed above, check:
- Is it present in the transcript?
- Is it spelled correctly?
- Score: correct / misspelled / missing / generic substitution (e.g., "knížky" for "Pírinky")

Key challenging proper nouns (ranked by difficulty):
1. **Autorstop** — program name, often split or misheard
2. **Pírinka** — commonly replaced with generic "knížka/knížky"
3. **Nechálov** — commonly rendered as Nechvíl or other variants
4. **Čapajevova** — unusual Czech street name, many misspellings
5. **Zlatý máj** — journal name, easily missed in rapid exchange
6. **Vildů, Čihákům** — names inside dramatized section
7. **Boris Riegler** — only mentioned once (closing), easily missed
8. **Drbohlav** — uncommon surname

### 2. Diarization Accuracy

- Are all 3 interview speakers identified (Lukeš, Kožík, Moderátor)?
- Is the dramatized section [13:48–17:53] recognized as different speakers (actors, not the interviewees)?
- Are the dramatized voices distinguished (Dívka/Stáňa, Vypravěč, Romega, Vašek)?
- Are short interjections correctly attributed (not folded into adjacent speaker)?
- Are the speaker attribution swaps (see table above) correct?
- Is the moderator correctly limited to 3 appearances (not over-attributed)?

### 3. Content Completeness

- Are all segments present?
- Is the dramatized section preserved in full (not truncated)?
- Are timestamps reasonably aligned?
- Is the Romega closing speech preserved (dětství = křižovatka)?

## Audio Characteristics

Properties that affect transcription quality:
- **Recording quality:** Archival radio, some background noise/hiss
- **Interview speakers:** Two elderly men (born ~1910s) with period Czech pronunciation, plus a moderator
- **Dramatized section:** Professional actors performing a scene (~4 minutes), completely different voices
- **Speech patterns:** Long, complex sentences; literary language; archival diction
- **Frequent address forms:** "Josefku", "Františku" — diminutive vocatives
- **Duration:** ~24 minutes
- **Language:** Czech
- **Dialect:** Standard Czech with some Bohemian regional features
