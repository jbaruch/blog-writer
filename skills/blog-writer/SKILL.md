---
name: blog-writer
description: >
  Write developer blog posts from video transcripts, meeting notes, or rough ideas.
  Extracts narrative from source material, structures content with hooks and technical sections,
  formats code examples with placeholders, and checks drafts against 38 AI anti-patterns.
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

## Step 2 — Bootstrap the Persona Directory

Check if `~/.claude/blog-writer-persona/` exists (as a real directory or a symlink).

| State | Action |
|-------|--------|
| Exists and `persona/voice.md` has content | Persona ready — proceed to Step 3 |
| Exists but `persona/voice.md` is empty or missing | Read `references/setup.md` and run onboarding; do not proceed until complete |
| Directory doesn't exist | First-time setup — see below |

**First-time setup:** Ask the author where to store persona files:

> 1. `~/.claude/blog-writer-persona/` ← **default** (recommended)
> 2. A custom path — I'll create a symlink so the skill always finds them

- **Option 1:** Create `~/.claude/blog-writer-persona/`.
- **Option 2:** Ask for the full path, create it, then run:
  ```bash
  ln -s /their/chosen/path ~/.claude/blog-writer-persona
  ```

Then read `references/setup.md` and run the interactive onboarding flow.

Proceed immediately to Step 3 once the persona is ready.

## Step 3 — Refresh the Anti-Pattern File

Fetch Wikipedia's "Signs of AI writing" article and compare it against
`references/ai-anti-patterns.md`. Wikipedia's list is community-maintained and evolves as
LLM writing patterns change.

```bash
.tessl/plugins/jbaruch/blog-writer/skills/blog-writer/fetch-signs-of-ai-writing.sh
```

The script writes the raw wikitext to a file and prints `{"ok": true, "path": ..., "bytes": ...}`.
Read the file at `.path`.

- **Exit 0** — read the article and continue below.
- **Exit 1** — the fetch failed (network, HTTP error, or a body too short to be the
  article). Proceed with `references/ai-anti-patterns.md` as-is; it is self-contained and
  does not depend on this check.
- **Exit 2** — a tool or usage error (curl missing, destination not writable). Report the
  script's stderr diagnostic, then proceed with the current anti-pattern file as-is.

If the article contains new patterns, vocabulary, or structural variants not already
covered in the anti-patterns file, update the file to incorporate them. Keep the same
format: pattern number, the tell, symptoms, examples, structural variants (where
applicable), why it's a tell, and instead.

Proceed immediately to Step 4.

## Step 4 — Read the Reference Files

Read these reference files in order:

1. `persona/voice.md` — The author's voice. Read this first, every time. It contains the
   tone, rhetorical devices, and voice-specific examples.
2. `persona/framework.md` — (If it exists and has content) Post-level architecture: opening
   modes, argument shape by post type, density philosophy, first-person rules, closing modes,
   and off-voice moves. **When this file exists and has content, it overrides
   `references/blog-anatomy.md` and the narrative-density doctrine in
   `references/tone-guide.md`.** Read it immediately after `persona/voice.md`, before any
   other reference file.
3. `references/tone-guide.md` — The generic writing framework. Narrative density rules,
   anti-pattern index, tone calibration, TLDR format.
4. `references/ai-anti-patterns.md` — 38 named AI writing patterns to never use. Each has
   symptoms, examples, structural variants, and alternatives. The anti-pattern check in
   Phase 3 and 4 scans the draft against this file.
5. `references/process.md` — The workflow from transcript to published draft.
6. `references/blog-anatomy.md` — Post shape (TLDR, hook, technical meat, CTA, bio) and
   series handling. Fallback only — `persona/framework.md` overrides it when present.
7. `persona/product.md` — (If it exists and has content) Index of product docs and
   terminology. Do NOT read the whole thing upfront. Scan it to know what's available, then
   fetch only the specific pages relevant to the post's topic during Phase 0.

Proceed immediately to Step 5.

## Step 5 — Run Phase 0: Intake

Read the source material and build the narrative model: who is involved, what was built,
what went wrong, what went right, what was shown on screen, and the jokes and references
that surfaced naturally. Gather product context and previous posts in the series if either
is configured. `references/process.md` Phase 0 has the full procedure.

Gate: the gaps in your understanding are identified. Do not summarize, and do not start
writing.

Proceed immediately to Step 6.

## Step 6 — Run Phase 1: Clarification

Ask the author one question at a time, each with 1-4 concrete options plus an open answer,
your best guess marked. Group questions by narrative, technical, visual, and context gaps.
`references/process.md` Phase 1 has the question format and grouping rules.

Gate: the author confirms the narrative reconstruction is accurate and no ambiguity
remains.

Proceed immediately to Step 7.

## Step 7 — Run Phase 2: Editorial Planning

Lock the main idea, the CTA, and the section outline. `references/process.md` Phase 2 has
the main-idea template and the outline requirements.

Gate: the author approves the plan.

Proceed immediately to Step 8.

## Step 8 — Run Phase 3: First Draft

Write the draft to `blog-draft-[slug].md`, insert and confirm placeholders, then run the
anti-pattern, accuracy, and tightening checks. `references/process.md` Phase 3 has the
writing rules, the placeholder conventions, and the check procedure.

Two rules bind this step and Step 9:

**Persona adherence.** Re-read `persona/voice.md` before every writing action — before this
draft, before every Step 9 revision, and before the anti-pattern rewrite voice check. At
the start of this step and Step 9, confirm you can name at least 3 rhetorical devices from
the profile; if you can't, read it again.

**Anti-pattern check adherence.** The anti-pattern check is a defined procedure, not a vibe
check.

1. **Always re-read `references/ai-anti-patterns.md` before running the check.** Use the
   file's definitions — specific patterns, symptoms, examples, structural variants, and
   alternatives — not your general knowledge of AI writing patterns.
2. **Follow the three-pass procedure exactly as written in `references/process.md`.** Pass 1
   is the surface scan against all 38 patterns. Pass 2 is the skeleton scan on adjacent
   sentence pairs. Pass 3 is the soul check — a holistic read for sterile, voiceless writing
   that passes pattern checks but still reads as AI. Then the rewrite audit. Then the voice
   check. Then the proportionality check — was the amount of rewriting proportional to the
   slop found, and would the author still recognize the draft as their own voice. In that
   order. Do not skip passes, do not merge them, do not substitute your own method.
3. **Do not invent patterns that aren't in the file.** If something feels "AI-ish" but
   doesn't match any of the 38 defined patterns or their structural variants, leave it
   alone. False positives from improvised rules damage the author's voice more than the
   pattern they're trying to fix.

> **General rule — if you can't find a required file, ask the author. Don't claim it
> doesn't exist, don't assume its contents, don't skip the step.**

Gate: the draft is delivered to the author.

Proceed immediately to Step 9.

## Step 9 — Run Phase 4: Revision

Edit the draft file on the author's feedback, and re-run the Step 8 checks after every
change. `references/process.md` Phase 4 has the revision procedure.

Finish here when the author declares the post done.
