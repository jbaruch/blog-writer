---
name: blog-writer
description: >
  Write developer blog posts from video transcripts, meeting notes, or rough ideas.
  Extracts narrative from source material, structures content with hooks and technical sections,
  formats code examples with placeholders, and checks drafts against 39 AI anti-patterns.
  Use this skill whenever the user wants to write a blog post, draft a blog, turn a transcript
  into a blog, work on blog content, or mentions "blog" in the context of content creation.
  Also trigger when the user provides a video transcript and wants written content derived from it,
  or when continuing work on a blog series.
---

# Blog Writer

Process steps in order. Do not skip ahead.

Write developer blog posts for practitioners who build things, break things, and have
opinions about their tools. The voice is the author's own — configured through persona
files that capture their style, rhetorical devices, and personality.

## Step 1 — Resolve the Persona Path

**Persona path:** `~/.claude/blog-writer-persona/`

Throughout this document and all reference files, **`persona/`** is shorthand for this
absolute path. When you see "read `persona/voice.md`", that means read
`~/.claude/blog-writer-persona/voice.md`. Always resolve `persona/` to this absolute path
when reading or writing files.

Proceed immediately to Step 2.

## Step 2 — Probe the Persona State

Ask the script what state the persona is in. Do not inspect the filesystem yourself — the
script decides whether the directory exists and whether the voice profile has content:

```bash
.tessl/plugins/jbaruch/blog-writer/skills/blog-writer/setup-persona-dir.sh --probe
```

It changes nothing and prints
`{"ok": true, "path": ..., "exists": bool, "kind": ..., "target": ..., "voice_ready": bool, "action": "probed"}`.

Route on the result:

| Result | Where to go |
|--------|-------------|
| `exists: true`, `voice_ready: true` | Persona is ready — skip to Step 5 |
| `exists: true`, `voice_ready: false` | Onboarding is incomplete — skip to Step 4 |
| `exists: false` | First-time setup — proceed to Step 3 |

On **exit 1** the canonical path is occupied by a regular file, or is a symlink whose
target is missing. Report the script's stderr diagnostic and ask the author how to resolve
it; do not remove or replace what is there. On **exit 2** report the diagnostic and stop.

## Step 3 — Establish the Persona Directory

Ask the author where to store persona files:

> 1. `~/.claude/blog-writer-persona/` ← **default** (recommended)
> 2. A custom path — I'll create a symlink so the skill always finds them

Then run the same script to establish it. Pass the author's chosen path for option 2, and
no argument for option 1:

```bash
.tessl/plugins/jbaruch/blog-writer/skills/blog-writer/setup-persona-dir.sh [target-path]
```

An `action` of `created` or `linked` means the directory is now in place. An `action` of
`unchanged` means one was already established and the script left it alone rather than
repointing it. The exit-1 and exit-2 handling is the same as Step 2.

Proceed immediately to Step 4.

## Step 4 — Run the Onboarding Flow

Read `skills/blog-writer/references/setup.md` and run the interactive onboarding that
produces the author's voice profile. Do not proceed until it is complete.

Proceed immediately to Step 5.

## Step 5 — Refresh the Anti-Pattern File

Fetch Wikipedia's "Signs of AI writing" article and compare it against
`skills/blog-writer/references/ai-anti-patterns.md`.

```bash
.tessl/plugins/jbaruch/blog-writer/skills/blog-writer/fetch-signs-of-ai-writing.sh
```

The script writes the raw wikitext to a file and prints `{"ok": true, "path": ..., "bytes": ...}`.
Read the file at `.path`.

- **Exit 0** — read the article and continue below.
- **Exit 1** — the fetch failed (network, HTTP error, or a body too short to be the
  article). Proceed with `skills/blog-writer/references/ai-anti-patterns.md` as-is.
- **Exit 2** — a tool or usage error (curl missing, destination not writable). Report the
  script's stderr diagnostic, then proceed with the current anti-pattern file as-is.

If the article contains new patterns, vocabulary, or structural variants not already
covered in the anti-patterns file, update the file to incorporate them. Keep the same
format: pattern number, the tell, symptoms, examples, structural variants (where
applicable), why it's a tell, and instead.

Proceed immediately to Step 6.

## Step 6 — Read the Reference Files

Read these reference files in order:

1. `persona/voice.md` — The author's voice. Read this first, every time. It contains the
   tone, rhetorical devices, and voice-specific examples.
2. `persona/framework.md` — (If it exists and has content) Post-level architecture: opening
   modes, argument shape by post type, density philosophy, first-person rules, closing modes,
   and off-voice moves. **When this file exists and has content, it overrides
   `skills/blog-writer/references/blog-anatomy.md` and the narrative-density doctrine in
   `skills/blog-writer/references/tone-guide.md`.** Read it immediately after `persona/voice.md`, before any
   other reference file.
3. `skills/blog-writer/references/tone-guide.md` — The generic writing framework. Narrative density rules,
   anti-pattern index, tone calibration, TLDR format.
4. `skills/blog-writer/references/ai-anti-patterns.md` — 39 named AI writing patterns to never use. Each has
   symptoms, examples, structural variants, and alternatives. The anti-pattern check in
   Phase 3 and 4 scans the draft against this file.
