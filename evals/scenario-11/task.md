# Recalibrate a Developer Blog Review Against Current Prose Tells

## Problem/Feature Description

Review and revise the developer blog excerpt below. Apply the current-source,
historical-source, Wikipedia/interface, general developer-blog, and accuracy categories
from the anti-pattern catalog.

The mechanical sweep reports no hard findings. Its em-dash observations report one paired
aside in the `What the benchmark proved` section and three total em dashes there. Use the
supplied same-mode identity passages to judge those observations; do not treat the old
per-section threshold as a rule.

## Output Specification

Produce:

- `revised-draft.md` with warranted prose fixes only
- `review-report.md` listing each candidate, its evidence class, the test applied, the
  verdict, and the reason for keeping or changing it

## Input Files

=============== FILE: identity/examples.md ===============
# Calibration Passages

## Passage A: "Benchmarks Need Witnesses", paragraphs 3-4
Mode: analytical opinion
Authorship: solely authored

A benchmark gives you a number — useful, compact, dangerously portable — and drops the
measurement choices that made it true. I want the workload beside the result, even when
that makes the chart harder to quote.

The number can stay. Its alibi stays with it.

## Passage B: "The Cache Is Part of the Contract", paragraphs 5-6
Mode: analytical opinion
Authorship: solely authored

The cache — yes, the boring map in memory — decides how stale a promise can become. That
decision belongs in the API review, next to the response schema and failure modes.

You can hide the cache from callers. You cannot hide what it does to them.
=============== END INPUT ===============

=============== FILE: draft.md ===============
---
title: The Benchmark Needs Its Workload
---

# The Benchmark Needs Its Workload

## What the benchmark proved

The project has received independent coverage and was featured in several leading trade
publications, proving its importance to platform engineering.

Wired measured a 180 ms cold start across 500 isolated runs on an M4 runner. InfoQ then
repeated the test with a warm dependency cache and recorded 74 ms.

The cache — the deliberately boring part — changed the result by 106 ms. That gap matters
more than the logo above the benchmark — and it is why the workload ships beside our chart.

## Who owned the change

Mina was connected to the rollout. The latency regression was associated with the retry
queue. Both relationships shaped the fix.

The benchmark client connected to Postgres over TLS during every measured run.

## Words around the result

The trace highlights the 400 ms gap between the first retry and the timeout. The launch
post is showcasing our commitment to performance and emphasizing the team's dedication to
seamless developer experiences. We delve into the numbers below.

The revised post keeps three facts:

- runner model and operating system
- cache state at the start of each run
- median and p99 across 500 runs

## The comparison readers need

| Workload | Cache state | Cold start |
| --- | --- | --- |
| Isolated runner | Empty | 180 ms |
| Isolated runner | Warm | 74 ms |

The table keeps the workload, cache state, and result visible in one place.
=============== END INPUT ===============
