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

Ask **one question at a time**. Each question presents 1-4 concrete options plus an open
answer escape hatch. Mark your best guess with an arrow or "← my guess". The author should
be able to answer with a single number in most cases.

**EVERY question MUST include your best guess as one of the options.** Do not ask open-ended
questions like "what happened here?" or "what was on screen?" Instead, reconstruct what you
think happened from context and present it as the likely option. The author should be able
to answer most questions with a single number. You do the heavy lifting.

**Example format:**

```
At ~12:30 you said "and then this happened." What was on screen at that point?

1. The agent's terminal output showing an error ← my guess
2. The IDE with the config file open
3. The browser showing the dashboard
4. Something else (describe briefly)
```

Wait for the answer, then proceed to the next question. Do not batch questions.

**Question grouping:** Group questions by type under section headers, in this order:
1. **Narrative gaps** (what happened when) — needed to structure the post
2. **Technical gaps** (exact commands, outputs, configurations) — needed for accuracy
3. **Visual gaps** (what was on screen) — needed for placeholders
4. **Context gaps** (references to other work, people, previous posts) — needed for callbacks

Present each group as a headed section (e.g., "### Narrative gaps") with its questions
underneath. This lets the author scan by category instead of reading a flat numbered list.

Keep asking questions one at a time until you can reconstruct the entire narrative without
uncertainty. Tell the author roughly how many questions you expect ("I have about 6 questions
to fill in the gaps") so they know what to expect, and update if the count changes.

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

**Placeholders go in the outline, not just the draft.** For each section, include the
specific placeholders that will appear there, using the standard format with independent
numbering per type:
- `[Screenshot 01: the Grafana panel showing memory usage]`
- `[Code 01: the rate limiter middleware config]`
- `[Link 01: OWASP rate limiting guide]`
- `[Diagram 01: request flow through the middleware stack]`

Screenshot, Code, Link, Fact, and Diagram each have their own counter starting at 01.
The outline is where placeholder planning happens — don't defer it to the draft.

**When to use a diagram vs. a screenshot.** A screenshot of the real system (terminal
output, UI state, a dashboard mid-incident) is almost always more honest than a diagram.
Use a diagram when the concept is structural — architecture, request flow, component
relationships, state transitions — and no single screen capture can show it. Don't
default to a diagram because it looks professional; default to the artifact that proves
the point with the least abstraction.

### 2e: Honest Limitations

If the post involves a product, tool, or approach, ask the author: "What can't this do?
Where does it fall short? What should the reader know before trying it?" Include at least
one limitation or caveat in the outline. Acknowledging what doesn't work builds more trust
than any amount of praise — it shows the author has real experience, not just marketing
talking points. The limitation doesn't need its own section; it can live inside the
technical meat or the broader point as a natural aside.

**Checkpoint:** Author approves the main idea, CTA, and structure outline.

---

## Phase 3: First Draft

**Purpose:** Write the post. Use the approved structure. Follow the tone guide religiously.

**Re-read `persona/voice.md` now.** Actually re-read the file — do not rely on memory from
earlier in the conversation. Confirm you can name at least 3 rhetorical devices from the
profile before writing a single sentence.

### Writing rules:

1. **Start with the opening hook, NOT the TLDR.** Write the TLDR last.

2. **Write sections in narrative order.** The reader should feel like they're on a journey,
   not reading a report.

3. **Every section must earn its place.** If a section doesn't serve the main idea or the
   narrative arc, cut it or fold it into another section.

4. **Code blocks are part of the story.** Don't dump code without context. Set up why the
   reader is about to see this code, show it, then explain what it means.

5. **Sentence and paragraph craft.** Apply the rules from `references/tone-guide.md` section
   "Sentence & Paragraph Craft" while writing — not just during review. Key checks:
   - One new idea per sentence. If you're cramming, split.
   - Generalize before listing unfamiliar items ("three tools: X, Y, Z").
   - Strong subjects (real actors) and strong verbs (real actions). Don't hide actions
     behind state verbs or nominalizations.
   - One topic per paragraph. First sentence = main idea or hook.
   - Every paragraph must advance the reader toward the main idea (point B from Phase 2).

6. **Maintain narrative density in EVERY section, not just the opening.** This is the most
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

7. **Placeholders use INDEPENDENT numbering per type.** There is NO shared counter
   across types. Screenshots start at 01 and increment on their own. Code starts at
   01 and increments on its own. Same for Links, Facts, and Diagrams. WRONG: Screenshot
   01, Code 02, Screenshot 03. RIGHT: Screenshot 01, Code 01, Screenshot 02.
   ```
   [Screenshot 03: the agent re-ingesting 100 files]
   [Code 02: the config file after installing the plugin]
   [Diagram 01: request flow through the rate limiter middleware]
   ```
   The last number of each type = total assets of that type the author needs to prepare.

8. **Aim for 1,500-2,000 words.** 2,000 is a target, not a cliff. A tight 2,200 that
   earns every sentence is better than a padded 1,800. If you're under 1,200, you're
   probably not going deep enough on the technical content. Don't pad to hit a number
   and don't butcher good content to stay under one.

9. **Write the TLDR last.** ALWAYS bullets, 2-4 items. Never prose paragraphs. Each bullet is a standalone
   provocation — something that makes the reader think "wait, really?" The TLDR sells the
   journey, it doesn't summarize the destination.

10. **End with the author bio.** Follow the schema in `persona/bio.md`. The kicker
   must connect to something specific in THIS post. Propose a kicker and confirm with the
   author — don't reuse the same one across posts unless nothing better fits.

11. **The Comparison Trap.** Posts that involve before/after demos, A/B tests, or tool
    comparisons are magnets for patterns #1, #2, #5, and #6. The content naturally involves
    contrasts (old vs. new, broken vs. fixed, input vs. output), and every sentence about
    those contrasts will default to mirrored grammatical structure unless you actively fight
    it. When writing a comparison post:
    - Write the "before" story and the "after" story as separate narratives with different
      sentence structures, not as matched pairs
    - If you catch yourself writing "[thing A] does X, [thing B] does Y" in any form,
      rewrite so only one of them gets a full sentence and the other is folded into a
      different construction
    - The anti-pattern check for comparison posts should include an extra pass specifically
      looking for mirrored clause pairs, even if they don't match the exact examples in the
      anti-pattern file

### Placeholder conventions:

Each placeholder type has its own **independent** numbering sequence, zero-padded.
Counters are **separate per type** — there is NO shared counter. A post can have
Screenshot 10, Code 03, Link 05, Fact 02, and Diagram 03 all at the same time. The
last number of each type tells the author exactly how many of that asset they need
to prepare. WRONG: Screenshot 01, Code 02, Link 03, Screenshot 04. RIGHT: Screenshot
01, Code 01, Link 01, Screenshot 02.

- Screenshots: `[Screenshot 01: description]`, `[Screenshot 02: description]`, ...
- Code to verify: `[Code 01: description] <!-- VERIFY: reconstructed from transcript -->`
- Links to confirm: `[Link 01: description]`
- Facts to check: `[Fact 01: description]`
- Diagrams: `[Diagram 01: description]` followed by a fenced ```d2 block with the
  diagram source, then `<!-- VERIFY: diagram reconstructed from narrative context, confirm architecture -->`

**Example in a draft:** a post might contain, in order: Screenshot 01, Code 01, Screenshot
02, Diagram 01, Screenshot 03, Code 02, Link 01, Screenshot 04. That's 4 screenshots, 2
code blocks, 1 link, 1 diagram — each count is immediately obvious from the last number
in its sequence.

**Prioritize demonstrations over static illustrations.** A screenshot of the product in
action (terminal output mid-run, UI responding to input, a before/after diff) is worth
more than a polished hero image. A video or GIF of the workflow beats a screenshot. When
planning placeholders, prefer assets that show the product *doing something* — the reader
should be able to picture themselves using it. If the source material includes a live demo
moment, that's your strongest placeholder.

**Diagrams earn their place by clarifying complexity prose can't carry.** A diagram is the
right choice when the reader needs to see structure — how components connect, how a request
moves through a stack, how state changes — and the narrative would otherwise have to spell
out relationships the eye grasps instantly. A diagram is the wrong choice when it decorates
rather than clarifies, when a screenshot of the real system would do the same work, or when
the prose already makes the structure obvious. Integrate diagrams like any other asset: set
up what the reader is about to see, show it, then interpret what matters about it.

### Inserting and confirming placeholders:

The author's video transcript will reference things visible on screen that Claude cannot
see. After reconstructing the narrative:

1. Identify every moment where something was shown on screen, code was demonstrated, a link
   was referenced, a fact needs verification, or a concept would benefit from a diagram
   (architecture, flow, system relationships)
2. Insert placeholders using the numbering conventions above — independent sequences per
   type, no shared counter
3. For code placeholders, include best-guess content and flag it:
   `<!-- VERIFY: reconstructed from transcript, confirm actual code -->`
4. For CLI commands, reconstruct from context and flag if uncertain
5. For diagram placeholders, generate D2 source inline in a fenced `d2` block and flag it:
   `<!-- VERIFY: diagram reconstructed from narrative context, confirm architecture -->`

Before the draft is finalized, ask the author to confirm or replace every placeholder.
Cover all five types — Screenshot, Code, Link, Fact, Diagram — and treat the `VERIFY`
comments on reconstructed code and diagrams as open questions rather than resolved content.

### After writing:

Run the anti-pattern check (three passes). Open `references/ai-anti-patterns.md` and scan
the draft:

**Pass 1 — Surface scan:** Read the draft against each of the 39 patterns, looking for
the forms described in the examples and structural variants. For the following patterns,
do a dedicated mechanical sweep instead of relying on contextual reading alone:

- **Contrastive negation (#1):** Do a literal, case-insensitive search for "rather than".
  Every hit that joins two candidates for the same slot is pattern #1 wearing a
  comparative — the negation-then-affirmation is intact, with "rather than" doing the work
  of "not". Case matters: "Rather than X, Y" fronts the construction at the start of a
  sentence, and a case-sensitive search silently misses every one of them. The "Not X. Y."
  form announces itself on a contextual read; this one doesn't, which is exactly why it
  needs the literal search.
- **Fragments (#3, #4):** Find every sentence under six words in the draft and check
  whether 3+ appear consecutively. Surrounding sentences can make fragments feel embedded
  when they're actually standalone. Count periods, not vibes.
- **Parenthetical em-dashes (#7):** Find every paired em-dash (` — X — `) in the draft.
  Each occurrence is a flag regardless of count. Convert to parentheses, restructure the
  sentence, or promote the aside to its own clause. This is a usage check, not a density
  check — a single pair is still a hit, so don't let a passing #8 count clear it.
- **Em-dashes (#8):** Count em-dashes per section. More than two in a section is a flag.
  Don't judge whether each em-dash is "justified" — just count them first. This is the
  density check only; individual paired em-dashes are #7's job above, and a section that
  passes the count can still carry a #7 violation.
- **AI vocabulary (#12):** Scan the draft for the watchlist words (delve, leverage, tapestry,
  landscape, pivotal, crucial, seamless, etc.). One in a post is fine. Two or more is a
  contamination event. Do a literal word search, not a vibe read — these words hide in
  otherwise clean paragraphs.
- **Low burstiness (#14):** Count the word length of each sentence in every paragraph. Flag
  any run of 3+ consecutive sentences within 5 words of each other in length. Uniform
  sentence length is invisible when reading for content but obvious when counting. The fix
  is genuine variety — a mix of short, medium, and long sentences — not merging everything
  into one compound sentence, which just trades seven monotone beats for one run-on.
- **Synonym cycling (#17):** After the surface scan, build a term inventory: list every
  noun phrase used for each core concept in the post. If any concept has more than one
  name, flag it. Cross-section cycling (one term in the intro, a different one in the
  conclusion) is the most common miss.
- **Stacked data points (#32):** Find every sentence or passage with two or more statistics.
  Count how many of those numbers describe the same change. If two or more data points
  make the same point (e.g., a raw number AND a percentage AND a time savings), keep the
  strongest one and cut the rest.
- **Temporal filler (#35):** Scan for the watchlist phrases ("In today's", "Now more than
  ever", "In the age of", "In the current", "As [X] continues to evolve", "In an
  increasingly"). These hide in opening sentences and topic transitions. If the temporal
  phrase can be deleted without changing the meaning, delete it. If the sentence collapses
  without it, the sentence had no content — replace with a specific fact.
- **Corporate cliché phrases (#36):** After the surface scan, check whether any product or
  tool description uses composite corporate phrases ("end-to-end solution", "trusted by
  industry leaders", "passionate team", "drives business value"). Apply the
  interchangeability test: swap the product name for a competitor's. If the sentence still
  works, it's a cliché — replace with a specific fact.
- **Introductory filler words (#10):** Scan for the watchlist words from the "introductory
  filler words" variant in pattern #10: "of course", "naturally", "obviously", "clearly",
  "certainly", "indeed", "in fact", "honestly", "frankly", "additionally", "furthermore",
  "moreover", "first of all", "that said", "that being said", "needless to say". For each
  hit, apply the delete test: remove the word and re-read the sentence. If the meaning is
  unchanged, delete. These accumulate invisibly — one per paragraph is death by a thousand
  cuts.

**Craft sweep (between Pass 1 and Pass 2):** Check the draft against `references/tone-guide.md`
section "Sentence & Paragraph Craft":
- **Overloaded sentences:** Find any sentence that answers 3+ distinct questions (what? how?
  for whom? why?). Split it.
- **Cold lists:** Find enumerations of 3+ unfamiliar items introduced without a category
  label. Add a generalization ("three tools:", "two reasons:").
- **Weak subjects:** Find sentences where the subject is an abstract noun or nominalization
  ("the implementation of," "the presence of," "reforestation"). Check whether a real actor
  is hiding. If so, rewrite with the actor as subject.
- **Nested subordination:** Find sentences with 2+ subordinating conjunctions (which, that,
  because, when, although, if). If they're nested (one inside another), flatten by splitting.
- **Paragraph topics:** Read only the first sentence of each paragraph in sequence. Do they
  tell a coherent story? Flag any that are vague ("Let's consider another aspect...") or
  that don't connect to the preceding paragraph's conclusion.
- **Goal alignment:** For each paragraph, ask "does this advance the reader toward point B?"
  Flag any paragraph that's interesting but tangential.

**Pass 2 — Skeleton scan:** For each pair of adjacent sentences, strip the content and
look at the grammatical skeleton only. Ask: "Do these two sentences have the same shape?"
Subject-verb-object mirroring, parallel prepositional phrases, matching parenthetical
structures — any of these in adjacent sentences is a flag, regardless of whether it matches
a named pattern. Vary the structure of one sentence in the pair. Pass 2 catches patterns
that Pass 1 misses because the vocabulary is different but the grammar is identical.

**Pass 2 must also cover lists and example sequences**, not just adjacent sentence pairs.
When a paragraph contains 3+ examples, case studies, or items in a series, check whether
they share an identical grammatical skeleton across items. Full-sentence examples hiding
inside a dense paragraph are still a pattern if they all follow "[agent did X] — fix went
into [Y]" or any repeated skeleton. Sentence length does not excuse structural repetition.

**Thematic number trap:** When the post's content naturally involves a specific number
(e.g., three tiers, five stages), the LLM will lean into that number harder than a human
would — manufacturing neat "[N] things, [N] results" summaries that announce the pattern
instead of letting the examples show it. Be extra suspicious of numerical summaries that
echo the post's theme. If the content already demonstrates the count, the sentence
announcing it is manufactured symmetry.

**Pass 3 — Soul check:** Step back from the pattern list and ask one holistic question:
"What makes this draft obviously AI-generated?" Read the draft as a skeptical reader would,
not checking against specific patterns but reacting to the overall feel. Look for:
- No opinions anywhere — facts reported but never reacted to
- No uncertainty or mixed feelings — everything is confidently resolved
- No first-person voice when the content warrants it
- No humor, edge, or personality — technically clean but reads like Wikipedia
- Uniform energy — every paragraph has the same emotional temperature
- Press-release tone — sounds like it was written to impress rather than to communicate

A draft can pass all 39 patterns and still read as obviously AI because it has no soul. If
Pass 3 flags the draft as sterile, the fix is not another anti-pattern rewrite — it's going
back to `persona/voice.md` and injecting the author's actual rhetorical devices, opinions,
and attitude into the flat sections.

Rewrite any hits. This is not optional.

**Rewrite audit:** After rewriting any anti-pattern hit, re-read the replacement sentence
in isolation and check it against ALL 39 patterns. Rewrites frequently introduce the same
pattern in a different surface form. This is especially true for:
- #2 (Parallel Binary) — the most likely pattern to survive a rewrite, because describing
  a comparison naturally produces mirrored clauses. If you rewrote a parallel binary and the
  new version still has two clauses about two different things, check the grammatical
  skeleton. If both clauses have the same shape, you just wrote another parallel binary.
- #6 (Self-Answering Fragment) — rewrites often turn "The result? Great." into a longer
  question with a longer answer, but the structure is identical.

Do not consider an anti-pattern fixed until the replacement passes a full 39-pattern scan
on its own.

**Voice check:** After confirming the rewrite is anti-pattern clean, re-read it against
`persona/voice.md`. Does it still sound like the author? If the rewrite is correct but
flat, redo it using the author's rhetorical devices. A mechanically clean sentence that
sounds like a different person is not a fix.

**Proportionality check:** After all rewrites are done, compare the edited draft against
the pre-scan version and ask two questions at the draft level:
- Is the amount of rewriting proportional to the actual slop found? If the scan flagged
  five sentences and forty changed, the editing pass over-reached. Zero tolerance applies
  to the named patterns — not to everything in their vicinity.
- Would the author recognize this draft as their own voice? The scan's failure mode is
  laundering the voice out along with the patterns: every paragraph equally tidy, every
  edge sanded off, distinctive lines rewritten "for consistency." A voice device that
  merely resembles a pattern (the carve-outs in `ai-anti-patterns.md` list the known
  cases) stays. If the answer to this question is no, restore the human sentences the
  scan didn't actually flag.

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
- One data point per beat: if a paragraph has two statistics making the same point ("reduced
  from 45 minutes to 90 seconds, a 97% improvement, saving 6 hours per week"), pick the one
  that hits hardest and cut the rest. The extras are noise.
- Isolate the punchline: the final sentence of a key section should get its own line. If the
  punchline is buried in a paragraph, give it a line break so it lands with weight.
- Black marker test: mentally redact the product or tool name from every product-facing
  paragraph. If the paragraph could describe any competitor's product just as well, it's
  not specific enough. Add concrete details — specific features, real numbers, actual
  behavior — that only apply to this product.
- The goal is to tighten without losing substance. A post that's 1,700 words of meat is
  better than 2,000 words with padding.

**Checkpoint:** Write the first draft to `blog-draft-[slug].md` in the working directory.
Tell the author the file is ready for review. Also display a summary in conversation: word
count, placeholder counts by type, and any open questions or flags.

---

## Phase 4: Revision

**Purpose:** Iterate based on author feedback. This phase loops until the author declares
the post done.

**Re-read `persona/voice.md` now.** Every time you enter Phase 4 or return to it after
author feedback, re-read the file. Long revision cycles are where voice drift happens.

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
- Re-run the anti-pattern check (`references/ai-anti-patterns.md`) after changes — all
  three passes (surface scan + skeleton scan + soul check) for new or rewritten sections.
  Apply the rewrite
  audit rule: every rewrite must pass a full 39-pattern scan on its own before it's
  considered fixed. Then run the voice check: re-read against `persona/voice.md` and
  redo any rewrite that's clean but flat. New writing can introduce new patterns
- Re-run the product accuracy check if any product feature descriptions, commands, or
  terminology were added or changed (only if `persona/product.md` is configured) — use
  WebFetch against docs pages as needed
- If a change conflicts with the tone guide, flag it but defer to the author
- When replacing placeholders with actual content, integrate smoothly — don't just drop
  in an image or code block without adjusting the surrounding prose
- Re-run the tightening pass on any new or rewritten sections — additions tend to
  introduce redundancy with existing content

**The post is done when the author says it's done. Not before.**

**When a post is finished and added to `persona/examples.md`:** The persona has been updated
with new writing. Ask the global voice preference question from `references/setup.md` Step 10.

---

## Phase Summary

| Phase | Gate | Who decides |
|-------|------|-------------|
| 0: Intake | Material read, gaps identified | Automatic |
| 1: Clarification | All gaps resolved | Author confirms |
| 2: Editorial Planning | Main idea + CTA + outline approved | Author approves |
| 3: First Draft | Draft written, anti-patterns checked | Delivered to author |
| 4: Revision | Post meets author's standards | Author declares done |
