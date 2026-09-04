---
name: create-personal-identity
description: Creates, updates, migrates, and audits evidence-backed personal writing identity packages by tracing voice and composition guidance to source passages while excluding employer branding. Use when someone asks to capture their writing style, make a persona from their posts, build an author voice profile or tone guide, refresh an existing writing identity, migrate legacy persona files, or audit whether a profile matches its author.
---

# Create Personal Identity

This skill is an action router — pick the step that matches the user's intent and execute only that step. Do not run other steps; do not parallelize.

Personal identity owns how an author sounds and reasons, never employer positioning,
product claims, or corporate editorial policy.

Before any action, read both contracts completely:

```text
skills/create-personal-identity/references/lifecycle.md
skills/create-personal-identity/references/package-contract.md
```

For Step 1 or Step 2, also read the shared storage contract before writing:

```text
skills/blog-writer/references/identity-storage.md
```

That contract lives with `blog-writer` because every identity type shares its destination,
discovery, and selection layout.

Use this approval loop for every consequential create or update:

- Set `status` to `draft`.
- Show the one-paragraph summary, Required and Avoid guidance, high-impact inferences, and
  unresolved items.
- Ask one focused question at a time for consequential conflicts.
- Apply corrections, re-read each changed conclusion beside its cited sources, and present
  the corrected conclusion with those sources.
- Set `status` to `approved` only after explicit approval.

## Step 1 — Create a Personal Identity

1. Inventory every supplied file, directory, URL, pasted passage, existing skill,
   transcript, published post, interview, feedback item, and legacy persona file.
2. Classify each source as authored, ghostwritten, heavily corporate-edited, experimental,
   rejected, or unresolved; record its scope and authority before drawing conclusions.
3. Compile evidence about register, confidence, reader relationship, argument construction,
   rhetorical devices, humor, references, technical depth, recurring elements, deliberate
   variation, off-voice moves, and durable bio facts. Keep explicit preferences separate
   from observed patterns; sample frequency is evidence, not a quota.
4. Classify representative prose by writing mode and authorship. Route supported contiguous
   passages through an `examples` resource.
5. Mark a writing mode Unresolved when it lacks representative prose. Do not use these as
   prose evidence:

   - URLs whose prose has not been read
   - summaries
   - isolated lines

6. Resolve the destination through the shared storage contract, write the package through
   `skills/create-personal-identity/references/package-contract.md`, run the approval loop,
   then finish here.

Before approval, confirm every declared resource and consequential guidance item traces to
an inventoried source; leave any missing trace Unresolved.

## Step 2 — Migrate a Legacy Personal Identity

Read the source directory and run the exact v0-to-v1 migration in the lifecycle reference.
Stop unless the directory matches that reference's legacy v0 shape. Resolve the destination
through the shared storage contract. Run the approval loop and finish here.

## Step 3 — Update a Personal Identity

Read the existing v1 package and its provenance before reading new evidence. Preserve valid
guidance and source history. Identify which conclusions the new sources confirm, weaken,
replace, or leave unresolved; never regenerate the package as if prior decisions did not
exist. Stop on a non-v1 package; Step 2 owns the only supported older shape.

Apply accepted changes through
`skills/create-personal-identity/references/package-contract.md`. Keep the existing status
only when changes do not alter consequential guidance. For consequential changes, run the
approval loop. Finish here.

## Step 4 — Audit a Personal Identity

Compare the package and its provenance against the representative sources the user names.
Report stale, unsupported, contradictory, overfit, and missing guidance with the evidence
for each finding. Pay special attention to employer language misclassified as personal
voice and observed patterns promoted into requirements.

Do not modify the identity during an audit. If the user later asks to apply accepted
findings, that follow-up request routes to Step 3. Finish here.
