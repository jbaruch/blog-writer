# blog-writer

[GitHub releases](https://github.com/jbaruch/blog-writer/releases)

Write developer blog posts from video transcripts, meeting notes, or rough ideas.
Use the same skill for a humanizer or humanization pass on an existing draft: remove
AI slop and formulaic phrasing while preserving meaning, technical accuracy, and voice.
Scoped edits and non-blog assignments use the supplied material without blog setup or
publication bookkeeping. Review-only requests return findings without changing the source.

## Skills

| Skill | What it does |
|-------|--------------|
| [`blog-writer`](skills/blog-writer/SKILL.md) | Composes optional personal and corporate identities while drafting and reviewing a blog post |
| [`cfp-abstract`](skills/cfp-abstract/SKILL.md) | Writes conference talk abstracts and separate program committee notes |
| [`create-personal-identity`](skills/create-personal-identity/SKILL.md) | Compiles a reusable personal writing identity from supplied samples, interviews, personas, and feedback |
| [`create-corporate-identity`](skills/create-corporate-identity/SKILL.md) | Compiles a reusable corporate identity from supplied guides, skills, examples, product context, and feedback |

## Rules

| Rule | Scope | Purpose |
|------|-------|---------|
| [`blog-writer-script-location`](rules/blog-writer-script-location.md) | conditional | Authority for the `<blog-writer-dir>` lookup: which files invoke blog-writer's scripts, the scripts they may name, and how the name resolves for each loader |

## Installation

Install the [Agentic Context Registry CLI](https://github.com/jbaruch/agentic-context-registry/blob/main/docs/install.md).
In the project where you want to use the skills, choose your agent and install the package.

```bash
acr init --agent codex
acr install github:jbaruch/blog-writer
acr realize
```

Use `--agent claude-code` or `--agent cursor` for those agents. If the project already
has `agents.yaml`, start with `acr install`. The first ACR release is `v1.1.53`.
To try the package before that release is published, run `acr install /path/to/blog-writer`
in a consumer project and then `acr realize`.

For an existing Tessl installation, follow the [ACR consumer migration guide](https://github.com/jbaruch/agentic-context-registry/blob/main/docs/migration-guide.md)
after the first ACR release is available. Preview the migration from the consumer
project with an explicit mapping to the first ACR release.

```bash
acr migrate tessl --dry-run --map jbaruch/blog-writer=github:jbaruch/blog-writer@v1.1.53
```

## What it does

Turns raw source material (video transcripts, meeting notes, rough outlines) into
polished blog posts in the author's own voice. The skill follows a phased workflow:
intake, clarification, editorial planning, first draft, and revision — with quality
gates at each step.

## Placeholders

Drafts use five placeholder types with independent numbering per type: Screenshot,
Code, Link, Fact, and Diagram. Code and Diagram placeholders include best-guess content
(reconstructed code blocks and inline D2 diagram source) plus a VERIFY comment for the
author to confirm. Diagrams earn their place when structure is the point (architecture,
request flow, state transitions); a screenshot of the real system wins when it can show
the same thing with less abstraction.

The mechanical sweep has separate draft and final contracts. Draft mode permits the five
placeholder types and their VERIFY comments. Final mode blocks every unresolved marker and
deterministic interface residue before the finished post can be recorded. Retained
stylistic matches remain visible; an exit code alone does not establish editorial success. Phrases such as
"let me know" are surfaced separately for contextual review.

## Anti-pattern detection

Drafts are checked against a catalog of named AI writing anti-patterns, each with symptoms,
examples, and alternatives (plus structural variants where applicable). The check runs
in three passes:

- Surface scan, matching known pattern forms and their structural variants
- Skeleton scan, comparing the grammatical structure of adjacent sentences to catch
  patterns where the vocabulary differs but the grammar is identical
- Soul check, a read for evidenced departures from the selected identity or assignment
  that survive pattern checks

Four patterns are covered by three counting sweeps. They check fragment chains (#3/#4),
sentence-length uniformity (#14), and unicode giveaways (#18). Sentence-length and fragment
counts require a contextual disposition; justified rhetoric can retain reported hits.
Required artifact corrections cannot be waived as voice. These checks run as a script
(`sweep.py`) over the draft. The same run
reports paired em-dash locations, per-section counts, and spacing as observations for an identity-
and genre-calibrated judgment; punctuation counts alone do not fail the draft. Every run
reports what it did not examine.

The rest stay with the model. Their check is a reading, not a match: whether deleting a
filler word changes the meaning, whether a product claim still works with a competitor's
name in it, whether two phrases in different sections name the same concept.

Every rewrite is re-audited against the whole catalog before it's considered fixed,
including the script, which is re-run after every edit.

At the start of each session the skill fetches
[Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
and compares it against the anti-pattern list, then reports anything the list doesn't
already cover. The refresh reads and reports; it never edits the list. A finding becomes a
change to the skill through its own review, not a silent rewrite inside whichever session
happened to notice it.

## Structural audits

The anti-patterns work at the sentence and section level. Above them sit six discourse-level
audits, run one at a time, that look at the shape of the whole post: theme explicitness,
structural tidiness, emotion mode, reference specificity, reader engagement, and shape
convergence.

Three of them run on the outline during editorial planning, where structure is still cheap
to change. The other three run on the prose alongside the anti-pattern check. Each audit
reads the selected personal identity first. Where that identity already prescribes the
human-side behavior, the audit is a drift check rather than a new rule.

They are grounded in [StoryScope](https://arxiv.org/abs/2604.03136) (Russell et al. 2026),
which classified 61,608 stories using only discourse-level features at 93.2% macro-F1 and
found that a professional surface-editing pass moved detection by 1.6 points. The audits are
reimplemented from the published findings, not ported.

Shape convergence is the one audit that needs history, so finished posts get their skeleton
recorded in `_blog-skill/post-shapes.json`. Two tested scripts own every operation on that
file. An absent history is reported differently from an unreadable one, so a corrupt file is
never read as "no history yet".

The deliberate non-goal: applying every audit to every post trades one detectable shape for
another, so the guidance is one or two changes per post, varied across posts.

## Identity system

The two identity creators compile any user-supplied sources into a common, provenance-aware
format. Personal identity governs an author's expression. Corporate identity governs brand,
audience, terminology, claims, evidence, and editorial review. `blog-writer` can use either
identity alone or compose both, and corporate identity is never inferred from employer,
topic, or product mentions. Existing `~/.claude/blog-writer-persona/` profiles remain a
compatibility fallback.

Reusable packages live by default under the shared
`~/.claude/blog-writer-identities/{personal,corporate}/` root. The root may be a directory or
a symlink to a synced location selected during setup. An explicit custom package path stays
custom; a missing root never sends an identity into the current blog project.

Each blog project stores only its confirmed personal and corporate selections in
`_blog-skill/identity.json`. First use in an unconfigured project discovers and validates
shared packages before offering them. Personal selection always requires confirmation.
Corporate selection is separate and explicit. Later sessions reuse the project selection
without rediscovery. Legacy personas are offered as read-only migration sources; migration
does not repoint or rewrite the legacy path.

## Series support

Blog series state (episode numbers, callbacks, open threads) is tracked across posts in
`_blog-skill/series-tracker.md`.

## Getting started

On first use, establish or select the shared identity root, then create or select at least
one writing identity. Clarification questions are asked one at a time with numbered options.
Existing persona users may continue through the legacy fallback or migrate into a v1
personal package under the shared root.


## Development and releases

Run `acr install` and `acr realize` from this checkout to load the repository's
coding-policy dependency. Validate the authored package with `acr validate`. Run
`bash .github/lint-shell.sh`, `bash .github/lint-python.sh`, and
`bash .github/run-script-tests.sh` to run the same checks as CI.

Set the same version in `agent-plugin.yaml` and `skills/blog-writer/catalog-version.txt`.
Add a matching version heading to `CHANGELOG.md`. After the release commit lands,
push the matching `v<version>` tag. The tag workflow runs the checks and publishes
the package as a GitHub Release.
