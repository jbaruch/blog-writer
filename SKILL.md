---
name: blog-writer
description: >
  Write developer blog posts from video transcripts, meeting notes, or rough ideas.
  Extracts narrative from source material, structures content with hooks and technical sections,
  formats code examples with placeholders, and checks drafts against 37 AI anti-patterns.
  Use this skill whenever the user wants to write a blog post, draft a blog, turn a transcript
  into a blog, work on blog content, or mentions "blog" in the context of content creation.
  Also trigger when the user provides a video transcript and wants written content derived from it,
  or when continuing work on a blog series.
---

# Blog Writer

Write developer blog posts for practitioners who build things, break things, and have
opinions about their tools. The voice is the author's own — configured through persona
files that capture their style, rhetorical devices, and personality.

## Persona Directory

**Persona path:** `~/.claude/blog-writer-persona/`

Throughout this document and all reference files, **`persona/`** is shorthand for this
absolute path. When you see "read `persona/voice.md`", that means read
`~/.claude/blog-writer-persona/voice.md`. Always resolve `persona/` to this absolute path
when reading or writing files.

## Bootstrap

**Before anything else**, check if `~/.claude/blog-writer-persona/` exists (as a real
directory or a symlink).

| State | Action |
|-------|--------|
| Exists and `persona/voice.md` has content | Persona ready — skip to "Before You Start" |
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

## Before You Start

### Anti-pattern freshness check

Before reading the reference files, fetch the Wikipedia article
"Wikipedia:Signs of AI writing" and compare it against `references/ai-anti-patterns.md`.
Wikipedia's list is community-maintained and evolves as LLM writing patterns change.

To fetch: Wikipedia blocks standard WebFetch requests. Use Bash instead:
```
curl -s -L -H "User-Agent: Mozilla/5.0" "https://en.wikipedia.org/w/index.php?title=Wikipedia:Signs_of_AI_writing&action=raw"
```
This returns the raw wikitext. If the output is too large to process inline, pipe it to
a temp file and read it.

If the article contains new patterns, vocabulary, or structural variants not already
covered in the anti-patterns file, update the file to incorporate them. Keep the same
format: pattern number, the tell, symptoms, examples, structural variants (where
applicable), why it's a tell, and instead.

If the fetch fails (network error, page unavailable), proceed with the current
anti-pattern file as-is — it is self-contained and does not depend on the Wikipedia check.

### Reference files

Read these reference files in order:

1. `persona/voice.md` — The author's voice. Read this first, every time. It contains the
   tone, rhetorical devices, and voice-specific examples.
2. `persona/framework.md` — (If it exists) Post-level architecture: opening modes, argument
   shape by post type, density philosophy, first-person rules, closing modes, and off-voice
   moves. **When this file exists, it overrides the "Blog Anatomy" section below and the
   narrative-density doctrine in `references/tone-guide.md`.** Read it immediately after
   `voice.md`, before any other reference file.
3. `references/tone-guide.md` — The generic writing framework. Narrative density rules,
   anti-pattern index, tone calibration, TLDR format.
4. `references/ai-anti-patterns.md` — 37 named AI writing patterns to never use. Each has
   symptoms, examples, structural variants, and alternatives. The anti-pattern check in
   Phase 3 and 4 scans the draft against this file.
5. `references/process.md` — The workflow from transcript to published draft.
6. `persona/product.md` — (If it exists and has content) Index of product docs and
   terminology. Do NOT read the whole thing upfront. Scan it to know what's available, then
   fetch only the specific pages relevant to the post's topic during Phase 0.

## Workflow Overview

The full process is in `references/process.md`. Here are the phases and their gates:

| Phase | What happens | Gate |
|-------|-------------|------|
| 0: Intake | Read source material, WebFetch relevant product docs (if configured), read series tracker | Gaps identified |
| 1: Clarification | One question at a time with 1-4 options (including open answer), your best guess marked — author picks or corrects | Author confirms reconstruction |
| 2: Planning | Lock main idea, CTA, and section outline | Author approves |
| 3: First Draft | Write to `blog-draft-[slug].md`, run anti-pattern + accuracy + tightening checks | Draft delivered |
| 4: Revision | Edit file based on feedback, re-run checks after changes | Author declares done |

Do not skip phases. Do not write prose before Phase 3.

## Persona Adherence

**Rule:** Re-read `persona/voice.md` before every writing action — before the Phase 3 first
draft, before every Phase 4 revision, and before the anti-pattern rewrite voice check.

At the start of Phase 3 and Phase 4, confirm you can name at least 3 rhetorical devices
from the profile; if you can't, read it again.

> **General rule — if you can't find a required file, ask the author. Don't claim it
> doesn't exist, don't assume its contents, don't skip the step.**

