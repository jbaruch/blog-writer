# blog-writer

Write developer blog posts from video transcripts, meeting notes, or rough ideas.

## What it does

Turns raw source material (video transcripts, meeting notes, rough outlines) into
polished blog posts in the author's own voice. The skill follows a phased workflow:
intake, clarification, editorial planning, first draft, and revision — with quality
gates at each step.

## Placeholders

Drafts use five placeholder types with independent numbering per type: Screenshot,
Code, Link, Fact, and Diagram. Code and Diagram placeholders include best-guess content
(reconstructed code blocks and inline D2 diagram source) plus a VERIFY comment for the
author to confirm. Diagrams earn their place when structure — architecture, request
flow, state transitions — is the point; a screenshot of the real system wins when it
can show the same thing with less abstraction.

## Anti-pattern detection

Drafts are checked against 32 named AI writing anti-patterns, each with symptoms,
examples, and alternatives (plus structural variants where applicable). The check runs
in three passes:

- **Surface scan** — matches known pattern forms and their structural variants
- **Skeleton scan** — compares grammatical structure of adjacent sentences to catch
  patterns where the vocabulary differs but the grammar is identical
- **Soul check** — holistic read for sterile, voiceless writing that passes pattern
  checks but still reads as obviously AI

Every rewrite is re-audited against all 32 patterns before it's considered fixed.

The anti-pattern list auto-updates from
[Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
at the start of each session to stay current as LLM writing patterns evolve.

## Persona system

The skill learns the author's voice through an interactive onboarding flow that analyzes
2-5 writing samples. Voice profile, bio template, product context, and example posts are
stored in `~/.claude/blog-writer-persona/` and read fresh each session. On first run, the
skill creates this directory (or lets you point it at a custom location like Google Drive
via symlink). After setup (or when new posts are added), you can optionally save the voice
profile to your global Claude Code user memory so it applies across all projects.

## Series support

Blog series state (episode numbers, callbacks, open threads) is tracked across posts in
`_blog-skill/series-tracker.md`.

## Getting started

Install via [Tessl](https://tessl.io):

```
tessl install jbaruch/blog-writer
```

On first use, the skill creates `~/.claude/blog-writer-persona/` and runs the setup flow
(or lets you symlink it to a custom location for backup). Clarification questions are asked
one at a time with numbered options — no question dumps. After that, just tell it what you
want to write about.
