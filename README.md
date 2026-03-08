# blog-writer

Write developer blog posts from video transcripts, meeting notes, or rough ideas.

## What it does

Turns raw source material (video transcripts, meeting notes, rough outlines) into
polished blog posts in the author's own voice. The skill follows a phased workflow:
intake, clarification, editorial planning, first draft, and revision — with quality
gates at each step.

## Anti-pattern detection

Drafts are checked against 22 named AI writing anti-patterns, each with symptoms,
examples, and alternatives (plus structural variants where applicable). The check runs
in two passes:

- **Surface scan** — matches known pattern forms and their structural variants
- **Skeleton scan** — compares grammatical structure of adjacent sentences to catch
  patterns where the vocabulary differs but the grammar is identical

Every rewrite is re-audited against all 22 patterns before it's considered fixed.

The anti-pattern list auto-updates from
[Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
at the start of each session to stay current as LLM writing patterns evolve.

## Persona system

The skill learns the author's voice through an interactive onboarding flow that analyzes
2-5 writing samples. Voice profile, bio template, product context, and example posts are
stored in `persona/` and read fresh each session.

## Series support

Blog series state (episode numbers, callbacks, open threads) is tracked across posts in
`_blog-skill/series-tracker.md`.

## Getting started

Install via [Tessl](https://tessl.io):

```
tessl install jbaruch/blog-writer
```

On first use, the skill runs the persona setup flow. After that, just tell it what you
want to write about.
