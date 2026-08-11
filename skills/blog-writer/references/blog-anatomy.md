# Blog Anatomy and Series Support

Reference material for post-level architecture. Read during Step 4, applied during the
Phase 3 draft and Phase 4 revisions.

## Quick Reference: Blog Anatomy

> **Fallback only.** If `persona/framework.md` exists and has content, that file governs
> post-level architecture (opening modes, argument shape, density philosophy, closing modes)
> and overrides this entire section. Read it instead.

Posts are stories about real problems that happen to involve a technology (and optionally a
product). The reader should learn something even if they never touch the author's stack.

A typical post runs 1,500-2,000 words. 2,000 is a target, not a cliff — a tight 2,200
that earns every sentence is better than a padded 1,800.

**This shape is a starting point, not a template to fill.** Two of its parts are fixed
schema — the TLDR and the author bio. Everything between them is one arrangement among
several, and running the same arrangement every time is exactly the convergence audit 6 in
`references/structural-audits.md` exists to catch. Vary the opening and closing moves across
posts, and record which ones a post used (see `references/post-shapes-schema.md`).

The default arrangement:

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
references, analogies, and dry observations live here. **Optional, and the first thing to
cut.** A zoom-out section placed after the story already landed is the epilogue habit — the
most distinctive fingerprint of the model doing the drafting (see `references/structural-audits.md`,
"Know what drafted the text"). Some posts should skip it. Some should open with it instead.
A post that ends on its strongest concrete moment does not need one.

**CTA** — Practical, specific, low-friction. Usually: install something, try something, read
the next post. If the author has product context configured, suggest a product-related CTA
and confirm.

**Author bio** — Fixed schema, rotating kicker. The kicker is a dry joke that connects
to the post's content. See the bio format in `persona/bio.md`.

## Varying the Shape

Audit 6 compares a planned post against recent ones and reports which axes have converged.
Its invocation, routing, and correction loop are in SKILL.md Step 9. Vary the axes it
reports; the menus below are what to vary them to.

**Opening modes** — public embarrassment or confession; cold open mid-incident; outcome
first, then rewind; the delayed reveal that withholds the central number; a named artifact
(the error message, the bill, the diff) before any framing.

**Closing modes** — stop on the strongest concrete sentence; the open thread, a question
named and left unanswered; genuine ambivalence with both feelings intact; end hot on the
spike rather than a quiet coda; the recontextualized callback that changes an earlier
detail's meaning.

Change what the verdict asks for and no more. Rewriting every axis on every post rebuilds
the same problem with different defaults — see the convergence trap in
`references/structural-audits.md`.

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