## Anti-Pattern Check Adherence

The anti-pattern check is a **defined procedure**, not a vibe check.

1. **Always re-read `references/ai-anti-patterns.md` before running the check.** Use the
   file's definitions — specific patterns, symptoms, examples, structural variants, and
   alternatives — not your general knowledge of AI writing patterns.

2. **Follow the three-pass procedure exactly as written in `references/process.md`.** Pass 1
   is the surface scan against all 37 patterns. Pass 2 is the skeleton scan on adjacent
   sentence pairs. Pass 3 is the soul check — a holistic read for sterile, voiceless writing
   that passes pattern checks but still reads as AI. Then the rewrite audit. Then the voice
   check. In that order. Do not skip passes, do not merge them, do not substitute your own
   method.

3. **Do not invent patterns that aren't in the file.** If something feels "AI-ish" but
   doesn't match any of the 37 defined patterns or their structural variants, leave it
   alone. False positives from improvised rules damage the author's voice more than the
   pattern they're trying to fix.

## Quick Reference: Blog Anatomy

> **Fallback only.** If `persona/framework.md` exists, that file governs post-level
> architecture (opening modes, argument shape, density philosophy, closing modes) and
> overrides this entire section. Read it instead.

Posts are stories about real problems that happen to involve a technology (and optionally a
product). The reader should learn something even if they never touch the author's stack.

A typical post runs 1,500-2,000 words. 2,000 is a target, not a cliff — a tight 2,200
that earns every sentence is better than a padded 1,800. The post follows this general
shape:

**TLDR** — 2-4 bullet points. Sells the "so what" without spoiling the journey. Bullets,
not prose. Each bullet should make the reader think "wait, really?" not "yeah, obvious."
Written last, placed first.

**Opening hook** — A personal story, a public embarrassment, a confession. Never a thesis
statement. Never "In this post, we'll explore..."

**The problem, demonstrated** — Show the failure. Screenshots, code, terminal output. Let the
reader feel the pain before offering the fix.

**The pivot** — What changed. What we tried differently. Why it matters.

**The technical meat** — How it actually works. Code blocks, architecture, real output. This
section earns the reader's trust.

**The broader point** — Zoom out. What does this mean for how we build software? Cultural
references, analogies, and dry observations live here.

**CTA** — Practical, specific, low-friction. Usually: install something, try something, read
the next post. If the author has product context configured, suggest a product-related CTA
and confirm.

**Author bio** — Fixed schema, rotating kicker. The kicker is a dry joke that connects
to the post's content. See the bio format in `persona/bio.md`.

## Series Support

Blog posts often belong to a series. Series state (episode numbers, callbacks, open
threads) is tracked in `_blog-skill/series-tracker.md` in the Blog Home Directory.
Read it at the start of every session; update it when a post is published.

- Maintain consistent title patterns
- Reference previous posts naturally in the opening
- Keep recurring characters consistent (personality, running jokes, callbacks) — see
  `persona/voice.md` for any established characters
- Each post must stand alone — a reader hitting part 2 first should not be lost
- End with a teaser for the next installment when applicable

## Screenshot, Code, and Diagram Handling

The author's video transcript will reference things visible on screen that Claude cannot see.
After reconstructing the narrative:

1. Identify every moment where something was shown on screen, code was demonstrated,
   a link was referenced, a fact needs verification, or a concept would benefit from a
   diagram (architecture, flow, system relationships)
2. Insert placeholders with **INDEPENDENT numbering per type**. Screenshots count
   separately from Code, which counts separately from Links, which counts separately
   from Facts, which count separately from Diagrams. There is NO shared counter. Each
   type starts at 01 and increments within its own sequence only:
   `[Screenshot 01: the agent's terminal output showing it re-ingested 100 files]`
   `[Code 01: config file dependency block after plugin install]`
   `[Screenshot 02: the app UI showing outdated information]`
   `[Link 01: plugin page on the registry]`
   `[Screenshot 03: terminal showing install command]`
   `[Fact 01: "25% of Y Combinator startups" claim — find source]`
   `[Diagram 01: architecture showing plugin registry flow]`
3. For code placeholders, include best-guess content and flag:
   `<!-- VERIFY: reconstructed from transcript, confirm actual code -->`
4. For CLI commands, reconstruct from context and flag if uncertain
5. For diagram placeholders, generate D2 source inline in a fenced `d2` block and flag:
   `<!-- VERIFY: diagram reconstructed from narrative context, confirm architecture -->`
   Diagrams earn their place when they clarify complexity that prose can't convey
   (multi-step flows, component relationships, state transitions). If a single screenshot
   of the real system would be more honest and more specific, use a screenshot instead.
6. Ask the author to confirm or replace all placeholders before finalizing
