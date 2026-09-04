# Review a Draft When Personal Voice Evidence Is Missing

## Problem/Feature Description

The author approved a personal identity and supplied a draft for an analytical opinion
post. The identity names several rhetorical devices, but its example resource contains only
links, one-line summaries, and an isolated quotation. The linked prose has not been fetched,
and the quotation's authorship is unknown.

The mechanical sweep has already run with zero hits. The author is unavailable for more
evidence and wants the review completed with every unresolved state kept visible. Do not
invent representative prose or imitate a voice from the device list.

## Output Specification

Produce `review-report.md`. State the assignment mode, evidence decision, mechanical sweep
state, manual anti-pattern review state, voice calibration state, and paragraph continuity
state. Explain what evidence the author must provide before voice can be calibrated.

## Input Files

=============== FILE: identity/voice.md ===============
# Voice Profile: Rowan Lee

## Rhetorical Devices

- dry one-line punchlines
- occasional direct address
- short asides in parentheses

## General Guidance

Sound candid and technically precise. Avoid marketing language.
=============== END INPUT ===============

=============== FILE: identity/examples.md ===============
# Example Posts

- https://example.com/rowan/platforms -- analytical post; direct and funny
- https://example.com/rowan/incident -- failure story; strong pacing
- "The abstraction held until production noticed it." -- source and authorship unknown
=============== END INPUT ===============

=============== FILE: draft.md ===============
# The Platform Team Is a Product Team

Platform teams often inherit a queue of requests and call it a roadmap. That framing hides
the real work. Internal users still make adoption decisions, compare alternatives, and stop
using tools that cost more attention than they save.

Treating the platform as a product changes which questions the team asks. Usage data shows
where developers abandon a workflow. Interviews explain the friction behind those exits.
Support requests reveal language that documentation failed to teach.

The shift also changes planning. A request from the loudest team becomes one signal among
several. The platform team can weigh reach, urgency, maintenance cost, and the damage caused
by leaving the problem alone.
=============== END INPUT ===============
