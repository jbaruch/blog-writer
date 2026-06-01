# Create an Editorial Plan for a Blog Post

## Problem/Feature Description

Priya Nandakumar writes a developer-tools blog known for sharp, opinionated position pieces. She spent a week benchmarking three popular JSON-parsing libraries after her team's API gateway started burning most of its CPU budget on deserialization, and the result upends the advice her team had been following. She wants to turn her rough notes into a blog post.

Priya needs the source material analyzed and an editorial plan created -- not the draft itself, just the plan. The slug for this post is `json-parsing-showdown`.

Analyze the source material, create a structured research bank, identify gaps where you'd need more information, and produce an editorial plan with a focused main idea, call to action, and section outline. Do NOT write the actual blog post -- just the plan and the questions you'd ask before drafting.

## Output Specification

Produce the following files:
- `blog-research-json-parsing-showdown.md` -- structured research notes from the source material
- `editorial-plan.md` -- the editorial plan for the blog post
- `clarification-questions.md` -- questions you'd need answered before writing the draft

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: ~/.claude/blog-writer-persona/voice.md ===============
# Voice Profile: Priya Nandakumar

## The Voice in One Paragraph

You write like you argue in a code review: fast, specific, and allergic to hand-waving. You have strong opinions about developer tools and you back every one of them with a number. Your humor is dry and it lands in the technical asides, never in the warm-up. You assume the reader came for the finding, not for a story about your weekend.

## Rhetorical Devices That Work

### The benchmark that settles it
Letting a measured number do the talking instead of an adjective.

> "It wasn't 'a bit slower.' It was 4.1x slower on the p99, every run."

### The dry technical aside
A parenthetical that's only funny if you've felt the pain.

> "(Yes, we profiled it three times. No, it wasn't the GC. We checked that too, at 1 AM, like adults.)"

### The myth, named and dropped
Stating the common belief in one line, then dismantling it with data.

> "Everyone 'knows' the fastest parser is the one with the most GitHub stars. Everyone is wrong."

## Cultural Reference Style
Profiler flame graphs, benchmark-methodology arguments, and the gap between a library's README and its p99 latency.

## Voice Consistency Notes
The dry wit lives in the technical asides, not the opening. Priya's sentences are playful once the numbers are on the table; the post itself never warms up with a personal scene.

=============== FILE: ~/.claude/blog-writer-persona/framework.md ===============
# Post Framework: Priya Nandakumar

This file defines post-level architecture -- how a post is shaped -- independent of sentence-level voice.

## Opening mode
Open with the finding, stated flat. Lead with the claim or the number the post will defend: a position-claim or a result lead. Never open with a personal story, a "let me set the scene" anecdote, or a confession. The reader should know the thesis by the end of the first two sentences.

## Argument shape (by post type)
- Position piece / benchmark: claim first, then the evidence that earns it, then the implication for the reader's own choices. Inverted pyramid, not a slow build.
- The strongest counter-argument gets its own section, answered with data.

## Density philosophy
High. No scene-setting paragraphs, no throat-clearing. Every paragraph either advances the claim or supplies evidence. Cut the warm-up.

## Closing mode
End on a concrete decision rule the reader can apply ("reach for X when Y"). No reflective wrap-up, no "in the end" summary, no paragraph restating what the post already proved.

## Off-voice moves (do not do)
- Do not open with a narrative hook or personal anecdote.
- Do not build suspense before revealing the finding.
- Do not close with a philosophical reflection.

=============== FILE: inputs/benchmark-notes.txt ===============
BENCHMARK NOTES: JSON parsing showdown

CONTEXT
- Our API gateway (Go service, ~40k req/s at peak) was spending ~55% of CPU in JSON deserialization.
- Decided to benchmark alternatives instead of guessing.

LIBRARIES TESTED
- encoding/json (stdlib) -- the default everyone reaches for
- jsoniter (json-iterator) -- "drop-in faster" reputation, the most GitHub stars of the third-party options
- a codegen-based parser (generated structs, no reflection) -- more setup, far less popular

METHOD
- Replayed 24h of captured production payloads (anonymized), 2KB-180KB each, median 6KB.
- Measured p50/p99 decode latency and allocations per op.
- Ran each library 5 times, warm.

RESULTS (median across runs)
- stdlib: p99 baseline (1.0x), high allocations
- jsoniter: ~1.15x faster p50, but only ~1.05x faster p99 -- basically a wash under our payload mix. This surprised us.
- codegen parser: 4.1x faster p99, ~6x fewer allocations -- but it has to be regenerated on every schema change

THE MYTH WE HIT
- Team assumption going in: jsoniter is "the fast one" because it has the most stars.
- Reality: under realistic mixed payloads it was within noise of stdlib on p99. The unglamorous codegen approach won decisively, at the cost of developer ergonomics.

CAVEATS / UNRESOLVED
- Only tested Go. Unknown whether the gap holds in other languages.
- Codegen numbers were on one schema; haven't stress-tested deeply nested or polymorphic payloads.
- Haven't measured the build-time / CI impact of the codegen step yet.
- One jsoniter run showed a 2x p99 spike we could not reproduce. GC? Not sure.

QUOTES
- Priya: "We adopted the popular one for a year on vibes. The profiler disagreed."
- Sam (platform teammate): "So the boring one wins?" Priya: "The boring one always wins. We just never benchmark it."

PEOPLE
- Priya (ran the benchmark)
- Sam (platform teammate, skeptical of the codegen ergonomics)
=============== END INPUT ===============
