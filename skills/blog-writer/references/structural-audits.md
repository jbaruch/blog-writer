# Structural Audits

The 39 anti-patterns in `references/ai-anti-patterns.md` work at the sentence and section
level. This file works at the level above: the shape of the whole post. A draft can pass
every one of the 39 and still be identifiable as machine-written from its skeleton alone.

## Why this layer exists

The StoryScope study (Russell, Rajendhran, Pham, Iyyer, Wieting — University of Maryland
and Google DeepMind, 2026, arXiv:2604.03136) classified 61,608 stories from human authors
and five LLMs using **only** discourse-level narrative features, with every style feature
withheld. It reached 93.2% macro-F1. Then it ran the AI text through a professional
span-level rewriting framework — the equivalent of a very good surface editing pass — and
detection fell by 1.6 points.

Surface editing is not the durable half. That does not make the 39 patterns less
important; they are what makes a post readable. It means they are not sufficient, and the
part they miss is the part that survives editing.

**The honest limit:** StoryScope studied roughly 5,000-word fiction. Applying it to short
technical nonfiction is an inference, not a finding. The study's own authors say so. The
audits that transfer most cleanly are 1, 3, 4, and 6.

## The convergence trap — read this before applying anything

The study's deepest result is not any single feature. It is that all five models occupy
one tight region of structural space while human writing is dispersed across a much wider
one. 24.7% of human stories land in the corpus's rarest 10%; only 7.1% of AI stories do.

**Rarity is the signal.** Which means a checklist applied uniformly produces a new
detectable cluster. If every post from here on opens mid-scene, names three feelings, and
ends on an unresolved question, that is not humanity — it is a different machine.

So: **pick one or two structural interventions per post, vary them across posts, and be
able to say why this post got this shape.** Never run the whole menu. An audit that finds
nothing is a valid result.

## Calibrate against the persona, not a generic human

Every rate below compares "humans in general" to "AI in general." The author is not humans
in general.

Before applying any audit, read `persona/voice.md`. If the profile already prescribes the
human-side behavior, **the audit is a drift check, not a new rule** — the question becomes
"did this draft wander off the profile," not "should the author start doing this."

For a persona whose declared devices include parenthetical asides, audit 5 is already
satisfied by the voice; enforcing it again would double the dose. For a persona built on
named cultural references, audit 4 is already satisfied. Check the profile first, then
decide whether the audit has anything to say.

Where `persona/framework.md` exists and has content, it governs post architecture and
overrides `references/blog-anatomy.md`. Audits 2 and 6 read the framework's declared
opening and closing modes as the menu to vary across, rather than the generic one below.

## Run one audit at a time

The study's own pipeline found 95.4% of the features it was looking for when it checked
one narrative dimension per pass, against 68.4% for a single combined pass. Do not read
the draft once holding all six in mind. Six reads, one lens each.

## Two altitudes, two moments

Structural problems are cheap to fix in an outline and expensive to fix in a finished
draft. The audits split accordingly:

| Audit | Level | When it runs |
|---|---|---|
| 1. Theme explicitness | Outline | Phase 2, on the section plan |
| 2. Structural tidiness | Outline | Phase 2, on the section plan |
| 6. Shape convergence | Outline | Phase 2, before the plan is locked |
| 3. Emotion mode | Prose | Phase 3/4, with the anti-pattern check |
| 4. Reference specificity | Prose | Phase 3/4, with the anti-pattern check |
| 5. Reader engagement | Prose | Phase 3/4, with the anti-pattern check |

The study found that comparing raw prose surfaces style features while comparing
structured outlines surfaces structural ones — only 6 of the top 20 features overlapped
between the two methods. **Audit the outline, not the prose.** Reading a finished draft
for structure mostly rediscovers its sentences.

---

## Audit 1 — Theme explicitness

**The gap:** the narrator explains the theme 77% of the time in AI text against 52% for
humans. Themes are moralized harder, and every example is made to serve the thesis.

**In a dev blog post:** the takeaway sentence at the end of each section. The thesis
restated in the TLDR, the intro, every section close, and the conclusion. Every code
example followed by a paragraph explaining what it demonstrated.

**Sentence-level form:** patterns #29 (restating the proven point) and #38 (fake-profound
kickers) already catch the individual sentences. This audit is the document-level version:
counting how many times the post states its point, across the whole outline.

**The fix:** state the point once, where it lands hardest. Delete every restatement. Leave
at least one example uninterpreted — the reader can do the work, and letting them is the
signal.

**Outline check:** mark every place in the section plan where the main idea gets stated. If
the count is above one, cut down to one and choose which.

## Audit 2 — Structural tidiness

**The gap:** AI writes single-track. No subplots, 79% against 57%. Resolution by
protagonist choice, 69% against 46%. Resolution by internal understanding — "and then I
realized" — 47% against 27%. Humans digress, loop, and leave things open.

**In a dev blog post:** the unbroken causal chain from problem to fix to lesson. Every
thread tied off. Nothing raised that isn't resolved. The post ends knowing more than it
started and says so.