5. `skills/blog-writer/references/structural-audits.md` — Six discourse-level audits that work above the
   sentence: theme explicitness, structural tidiness, emotion mode, reference specificity,
   reader engagement, and shape convergence. Audits 1, 2, and 6 run on the outline in Phase 2;
   audits 3, 4, and 5 run on the prose in Phase 3 and 4.
6. `skills/blog-writer/references/process.md` — The workflow from transcript to published draft.
7. `skills/blog-writer/references/blog-anatomy.md` — Post shape (TLDR, hook, technical meat, CTA, bio) and
   series handling. Fallback only — `persona/framework.md` overrides it when present.
8. `persona/product.md` — (If it exists and has content) Index of product docs and
   terminology. Do NOT read the whole thing upfront. Scan it to know what's available, then
   fetch only the specific pages relevant to the post's topic during Phase 0.

Proceed immediately to Step 7.

## Step 7 — Run Phase 0: Intake

Read the source material and build the narrative model: who is involved, what was built,
what went wrong, what went right, what was shown on screen, and the jokes and references
that surfaced naturally. Gather product context and previous posts in the series if either
is configured. `skills/blog-writer/references/process.md` Phase 0 has the full procedure.

Gate: the gaps in your understanding are identified. Do not summarize, and do not start
writing.

Proceed immediately to Step 8.

## Step 8 — Run Phase 1: Clarification

Ask the author one question at a time, each with 1-4 concrete options plus an open answer,
your best guess marked. Group questions by narrative, technical, visual, and context gaps.
`skills/blog-writer/references/process.md` Phase 1 has the question format and grouping rules.

Gate: the author confirms the narrative reconstruction is accurate and no ambiguity
remains.

Proceed immediately to Step 9.

## Step 9 — Run Phase 2: Editorial Planning

Lock the main idea, the CTA, and the section outline. `skills/blog-writer/references/process.md` Phase 2 has
the main-idea template and the outline requirements.

Before locking, audit the outline against `skills/blog-writer/references/structural-audits.md`
audits 1, 2, and 6 — theme explicitness, structural tidiness, shape convergence — one audit
at a time. `skills/blog-writer/references/process.md` section 2f has the procedure.

For audit 6, ask the script for the verdict rather than reading the shape history yourself:

```bash
.tessl/plugins/jbaruch/blog-writer/skills/blog-writer/check-shape-convergence.sh \
  <blog-home>/_blog-skill/post-shapes.json "<opening_mode>" "<arc>" "<closing_mode>"
```

Exit 0 is authoritative, including a `can_fire` of false — report it and continue. Exit 1
means the history exists but is unusable: report the script's diagnostic, continue without
audit 6, and do not delete or overwrite the file. Exit 2 is a tool error — report and stop.

If an audit finds no issue, proceed silently.

Gate: the author approves the plan.

Proceed immediately to Step 10.

## Step 10 — Run Phase 3: First Draft

Write the draft to `blog-draft-[slug].md`, insert and confirm placeholders, then run the
anti-pattern, structural, accuracy, and tightening checks.
`skills/blog-writer/references/process.md` Phase 3 has the writing rules, the placeholder
conventions, and the check procedure.

Three rules bind this step and Step 11:

**Persona adherence.** Re-read `persona/voice.md` before every writing action — before this
draft, before every Step 11 revision, and before the anti-pattern rewrite voice check. At
the start of this step and Step 11, confirm you can name at least 3 rhetorical devices from
the profile; if you can't, read it again.

**Anti-pattern check adherence.** Follow the three rules under "Running the check" at the
top of `skills/blog-writer/references/ai-anti-patterns.md` — re-read the file first, run the three-pass
procedure in order, and never invent a pattern the file does not define.

**Structural check adherence.** Run audits 3, 4, and 5 from
`skills/blog-writer/references/structural-audits.md` one at a time, after the anti-pattern
passes. Read `persona/voice.md` first. Where the profile already prescribes the human-side
behavior, the audit is a drift check rather than a new rule. Never apply more than two
interventions from the menu to one post.

> **General rule — if you can't find a required file, ask the author. Don't claim it
> doesn't exist, don't assume its contents, don't skip the step.**

Gate: the draft is delivered to the author.

Proceed immediately to Step 11.

## Step 11 — Run Phase 4: Revision

Edit the draft file on the author's feedback, and re-run the Step 10 checks after every
change. `skills/blog-writer/references/process.md` Phase 4 has the revision procedure.

Gate: the author declares the post done.

Proceed immediately to Step 12.

## Step 12 — Record the Post's Shape

Append the finished post's skeleton to the shape history so the next post's audit 6 has
something to compare against. Do not write the file yourself — the script owns the record
format, the schema stamp, and the refusal cases:

```bash
.tessl/plugins/jbaruch/blog-writer/skills/blog-writer/record-post-shape.sh \
  <blog-home>/_blog-skill/post-shapes.json "<slug>" "<YYYY-MM-DD>" \
  "<opening_mode>" "<arc>" "<closing_mode>" [intervention ...]
```

Record the post as it ended up, not as it was first drafted. Reuse an existing mode string
verbatim when the shape is the same; the comparison is by equality.
`skills/blog-writer/references/post-shapes-schema.md` has the field meanings.

On **exit 1** the history was refused and left untouched — a newer-schema or malformed file
is never overwritten. Report the script's stderr diagnostic to the author and do not work
around it by deleting the file. On **exit 2** report the diagnostic and stop.

Finish here.
