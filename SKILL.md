---
name: blog-writer
description: >
  Write developer blog posts from video transcripts, meeting notes, or rough ideas.
  Extracts narrative from source material, structures content with hooks and technical sections,
  formats code examples with placeholders, and checks drafts against 24 AI anti-patterns.
  Use this skill whenever the user wants to write a blog post, draft a blog, turn a transcript
  into a blog, work on blog content, or mentions "blog" in the context of content creation.
  Also trigger when the user provides a video transcript and wants written content derived from it,
  or when continuing work on a blog series.
---

# Blog Writer

Write developer blog posts for practitioners who build things, break things, and have
opinions about their tools. The voice is the author's own — configured through persona
files that capture their style, rhetorical devices, and personality.

## Bootstrap: Persona Location

**Before anything else**, check if the persona folder path is known. If this is the first
session or the persona folder hasn't been located yet, ask:

> Where is your persona folder? This is where your voice profile, bio, and examples live.
>
> 1. `persona/` (in this project directory) ← **my guess**
> 2. A different path in this project
> 3. A path outside this project
> 4. I don't have one yet — let's create it

Wait for the answer before proceeding. If the author picks option 4, create `persona/` in
the project root and continue to the setup flow.

## Persona Check

Check if `persona/voice.md` exists and contains content (using the located persona path).

- **If `persona/voice.md` is empty or missing:** Read `references/setup.md` and run the
  interactive onboarding flow. Do not proceed with blog writing until the persona is set up.
- **If `persona/voice.md` has content:** Proceed with the normal blog writing flow below.

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
2. `references/tone-guide.md` — The generic writing framework. Narrative density rules,
   anti-pattern index, tone calibration, TLDR format.
3. `references/ai-anti-patterns.md` — 24 named AI writing patterns to never use. Each has
   symptoms, examples, structural variants, and alternatives. The anti-pattern check in
   Phase 3 and 4 scans the draft against this file.
4. `references/process.md` — The workflow from transcript to published draft.
5. `persona/product.md` — (If it exists and has content) Index of product docs and
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

## Persona Adherence (Periodic Re-anchor)

Long conversations lose context. The persona is not optional — it defines the entire voice
of the output. To prevent drift:

1. **Re-read `persona/voice.md` before every writing action** — before Phase 3 first draft,
   before every revision in Phase 4, and before the anti-pattern rewrite voice check. Not
   "remember what it said" — actually re-read the file.

2. **If you think the persona is empty, missing, or unfamiliar — ASK, don't assume.** The
   persona was set up earlier in the session or in a previous session. If you can't find it,
   ask the author:
   > I can't locate the persona files. Where is the persona folder?
   >
   > 1. `persona/` (in this project directory)
   > 2. A different path (tell me)
   >
   Never claim the persona doesn't exist or that you don't know what it is. It exists. You
   may have lost track of the path — ask.

3. **Voice spot-check at phase transitions.** At the start of Phase 3 and Phase 4, re-read
   `persona/voice.md` and confirm to yourself (not to the author) that you can name at least
   3 rhetorical devices from the profile. If you can't, you haven't internalized it — read
   it again.

## Quick Reference: Blog Anatomy

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

## Screenshot and Code Handling

The author's video transcript will reference things visible on screen that Claude cannot see.
After reconstructing the narrative:

1. Identify every moment where something was shown on screen, code was demonstrated,
   a link was referenced, or a fact needs verification
2. Insert placeholders with **INDEPENDENT numbering per type**. Screenshots count
   separately from Code, which counts separately from Links, which counts separately
   from Facts. There is NO shared counter. Each type starts at 01 and increments
   within its own sequence only:
   `[Screenshot 01: the agent's terminal output showing it re-ingested 100 files]`
   `[Code 01: config file dependency block after plugin install]`
   `[Screenshot 02: the app UI showing outdated information]`
   `[Link 01: plugin page on the registry]`
   `[Screenshot 03: terminal showing install command]`
   `[Fact 01: "25% of Y Combinator startups" claim — find source]`
   In this example: 3 screenshots, 1 code block, 1 link, 1 fact — each count is
   the last number in its sequence. WRONG: Screenshot 01, Code 02, Link 03.
   RIGHT: Screenshot 01, Code 01, Link 01.
3. For code placeholders, include best-guess content and flag:
   `<!-- VERIFY: reconstructed from transcript, confirm actual code -->`
4. For CLI commands, reconstruct from context and flag if uncertain
5. Ask the author to confirm or replace all placeholders before finalizing