**The fix — pick at most one:**
- One tangent that parallels the theme without serving it, not tied back explicitly
- One question raised and openly not answered ("I still don't know why the buffer was
  sized that way, and the person who set it left in 2023")
- Stop before the resolution

**Genre caution:** a technical post has obligations fiction does not. If the reader came
for a fix, they get the fix. The target is the *epilogue* — the tidy wrap-up after the
fix already landed — not the fix itself. A post that withholds its solution to seem human
is a worse post.

**Outline check:** does every thread in the plan close? Is there exactly one causal spine
with no digression? If yes to both, that is the tell.

## Audit 3 — Emotion mode

**The gap:** the single largest in the corpus. AI performs emotion through the body 81% of
the time against 38% for humans; humans name the feeling outright 29% against 8%.

**This is pattern #39** in `references/ai-anti-patterns.md`, which carries the full
treatment: symptoms, variants, the fix, and the carve-out protecting factual physical
detail. Do not restate it here — run the pattern.

**What this audit adds beyond the pattern:** a document-level question. Across the whole
post, how many emotional beats are performed and how many are named? A draft can dodge
every individual #39 hit and still never once say what the author felt.

## Audit 4 — Reference specificity

**The gap:** humans name real things — texts, people, brands, places, prices, versions —
47% of the time against 24%. AI stays at vague allusion, 72% against 50%.

**In a dev blog post:** "a popular CI tool" instead of the name. "Recently" instead of a
date. "Significant savings" instead of the dollar figure. "The team" instead of who.

**Sentence-level form:** pattern #25 (vague attributions) catches the "experts say" shape.
This audit is broader — it covers every unnamed thing, not just unnamed authorities.

**The fix:** name it. The version number, the price, the city, the date, the person. This
is the cheapest human marker available and it costs nothing but accuracy.

**Interaction with placeholders:** where the specific isn't known, that is a `Fact`
placeholder for the author to fill (see `references/process.md` Phase 3), not a licence to
stay vague. A vague allusion is a placeholder nobody flagged.

## Audit 5 — Reader engagement

**The gap:** direct reader address 28% against 7%; fourth-wall permeability 67% against
39%. "AI writes as though no one is watching."

**The transfer caveat:** technical blogging already uses "you" constantly, so the raw
direct-address number does not transfer. The part that does is acknowledging the *writing
situation* — "I know how this sounds", "skip this section if you already run Kubernetes",
"you're probably skimming, so here's the number".

**Dosage:** this is a spice. One moment per post, maybe none. Most personas that have a
conversational voice already do this natively — check `persona/voice.md` before adding
any, and if the profile lists asides or direct address as a device, this audit is a drift
check only.

## Audit 6 — Shape convergence

**The gap:** not a per-feature rate. The five models cluster; humans scatter. This is the
audit with no sentence-level equivalent and the one most relevant to a blog that publishes
repeatedly, because it is the only one that can only be seen across posts.

**The question:** does this post have the same skeleton as the recent ones? Same opening
move, same arc, same closing move? How far back the comparison reaches is the script's, not
yours.

**Where the history lives:** `_blog-skill/post-shapes.json` in the Blog Home Directory
records the shape of each published post. Do not read or compare it yourself. SKILL.md
Step 9 has the invocation, the routing, and the correction loop; `references/post-shapes-schema.md`
has the field meanings.

**The fix:** open somewhere else, arc somewhere else, or close somewhere else — whichever
the verdict names. The intervention menu below and the mode menus in
`references/blog-anatomy.md` are what to reach for.

Change what the verdict asks for and no more. Rewriting every axis on every post rebuilds
the same problem with different defaults, which is the convergence trap in a new costume.

A first post has nothing to converge with, and that is not a finding.

---

## Intervention menu

Pick one or two. Vary across posts. Record what was used in `post-shapes.json` so the next
post can avoid repeating it.

- **Outcome first** — open at the end state, then rewind. The payoff lands mid-post.
- **Cold open** — start inside the incident, supply context afterward.
- **Delayed reveal** — withhold the number or the name the post is built on until late.
- **Recontextualization callback** — make an earlier detail mean something new.
- **The oblique tangent** — one paragraph parallel to the theme, not tied back.
- **The open thread** — name a question you cannot answer and leave it standing.
- **Genuine ambivalence** — end with both feelings intact, no forced resolution.
- **The named thing** — swap a vague allusion for a checkable specific.
- **Plain emotion** — replace body-performance with the stated feeling (pattern #39).
- **Acknowledged reader** — one moment that admits someone is reading.
- **End hot** — stop at the spike instead of the quiet coda.

## Know what drafted the text

Drafts written by Claude carry Claude's fingerprint, which the study found the most
distinctive of the five models:

- **The epilogue habit** — a wrap-up section after the natural ending. Cut it and end
  earlier. Watch for this in the "broader point" slot especially.
- **Flat event escalation** — uniform intensity from first paragraph to last. Vary the
  stakes and energy across the post.
- **Quiet, reverent endings** — occasionally end on the spike or leave it unresolved
  instead.

## What this file does not do

It does not fix vocabulary, punctuation, or sentence craft — that is
`references/ai-anti-patterns.md` and `references/tone-guide.md`. It does not impose a
voice — that is `persona/voice.md`. And it does not make a post undetectable. Nothing
does. It makes the post better shaped, which is the part that was worth doing anyway.
