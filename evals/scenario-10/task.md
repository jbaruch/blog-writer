# Repair Card-Deck Flow Without Flattening the Author's Voice

## Problem/Feature Description

Revise an analytical opinion draft using the supplied, solely authored calibration
passages. The middle of the draft has a run of independent paragraph cards that can be
reordered without changing the argument. Restore real movement between them. Preserve the
dependent one-line punchline and the author's habit of carrying a claim forward before
qualifying it.

The pre-edit draft is the comparison baseline. Do not manufacture continuity by adding the
same transition phrase to each paragraph or by forcing every related thought into its own
sentence.

## Output Specification

Produce:

- `revised-draft.md` with the complete revised draft
- `calibration-report.md` naming the assignment mode and passages used, comparing pre-edit
  and post-edit prose across the five voice dimensions, and reporting mechanical sweep,
  manual anti-pattern review, voice calibration, and paragraph continuity separately

## Input Files

=============== FILE: identity/voice.md ===============
# Voice Profile: Amara Singh

Amara begins with a concrete engineering claim, follows its consequence into the next
paragraph, and then qualifies it with the operational detail that complicated her first
position. She speaks directly to experienced developers without explaining basic terms.
Her short punchline paragraphs depend on the argument immediately before them.
=============== END INPUT ===============

=============== FILE: identity/examples.md ===============
# Calibration Passages

## Passage A: "Queues Are Product Decisions", paragraphs 4-6
Mode: analytical opinion
Authorship: solely authored

A queue does more than hold work. It decides whose waiting time the system treats as cheap.

That decision stays invisible while throughput looks healthy. Watch one tenant sit behind a
bulk import, though, and the policy appears in the latency graph before anyone names it in a
design review.

I still use queues. I just want the product decision written next to the buffer size.

## Passage B: "Retries Spend Someone's Budget", paragraphs 2-4
Mode: analytical opinion
Authorship: solely authored

Retries turn a brief failure into a traffic policy. The first retry spends machine time;
the fifth may spend the attention of the person carrying the pager.

That escalation is why a retry count cannot live as an unexplained integer in a client
library. Its owner needs to know which failure it absorbs and which failure it amplifies.

Three retries looked conservative in staging. Production taught us what they were
conserving.

## Passage C: "Defaults Have Owners", paragraphs 7-8
Mode: analytical opinion
Authorship: solely authored

A default outlives the meeting that chose it. Months later, a new team experiences the
choice as a property of the system rather than an opinion somebody could revisit.

You can keep the default. Put an owner and an expiry date beside it, then give the next team
a way to disagree.
=============== END INPUT ===============

=============== FILE: draft.md ===============
# An Internal API Is Still an API

Internal APIs deserve product decisions. The absence of a price page does not remove the
cost paid by callers.

Documentation affects adoption. Teams avoid endpoints they cannot understand.

Versioning affects trust. Consumers delay migrations when compatibility promises are
unclear.

Error design affects support load. Generic failures send developers to a shared chat
channel.

Ownership affects longevity. An endpoint without an owner slowly becomes infrastructure
nobody feels allowed to change.

The interface is internal. The consequences are not.

This does not mean copying every public-API ritual. An internal endpoint with three known
callers can use a smaller review, shorter deprecation window, and a conversation instead of
a developer portal. The product decision is still there; the ceremony should fit its cost.
=============== END INPUT ===============
