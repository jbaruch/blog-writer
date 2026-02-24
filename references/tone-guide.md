# Tone of Voice Guide

This document defines the writing framework for blog posts. It covers narrative quality
rules, anti-pattern references, tone calibration, and structural conventions. Read it
before every draft.

The author's personal voice, rhetorical devices, and bio format are in `persona/voice.md`
and `persona/bio.md`. Read those too.

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
from `persona/voice.md` — parenthetical asides, cultural references, self-deprecation,
whatever is characteristic — should continue into the code examples and the architecture
discussion. A technical section should still sound like a person telling you about it at a
conference afterparty, not a whitepaper.

---

## Anti-Patterns: What to Never Do

**Read `references/ai-anti-patterns.md` for the full list.** It contains 18 named patterns
with symptoms, examples, and alternatives. Scan the draft against every one of them during
Phase 3 and Phase 4. Zero tolerance.

Quick index for scanning:
1. Rhetorical contrastive negation — "Not X. Y."
2. Parallel binary comparisons — mirrored A/B clauses
3. Asyndetic tricolon with a kicker — "X. Y. Z. And then..."
4. Choppy fragment chains — noun-phrase fragments as drama
5. Symmetrical LLM patterns — fortune-cookie balance
6. Self-answering fragment questions — "The result? Great."
7. Parenthetical em-dashes — paired dashes as fancy commas
8. Excessive em-dashes — more than two per section
9. Preamble announcements — "In this post, we'll explore..."
10. Sycophantic hedging — "It's worth noting that..."
11. Emojis — never
12. AI vocabulary contamination — "delve", "tapestry", "leverage", "pivotal"
13. Copula avoidance — "serves as" instead of "is"
14. Low burstiness — every sentence the same length
15. Fabricated experience — simulating personal moments that never happened
16. False ranges — "from beginners to experts"
17. Synonym cycling — "the CLI" → "the tool" → "the interface"
18. Unicode giveaways — curly quotes, ellipsis character, en dashes in source

---

## Tone Calibration: Blog vs. Stage

Conference talks can be more aggressive because body language and delivery soften the edge.
Blog posts need the same confrontational energy but with more self-deprecation and more
"we" language. On stage you can say "this is broken." In a blog, say "we broke it, here's
how, here's the screenshot."

The blog reader doesn't have your facial expressions. They have your sentences. Every
provocation needs a wink built into the prose.

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
- [ ] Run a final pass: search for every anti-pattern listed above. Rewrite any hits.

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
