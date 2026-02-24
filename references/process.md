# Blog Writing Process

This document defines the step-by-step workflow from raw input (usually a video transcript)
to a finished blog post draft. Follow these phases in order. Do not skip phases. Do not
start writing prose until Phase 3.

## Blog Home Directory

The blog home directory is set by the author at session start. All blog artifacts live there.

**Directory structure:**
- `_blog-skill/` — Skill-wide persistent storage (series trackers, learned preferences,
  cross-post memory). Survives across all posts and sessions.
  - `series-tracker.md` — Series state, episode numbers, callbacks, open threads
- Per-post working directories as organized by the author

**Per-post files** (research banks, drafts) go in the post's working directory. The
working directory is usually set by the author before starting.

**At the start of every blog session**, read `_blog-skill/series-tracker.md` (if it exists)
to know the current state of all series. At the end of every session where a post is
published or substantially completed, update it.

## Research Memory Bank

Maintain a structured notes file throughout the process. This serves two purposes: it's a
working document that keeps research organized across phases, and it persists across sessions
if the conversation is resumed later.

The slug is provided by the author at the start of the conversation (see Phase 0). Examples:
`deep-dive-ep4`, `never-trust-llm`, `intent-chain`.

**File:** `blog-research-[slug].md` in the current working directory.

Write to it at phase checkpoints and whenever significant new information arrives
(clarification answers, author feedback, editorial decisions).

**Structure:**
```markdown
# Research Memory Bank: [working title]
Created: [date]
Last updated: [date] — [phase]

## Source Material Summary
[Phase 0: key narrative beats, people involved, what was shown, failures, successes]

## Product Context
[Phase 0: relevant product features, verified claims from docs, CLI commands, terminology.
Skip this section if no product context is configured.]

## Clarification Log
[Phase 1: numbered Q&A — questions asked, answers received, all rounds]

## Editorial Plan
[Phase 2: main idea sentence, CTA, series context, approved structure outline]

## Draft Notes
[Phase 3+: any decisions made during writing, author feedback, revision notes]
```

**Rules:**
- Update sections as new information arrives — don't just append, keep each section current.
- Before starting Phase 3, re-read the entire memory bank to confirm you have everything.
- The memory bank is a working document, not a deliverable. It doesn't need to be pretty.

---

## Phase 0: Intake

**First thing:** Ask the author for a short slug (kebab-case, 2-4 words) to identify this
post. Examples: `deep-dive-ep4`, `never-trust-llm`, `intent-chain`. Use this slug to name
the research memory bank and draft files. Do not proceed until you have the slug.

Then check for an existing `blog-research-[slug].md` in the working directory. If found,
read it and tell the author where you left off. If not found, create a new one.

**Input:** The author provides source material. This is usually a video transcript but could
also be meeting notes, a rough outline, a conference talk transcript, or a previous blog
post to extend.

**What to do:**

