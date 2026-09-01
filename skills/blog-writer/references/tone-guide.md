# Tone of Voice Guide

This document defines the writing framework for blog posts. It covers narrative quality
rules, anti-pattern references, tone calibration, and structural conventions. Read it
before every draft.

The author's personal voice, rhetorical devices, and bio format come from the selected
personal identity. Read its routed resources when one is selected; otherwise this guide is
the expression fallback.

---

## Narrative Density: Show, Don't Summarize

This is the single biggest quality differentiator between a great post and a decent one.
Every section of the post — not just the opening hook — must contain specific moments, not
general descriptions. The reader should feel like they're watching over your shoulder, not
reading a report about what happened.

### The rule: if you can picture it, the reader should be able to picture it too

**Bad (general):**
- "The agent reported success across all metrics."
- "Implementation proceeded with tests first, honoring constitutional requirements."
- "The architectural convergence signaled a winning approach."

**Good (specific):**
- "The agent's final message: 'All 47 tests passing. Build successful.' Except the 12 e2e
  tests? Never ran. It just... skipped them."
- "I typed 'restart the app.' The response: 'Let me first understand what kind of application
  this is.' It had just built the thing."
- "It hardcoded — and I cannot stress this enough — HARDCODED — the loyalty program
  information directly into the source code."

### What "show" does not mean: name the feeling, don't perform it

The examples above all share one property — they are **named, checkable specifics**. Real
terminal output, a real file count, a real thing that was hardcoded. That is the half of
"show, don't tell" that reads as human, and it's the half to push harder on. Humans name
real things at roughly twice the rate machines do.

The other half — emotion staged through the body or the room — inverted while nobody was
looking. "My stomach dropped," "the cursor blinked mockingly," "I felt something shift"
are now the strongest single machine signature in the measured corpus, because models were
trained on the same writing advice and follow it harder than people do. See pattern #39 in
`references/ai-anti-patterns.md` for the full treatment.

So the density rule splits cleanly:

| Push harder | Cut |
|---|---|
| "All 47 tests passing. Build successful." | "My stomach dropped." |
| "It scaffolded 62 files in twelve seconds." | "The terminal glowed accusingly." |
| "It HARDCODED the loyalty program info." | "Something shifted that day." |
| The one sock, the cat on the keyboard, 2:14 AM | "I let out a breath I didn't know I was holding." |

Both columns are "specific." Only the left one is checkable. When an emotional beat needs
to land, say the feeling in the author's own register — "honestly, that one stung" — and
save the physical detail for the moment that actually earns it.

### How to maintain density throughout the post

The opening hook always has personality because writers focus there. The quality crime happens
in the middle sections — "the technical meat" and "the broader point" — where the voice drifts
toward industry analyst. Watch for these symptoms:

- **Passive constructions** that remove the human: "Implementation proceeded" instead of "I
  hit enter and watched it scaffold 62 files in twelve seconds"
- **Abstract nouns** replacing lived experience: "The architectural convergence" instead of
  "Three companies shipped the same idea within a month"
- **Missing reactions**: what did you think when it happened? What did your collaborator say?
  What did the terminal show? If a paragraph describes an event without anyone reacting to it,
  it's a summary, not a story

Every paragraph should pass this test: **"Could I rewrite this paragraph as three bullet
points in a status update and lose nothing?"** If yes, it's a summary. Rewrite it as a
moment the reader experiences.

### Voice consistency across sections

The author's voice doesn't turn off when the content gets technical. The rhetorical devices
from the personal voice resource — parenthetical asides, cultural references, self-deprecation,
whatever is characteristic — should continue into the code examples and the architecture
discussion. A technical section should still sound like a person telling you about it at a
conference afterparty, not a whitepaper.

---

## Anti-Patterns: What to Never Do

**`references/ai-anti-patterns.md` is the list.** It names every pattern, with symptoms,
examples, structural variants, and alternatives. Read it there — this file carries no
copy of it. Scan the draft against every pattern during Phase 3 and Phase 4. Zero
tolerance.

---

## Facts Over Assessments: The Mindset

These principles apply across the entire post — hook, body, CTA, TLDR. They're not about
catching specific anti-patterns (those are in `ai-anti-patterns.md`). They're about the
mindset behind strong writing.

No word choice — no matter how precise, how plain, how clever — substitutes for having
something to say. A sentence full of plain words is still empty if it contains no fact,
no story, no specific detail. The anti-pattern list catches bad words; these principles
catch missing substance. Cutting fluff is half the job. The other half is replacing it
with something the reader can use.

### 1. Let the reader conclude

Don't tell readers something is impressive — give them the evidence and let them be
impressed. The strongest evaluation is the one the reader makes themselves.

