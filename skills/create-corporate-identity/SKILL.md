---
name: create-corporate-identity
description: Create, update, or audit a reusable corporate writing identity from brand guides, corporate skills, published content, product messaging, editorial feedback, examples, or other user-supplied sources. Use whenever someone wants to capture, refresh, migrate, or check company-wide audience, terminology, evidence, positioning, and editorial constraints without prescribing an individual author's personality.
---

# Create Corporate Identity

This skill is an action router — pick the step that matches the user's intent and execute only that step. Do not run other steps; do not parallelize.

Corporate identity owns audience, brand values, terminology, evidence standards, approved
claims, positioning, and editorial constraints. It does not prescribe an individual
author's personality. Before any action, read
`skills/blog-writer/references/identity-spec.md` completely and follow its package,
provenance, strength, ownership, approval, and storage contracts.

## Step 1 — Create a Corporate Identity

Inventory every source the user supplies before drawing conclusions. Accept local files or
directories, URLs, pasted text, skills, style guides, example content, product
documentation, messaging frameworks, and editorial feedback. Establish each source's
scope, authority, and relevant date or version. A current formal guide normally outweighs
an older example, but conflicting authoritative policies remain unresolved until the user
decides.

Compile evidence about intended audiences, reader relationship, values, trust signals,
tone boundaries, terminology, product positioning, sources of truth, evidence standards,
format-specific conventions, editorial checks, and stated legal or reputational
constraints. Keep explicit policy separate from patterns observed in examples. Compile the
identity and review guidance from source skills without copying their workflow.

Write the package to the user's selected directory, defaulting to
`~/.claude/blog-writer-identities/corporate/<name>/`. Put concise shared guidance and
routing in `identity.md`; add roles such as `brand`, `terminology`, `editorial-review`, and
`product-context` only when the evidence supports them. Record every source and
consequential inference in `sources.md`. Set `status` to `draft` first.

Show the user the one-paragraph identity summary, Required and Avoid guidance, high-impact
inferences, and unresolved items. Ask one focused question at a time for consequential
conflicts. Set `status` to `approved` only after explicit approval. Finish here.

## Step 2 — Update a Corporate Identity

Read the existing package and its provenance before reading new evidence. Preserve valid
guidance and source history. Identify which conclusions the new sources confirm, weaken,
replace, or leave unresolved; never regenerate the package as if prior decisions did not
exist.

Apply accepted changes through the same package contract as Step 1. Keep the existing
status only when changes do not alter consequential guidance. For consequential changes,
set `status` to `draft`, show the changed summary, Required and Avoid guidance, high-impact
inferences, and unresolved items, then restore `approved` only after explicit approval.
Finish here.

## Step 3 — Audit a Corporate Identity

Compare the package and its provenance against the current authoritative sources and recent
representative content the user names. Report stale, unsupported, contradictory, overfit,
and missing guidance with the evidence for each finding. Pay special attention to old
examples outweighing current policy and unsupported claims presented as approved language.

Do not modify the identity during an audit. If the user later asks to apply accepted
findings, that follow-up request routes to Step 2. Finish here.