Read the entire source material. Build a mental model of the narrative. Identify:
- Who is involved (speakers, collaborators, quoted individuals)
- What was built or demonstrated
- What went wrong (there's almost always a failure story)
- What went right (the fix, the alternative approach, the insight)
- What was shown on screen that the transcript references but you can't see
- Jokes, asides, and cultural references that surfaced naturally

**Gather product context (if configured):** If `persona/product.md` exists and contains
content, list every product feature, command, or concept mentioned in the source material.
Consult `persona/product.md` and use WebFetch to pull the relevant docs pages directly —
don't ask the author to provide them. Fetch as many pages as the post needs to be accurate
(the 1M context window can handle it). If the source material references a feature that
doesn't appear in any docs page, flag it for the author in Phase 1. If no product context
is configured, skip this step.

**Fetch previous posts in the series:** If this post belongs to a series, use WebFetch to
read the previously published posts (URLs are in `persona/examples.md`). This ensures
continuity of callbacks, running jokes, character dynamics, and narrative arc. You have the
context budget for it — use it.

**Do NOT start writing. Do NOT summarize. Move to Phase 1.**

---

## Phase 1: Clarification

**Purpose:** Fill every gap in your understanding. The transcript is a lossy compression of
a video. Things that were obvious on screen are invisible in text. Things that were said
casually might be technically important.

**How to do it:**

Ask clarification questions. Ask as many as you need. **Always number them** so the author
can reply efficiently with "1: yes, 2: it was actually React, 3: yes" etc.

**EVERY question MUST include your best guess.** Do not ask open-ended questions like "what
happened here?" or "what was on screen?" Instead, reconstruct what you think happened from
context and ask the author to confirm or correct. The author should be able to answer most
questions with "yes", a short correction, or a one-liner. You do the heavy lifting.

**Example format:**

```
1. At ~12:30 you said "and then this happened." I'm guessing the screen showed the agent's
   terminal output with an error — is that right? If so, what was the error?
2. The transcript mentions installing a package. Was the command `npm install example-lib`?
3. You referenced "the last time we tried this." Is that from a previous post in the series?
4. It sounds like your collaborator pushed back here about the time spent. Was this the
   "we spent an hour and still haven't implemented anything" moment, or a different objection?
```

If you catch yourself writing a question without a guess, stop and add one. Even a wrong
guess is better than an open-ended question — it gives the author something to react to.

Group questions by type for easier scanning:

- **Narrative gaps** (what happened when)
- **Technical gaps** (exact commands, outputs, configurations)
- **Visual gaps** (what was on screen)
- **Context gaps** (references to other work, people, previous posts)

Keep asking rounds until you can reconstruct the entire narrative without uncertainty.
Multiple rounds are fine — just keep numbering sequentially across rounds.

**Checkpoint:** The author confirms the narrative reconstruction is accurate. No ambiguity
remains.

---

## Phase 2: Editorial Planning

**Purpose:** A transcript wanders. A blog post has a spine. Determine the one thing this
post is about, and everything else is either supporting evidence or cut material.

### 2a: Main Idea

Answer this in one sentence: "This post shows that [specific claim], demonstrated by
[specific evidence]."

If you can't fill that template, the post isn't focused enough. Propose a main idea and
confirm with the author.

### 2b: CTA

What should the reader do after reading this? Options typically include:
- Install/try a tool or library (with exact commands)
- Read the next post in a series
- Watch the video/stream
- Check out a specific repository or resource

If the author has product context configured, suggest a product-related CTA and confirm.
Otherwise, suggest a general CTA appropriate to the content.

### 2c: Series Context

If this is part of a series, read `_blog-skill/series-tracker.md` (in the Blog Home
Directory) for the full state: title patterns, previous episodes, established callbacks,
open threads, and teasers. Then confirm with the author:
- Which callbacks or running jokes should continue in this post?
- What's the teaser for the next installment?
- Any new recurring elements to establish?

### 2d: Structure Outline

Propose section headers and a 1-2 sentence description of each section's purpose. Confirm
with the author before proceeding.

Include proposed placeholder locations in the outline — each type numbered independently:
"[Screenshot 01: ...]", "[Screenshot 02: ...]", "[Code 01: ...]", "[Link 01: ...]", etc.

**Checkpoint:** Author approves the main idea, CTA, and structure outline.

---

## Phase 3: First Draft

**Purpose:** Write the post. Use the approved structure. Follow the tone guide religiously.
Read `persona/voice.md` to stay in the author's voice throughout.

### Writing rules:

1. **Start with the opening hook, NOT the TLDR.** Write the TLDR last.

2. **Write sections in narrative order.** The reader should feel like they're on a journey,
   not reading a report.

3. **Every section must earn its place.** If a section doesn't serve the main idea or the
   narrative arc, cut it or fold it into another section.

4. **Code blocks are part of the story.** Don't dump code without context. Set up why the
   reader is about to see this code, show it, then explain what it means.

5. **Maintain narrative density in EVERY section, not just the opening.** This is the most
   common quality failure. The opening hook always has personality because writers focus
   there. But by mid-post, the voice drifts toward report/analyst style. Watch for:
   - Passive summaries replacing specific moments ("Implementation proceeded" vs "I hit
     enter and the agent scaffolded 62 files in twelve seconds")
   - Missing human reactions (what did you say? what did your collaborator say? what did
     you feel?)
   - Abstract nouns replacing lived experience ("The architectural convergence" vs "Three
     companies shipped the same idea within a month")
   - Paragraphs that could be rewritten as bullet points without losing anything
   Re-read `references/tone-guide.md` section "Narrative Density: Show, Don't Summarize"
   for the full diagnostic.

6. **Placeholders use INDEPENDENT numbering per type.** There is NO shared counter
   across types. Screenshots start at 01 and increment on their own. Code starts at
   01 and increments on its own. Same for Links and Facts. WRONG: Screenshot 01,
   Code 02, Screenshot 03. RIGHT: Screenshot 01, Code 01, Screenshot 02.
   ```
   [Screenshot 03: the agent re-ingesting 100 files]
   [Code 02: the config file after installing the plugin]
   ```
   The last number of each type = total assets of that type the author needs to prepare.

7. **Aim for 1,500-2,000 words.** 2,000 is a target, not a cliff. A tight 2,200 that
   earns every sentence is better than a padded 1,800. If you're under 1,200, you're
   probably not going deep enough on the technical content. Don't pad to hit a number
   and don't butcher good content to stay under one.

8. **Write the TLDR last.** ALWAYS bullets, 2-4 items. Never prose paragraphs. Each bullet is a standalone
   provocation — something that makes the reader think "wait, really?" The TLDR sells the
   journey, it doesn't summarize the destination.

9. **End with the author bio.** Follow the schema in `persona/bio.md`. The kicker
   must connect to something specific in THIS post. Propose a kicker and confirm with the
   author — don't reuse the same one across posts unless nothing better fits.

### Placeholder conventions:

Each placeholder type has its own **independent** numbering sequence, zero-padded.
Counters are **separate per type** — there is NO shared counter. A post can have
Screenshot 10, Code 03, Link 05, and Fact 02 all at the same time. The last number
of each type tells the author exactly how many of that asset they need to prepare.
WRONG: Screenshot 01, Code 02, Link 03, Screenshot 04. RIGHT: Screenshot 01, Code 01,
Link 01, Screenshot 02.

- Screenshots: `[Screenshot 01: description]`, `[Screenshot 02: description]`, ...
- Code to verify: `[Code 01: description] <!-- VERIFY: reconstructed from transcript -->`
- Links to confirm: `[Link 01: description]`
- Facts to check: `[Fact 01: description]`

**Example in a draft:** a post might contain, in order: Screenshot 01, Code 01, Screenshot
02, Screenshot 03, Code 02, Link 01, Screenshot 04. That's 4 screenshots, 2 code blocks,
1 link — each count is immediately obvious from the last number in its sequence.

### After writing:

Run the anti-pattern check. Open `references/ai-anti-patterns.md` and scan the draft for
all 18 patterns. Rewrite any hits. This is not optional.

Run the product accuracy check (if configured). If `persona/product.md` exists and contains
content, verify every claim the draft makes about the product — feature names, CLI commands,
behavior, terminology — against the docs pages fetched in Phase 0. If the draft references
something you didn't fetch, fetch that specific page from `persona/product.md` now. Do not
guess. Flag anything that contradicts the docs or isn't covered by them. If no product
context is configured, skip this check.

Run the tightening pass. Re-read the draft sentence by sentence with fresh eyes:
- For every sentence, ask: "would the reader miss this if it vanished?" If not, cut it.
- Identify redundancies — two sentences making the same point in different words. Keep the
  stronger one.
- Kill bloated transitions: "Now that we've seen X, let's look at Y" can almost always be
  replaced by just starting Y.
- Check for hedging filler that crept in: "basically," "essentially," "in order to."
- The goal is to tighten without losing substance. A post that's 1,700 words of meat is
  better than 2,000 words with padding.

**Checkpoint:** Write the first draft to `blog-draft-[slug].md` in the working directory.
Tell the author the file is ready for review. Also display a summary in conversation: word
count, placeholder counts by type, and any open questions or flags.

---

## Phase 4: Revision

**Purpose:** Iterate based on author feedback. This phase loops until the author declares
the post done.

**Draft is a file.** All revisions happen in `blog-draft-[slug].md` using the Edit tool.
This gives the author a persistent artifact they can review in their editor, diff against
previous versions, and eventually copy to the CMS. Don't rewrite the entire draft in
conversation — edit the file surgically.

**What to expect:**
- Tone adjustments ("this section sounds too corporate")
- Technical corrections ("that's not how the API actually works")
- Structural changes ("move this section before that one")
- Cuts ("we don't need this paragraph")
- Additions ("add a section about X")
- Screenshot and code placeholder updates

**How to handle feedback:**
- Apply changes to the draft file using Edit
- Re-run the anti-pattern check (`references/ai-anti-patterns.md`) after changes (new
  writing can introduce new patterns)
- Re-run the product accuracy check if any product feature descriptions, commands, or
  terminology were added or changed (only if `persona/product.md` is configured) — use
  WebFetch against docs pages as needed
- If a change conflicts with the tone guide, flag it but defer to the author
- When replacing placeholders with actual content, integrate smoothly — don't just drop
  in an image or code block without adjusting the surrounding prose
- Re-run the tightening pass on any new or rewritten sections — additions tend to
  introduce redundancy with existing content

**The post is done when the author says it's done. Not before.**

---

## Phase Summary

| Phase | Gate | Who decides |
|-------|------|-------------|
| 0: Intake | Material read, gaps identified | Automatic |
| 1: Clarification | All gaps resolved | Author confirms |
| 2: Editorial Planning | Main idea + CTA + outline approved | Author approves |
| 3: First Draft | Draft written, anti-patterns checked | Delivered to author |
| 4: Revision | Post meets author's standards | Author declares done |
