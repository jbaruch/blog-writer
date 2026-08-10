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