In tech writing: benchmarks beat adjectives, code samples beat descriptions, before/after
beats "much improved." Don't write "remarkably fast" — show the benchmark. Don't write
"elegant design" — show the three-line config. The reader's own "wow" is ten times more
powerful than yours.

### 2. The false-work test

If a paragraph feels complete but is mostly adjectives, you did word-work, not research-work.
Strip the evaluative adjectives from the paragraph and read the skeleton. If the skeleton is
empty — if all that's left is "A tool for teams" or "An approach to deployment" — the
paragraph doesn't need better adjectives. It needs facts. The author needs to go find a
number, a story, a before/after, a specific detail that earns the reader's conclusion.

Writing adjectives is easy. Finding facts is hard. That's why weak writing is full of
adjectives and strong writing is full of facts.

### 3. Simple words, complex ideas

Using "use" instead of "leverage" doesn't dumb anything down. Using "method" instead of
"methodology" doesn't lose nuance. Complexity belongs in the *ideas*, not the *vocabulary*.

A reader who understands the concept won't be more impressed by a Latin synonym. A reader
who doesn't will be lost by one. In both cases, the plain word serves the reader better.
The only exception: when the precise technical term carries meaning the plain word doesn't
(e.g., "idempotent" means something specific that "repeatable" doesn't fully capture). In
that case, use the precise term — but explain it if needed.

### 4. Benefit, not features

When describing a product or tool, translate every feature into what it means for the
reader. Raw specs are for data sheets. Blog readers want to know what changes for them.

**Feature (useless):** "25,000 mAh battery."
**Benefit (useful):** "2.5 hours of continuous cleaning — enough to vacuum a 60m² apartment
on a single charge."

**Feature:** "Automatic route mapping with contamination detectors."
**Benefit:** "It doesn't wander randomly — it heads straight for the dirty spots first.
Cleans a two-bedroom apartment in one pass on one charge."

The test: after writing a feature description, ask "so what does the reader get from this?"
If the answer isn't in the text, rewrite. Every spec should answer "why should I care?"
from the reader's chair.

### 5. Cut then fill — never leave a hole

Cutting filler, assessments, and clichés is only half the editorial job. Every cut leaves a
hole where substance should go. If you delete "robust and scalable" and leave the sentence
as "A solution for modern teams," you've made the sentence *cleaner* but not *stronger* — it's
still empty. The fix is to replace the cut with a fact: "Handles 50K RPS on a single node.
Add nodes to grow linearly."

**The rule:** never submit a sentence that got shorter without getting more informative. If
you cut three adjectives and the sentence collapsed, the sentence was *made of* adjectives —
it needs research, not editing. Go find a number, a story, a before/after, a specific
behavior. Then write the sentence around that.

This applies at every stage:
- **During writing:** when you catch yourself reaching for an adjective, stop and ask "what's
  the fact behind this?" Write the fact instead.
- **During anti-pattern rewrites:** when you fix a pattern hit, don't just delete — replace.
  A rewrite that's shorter but emptier is a lateral move, not a fix.
- **During tightening:** when you cut a sentence for brevity, check that the paragraph still
  earns its place. If cutting revealed that the paragraph had nothing to say, cut the
  paragraph — or go find the substance it was missing.

A post that's been aggressively cut but never filled reads like a telegram: clean, short,
and devoid of value. Cut *and* fill. Always both.

---

## Sentence & Paragraph Craft

These rules govern how ideas flow at the sentence, paragraph, and structural level. They
complement the anti-pattern list (which catches AI tells) and narrative density (which
catches flat writing). These catch *overloaded, tangled, or structureless* writing.

### Sentence-level: one idea per sentence

A "new idea" is either (a) introducing the reader to something unfamiliar, or (b) showing
a familiar thing interacting with another familiar thing. One sentence should carry one new
idea. Two tightly related ideas are acceptable. Three or more is overloaded — split the
sentence.

**Test:** count the distinct ideas in a sentence. If a sentence answers three different
questions (what? how? for whom?), it's three ideas crammed together. Give each its own
sentence.

**Overloaded:** "We sell camping gear wholesale and retail to hikers, athletes, and anyone
who loves the outdoors, from our stores in four cities or our next-day delivery online
shop."

**Split:** "We sell camping gear: tents, backpacks, stoves, sleeping pads. Our customers are
hikers, athletes, anyone who spends weekends outside. We have stores in four cities and an
online shop with next-day delivery."

### Generalize before listing

When introducing multiple unfamiliar items, tell the reader what category they belong to
before listing them. The category label ("three tools," "two reasons," "four steps") gives
the reader a shelf to put things on.

**Cold list:** "Fraudsters use skimmers, keyboard overlays, hidden cameras, and direct
observation to steal your money."

**Generalized:** "Fraudsters use three tools to steal your money: skimmers, keyboard
overlays, and hidden cameras."

The generalization also forces you to decide what really belongs. In the example above,
"direct observation" isn't really a tool — cutting it made the sentence stronger.

### Explain by chain: known → unknown

When explaining something complex, introduce one new concept at a time, building each
explanation on what the reader already knows. Don't introduce a new concept and immediately
use it in a complex interaction in the same sentence.

**Overloaded:** "The buffer overflow control system monitors the printer's job stack and
ensures uninterrupted operation even when too many jobs are submitted simultaneously."

**Chain:** Start with what a buffer is. Then explain overflow. Then explain the control
system. Each sentence uses only concepts the reader already has.

Calibrate to your audience. Technical readers don't need the basics explained — but they
do need *their* unfamiliar concepts introduced one at a time.

### Strong subjects and verbs

Sentences with real actors doing real things are easier to read and more vivid than
sentences with abstract nouns in passive constructions.

**Strong subject:** a person, team, company, program, robot — something that can act.
**Weak subject:** an abstract noun, a nominalization, "the presence of," "the implementation
of" — things that can't do anything.

**Weak:** "Reforestation led to a reduction in CO₂ concentration in the region."
**Strong:** "Greenpeace volunteers restored this stretch of forest, and CO₂ levels in the
region dropped."

**Strong verb:** an action you can picture — build, break, ship, reject, measure, cut.
**Weak verb:** a state verb hiding a real action — "is," "exists," "ensures," "indicates,"
"involves," "facilitates."

**Weak:** "The CRM implementation will ensure sales growth."
**Strong:** "When we roll out the CRM, sales reps will close a third more deals."

Don't force this mechanically. Some sentences naturally describe states, not actions. "It's
raining" is better than "Clouds above us accumulate moisture to release it." If a state verb
sounds natural, keep it. If an action is hiding behind a state verb, free it.

See also anti-pattern #13 (copula avoidance / nominal style) for the AI-specific variant.

### Read-aloud test

Read the draft out loud — not in your head, not in a whisper, but aloud with expression.
Every place you stumble, lose breath, or lose the thread is a place the reader will too.

- **Out of breath?** The sentence is too long. Split it.
- **Tripped on a word cluster?** Consonant collisions or awkward phrasing. Rewrite.
- **Lost the point mid-sentence?** Too many subordinate clauses. Flatten.
- **Sounds robotic?** The syntax is manufactured. Rewrite as you'd say it to a colleague.

Best syntax reads like natural speech. Tension and formality produce tangled sentences.
Write relaxed, then edit tight.

### Reduce subordination and nesting

Nested subordinate clauses ("which... that... because... when...") force the reader to hold
the beginning of the sentence in memory while processing the middle. More than one level of
nesting is a flag. Flatten by splitting into separate sentences.

**Nested:** "Due to the law, which was passed despite industry protests that included press
statements and public declarations, all companies that transmit data must store
correspondence history for six months or a year."

**Flat:** "The new law requires all data-transmitting companies to store correspondence for
six months to a year. The industry protested publicly, but the law passed anyway."

Also watch for:
- **Indirect speech:** "He said that he thought that..." → Just say what he said.
- **Split conjunctions:** "not only... but also," "both... and," "if... then" with long
  material between the halves. If the reader forgets the first half before reaching the
  second, simplify.
- **Stacked commas:** Many commas in a sentence usually signal a structure that's doing too
  much. Count them — if a sentence has 4+ commas, it probably needs splitting.

### Paragraph architecture

**One paragraph = one topic.** The topic is set by the first sentence (or the second, if the
first is a hook). Everything in the paragraph must relate to that topic. If a sentence
belongs to a different topic, move it to its own paragraph or cut it.

**First sentence does one of two jobs:**
1. **States the main idea** — best for technical content, instructions, business writing.
   The reader scans first sentences to navigate; if yours are vague ("Let's consider
   another aspect..."), the reader can't skim.
2. **Hooks with something unexpected** — best for opening paragraphs and opinion pieces.
   A question, a personal moment, a provocative claim.

**Test:** read only the first sentences of all paragraphs in sequence. They should tell a
coherent story on their own. If they don't, the paragraph structure needs work.

**Last sentence earns its place.** The end of a paragraph is what the reader remembers. Use
it for a conclusion ("so the takeaway is..."), a practical recommendation, or a rule. Don't
repeat the first sentence in different words. If the first sentence already said it all,
just end the paragraph — no decorative conclusion needed.

**Kill stream-of-consciousness.** Informational text isn't a diary. If sentences follow each
other by free association rather than logical structure, the reader has to decode every
connection. Structure the paragraph so the connections are obvious.

### Goal-driven content filtering

Every text moves the reader from point A (what they believe now) to point B (what they
should believe/know/do after reading). This is the goal.

**The straight-line test:** every paragraph should advance the reader toward B. If a
paragraph is interesting but doesn't serve the goal, it's a digression. Cut it or save it
for a different post.

This principle is already enforced in Phase 2 (editorial planning) via the main idea
sentence. These rules make it concrete at the paragraph level during writing:

- Before writing a paragraph, ask: "Does this move the reader closer to B?"
- If a paragraph introduces a tangent, ask: "Will the reader need this to reach B?" If not,
  cut.
- If you find yourself writing "by the way" or "incidentally" or "on a related note" — you're
  about to digress. Stop and check whether the digression earns its place.

---

## Tone Calibration: Blog vs. Stage

Conference talks can be more aggressive because body language and delivery soften the edge.
Blog posts need the same confrontational energy but with more self-deprecation and more
"we" language. On stage you can say "this is broken." In a blog, say "we broke it, here's
how, here's the screenshot."

The blog reader doesn't have your facial expressions. They have your sentences. Every
provocation needs a wink built into the prose.

---

## Respect and Care: Talk to Equals

The reader is not above you or below you. They are a peer who happens to need what you
know. Two failure modes:

**Writing down (condescension):** Dumbing things down, using cutesy language, assuming the
reader can't handle complexity. "Hey mommies, you know that problem when..." or "Don't
worry, this is easier than it sounds!" If you wouldn't say it to a colleague, don't write
it.

**Writing up (pandering):** Excessive formality, corporate honorifics, flattery.
"Esteemed professionals, we present for your consideration..." If it sounds like a press
release or a formal invitation, rewrite it as you'd say it over coffee.

Both modes create distance. The reader notices and loses trust — either they feel
patronized or they feel marketed at. The fix is the same: write as if you're explaining
something to a smart friend who hasn't seen this particular thing yet. Honest, direct,
on equal footing.

---

## Voice Consistency Checklist

Before submitting a draft, check:

- [ ] Does the opening tell a story, not state a thesis?
- [ ] Is there at least one moment of genuine self-deprecation (not performative)?
- [ ] Are cultural references earned (illuminate the point) or decorative (name-dropping)?
- [ ] Do code blocks and screenshots carry narrative weight, or are they filler?
- [ ] Does the CTA feel like advice from a friend, not a sales pitch?
- [ ] Would you be embarrassed to read any sentence out loud at a conference?
- [ ] Is the bio kicker actually funny AND connected to the post's content?
- [ ] **Sentence craft:** No sentence carries 3+ distinct ideas. New concepts are generalized
  before listing. Subordination is max one level deep. State verbs aren't hiding real actions.
- [ ] **Paragraph craft:** Each paragraph has one topic. First sentences tell a coherent story
  when read in sequence. No stream-of-consciousness digressions.
- [ ] **Goal alignment:** Every paragraph advances the reader toward the main idea (point B).
  No tangents survived the cut.
- [ ] Run a final anti-pattern check: surface scan (match examples and structural variants),
  then skeleton scan (compare grammatical structure of adjacent sentences), then soul check
  (holistic read for sterile, voiceless writing). Rewrite any hits, then re-check each
  rewrite against every pattern before considering it fixed.

---

## TLDR Format

Always bullets. Written last, placed first.

### Construction Rules

**Don't explain the mechanism.** If the post teaches the reader how something works, the
TLDR should make them want to know how, not spoil it. "We rebuilt X and the result was Y"
beats "X uses lazy-loading, native scripts, and sits deeper in the prompt hierarchy."

**Compress, don't miniaturize.** A good TLDR bullet takes a whole section's argument and
restates it as a provocation. A bad one takes a whole section and shrinks it into a feature
list. If a bullet reads like release notes, it's wrong.

**The recurring character bullet rule.** If the post has a recurring character or foil, one
bullet should belong to them. It humanizes the TLDR and breaks the pattern of technical
claims. The character bullet is always last.

**Three bullets is usually right.** Two feels thin. Four starts explaining too much. Three
gives you: one provocation that sets up the problem, one that hints at the payoff, one
that's human or funny.

**Test: would you click?** Read each bullet in isolation. If it doesn't make someone think
"wait, I need to read this," rewrite it. A bullet that merely summarizes what happened is
not a provocation. Good bullets create curiosity gaps — they hint at something surprising
without explaining it. "We told the agent 'no external APIs' four times before it listened"
is a provocation. "We iterated on the agent's output to improve the architecture" is a summary.

### Examples

**Good TLDR bullets:**
- "The spec file defines what you're building. The agent just follows orders."
- "The agent found 'critical gaps' in its own research when it compared its plan against
  actual documentation!"
- "When we wiped the context mid-stream, it recovered from the spec files alone!"

**Bad TLDR bullets:**
- "We built an app using a structured development approach and it worked better." (summary, not provocation)
- "This post covers our experience with the new toolchain." (meta-description, not content)
- "It uses lazy-loading, native scripts, and sits deeper in the prompt hierarchy."
  (mechanism dump — reads like release notes)
