# Identity Resolution and Composition

The blog writer consumes personal and optional corporate identity packages defined by
`references/identity-spec.md`.

## Resolve

Run:

```bash
python3 .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/resolve-identities.py \
  --blog-home <blog-home>
```

For assignment-specific overrides, add `--personal <path>` and/or `--corporate <path>`.
An empty value explicitly disables that layer for the assignment. Overrides do not rewrite
project configuration.

Route on the result:

- Exit 0: read the JSON and then every path in `read_order` in order.
- Exit 1: selection or identity data is invalid. Report each diagnostic and ask the author
  to fix or choose a different identity. Do not silently fall back.
- Exit 2: invocation or tool error. Report the diagnostic and stop.

If `personal.mode` is `legacy`, preserve the former persona behavior. Treat legacy
`product.md` as context with uncertain ownership; do not assume it activates a corporate
identity.

Either identity may be absent, but at least one must resolve. With corporate-only writing,
use generic tone guidance for expression and do not manufacture a personal voice.

If a selected identity is `draft`, show that fact and ask whether to use it for this
assignment. Approval for one assignment does not change its manifest status.

Corporate identity must come from an explicit command-line override or project config.
Never infer one from an employer, product, topic, source URL, or personal bio.

## Configure

After creating or selecting an identity for the project, update the selection through its
owner script:

```bash
python3 .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/configure-identities.py \
  --blog-home <blog-home> [--personal <path-or-empty>] [--corporate <path-or-empty>]
```

At least one layer argument is required. A non-empty value sets that layer; an empty value
removes it while preserving the other layer. Clearing the final selected layer is invalid;
set its replacement in the same command or leave the selection unchanged. The writer
resolves every resulting identity before it writes. Exit 0 prints
`{"ok": true, "config": ..., "personal": ..., "corporate": ...}`. Exit 1 means the
existing selection or a resulting identity is invalid and the record remains untouched.
Exit 2 means an I/O failure and the record remains untouched. Never hand-edit
`_blog-skill/identity.json`.

A present selection file is authoritative. An omitted key disables that layer, so a file
containing only `corporate` stays corporate-only even when a legacy persona exists. When no
selection file exists, the resolver may use the legacy personal fallback.
Selection-file symlinks must resolve to a regular file inside the blog home.

## Read and compose

Read the personal entry point and routed resources, when selected, before generic tone
guidance. If a corporate identity is selected, read its entry point and routed resources
next. During drafting, re-read each selected entry point before every writing action;
re-read specialized resources when the affected content changes.

Apply this conflict order:

1. verified facts and source material
2. assignment-specific instructions
3. explicit corporate requirements
4. explicit personal preferences
5. inferred corporate conventions
6. inferred personal patterns
7. generic blog defaults

Corporate guidance normally governs product terminology, claims, audience, and evidence.
Personal guidance normally governs cadence, humor, rhetorical devices, and first-person
expression. Ask before drafting when explicit guidance conflicts and the assignment does
not resolve it.

Run corporate `editorial-review` resources after the generic anti-pattern and structural
checks. Corporate review augments the blog workflow; it does not replace intake, planning,
accuracy checks, or revision gates.
