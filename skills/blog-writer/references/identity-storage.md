# Shared Identity Storage and First-Use Selection

## Resolve shared storage

Before creating or migrating an identity, probe the canonical root:

```bash
python3 .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/setup-identity-root.py --probe
```

Exit 0 prints `path`, `exists`, `kind`, resolved `target`, `personal_root`,
`corporate_root`, `action`, and `legacy`. Exit 1 reports an unusable root without changing
it. Exit 2 reports an invocation or I/O failure. Stop on either non-zero exit.

When the root is absent and no explicit custom package path was supplied, ask whether the
user already has a shared identity directory. Establish the canonical root as a real
directory when they do not:

```bash
python3 .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/setup-identity-root.py
```

Link the canonical root to their selected shared directory when they do:

```bash
python3 .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/setup-identity-root.py \
  --target <shared-identity-directory>
```

Both setup forms return the probe fields with `action` set to `created`, `linked`,
`prepared`, or `unchanged`. Use `<personal_root>/<name>/` or
`<corporate_root>/<name>/` from the result. Never invent a project-local package path.

An explicit package directory supplied by the user is an intentional custom path. Use it
after the probe without establishing a missing canonical root. Do not reinterpret a path
chosen by the agent as user intent.

The `legacy` object reports the canonical legacy persona path, its shape, resolved target,
and `migration_ready`. In personal and first-use flows, offer a ready legacy persona as a
migration source. Never repoint, delete, or rewrite the legacy path or its target.

## Discover first-use candidates

For an unconfigured project, enumerate packages beneath the resolved root:

```bash
python3 .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/discover-identities.py \
  --root <resolved-identity-root>
```

Exit 0 prints `personal` and `corporate` arrays of validated `{name, status, path}`
candidates plus an `invalid` array of rejected entries. Never offer an invalid entry. Exit
1 reports an invalid root layout. Exit 2 reports an invocation or I/O failure. Stop on a
non-zero exit.

Ask which personal identity the project should use for zero, one, or multiple candidates.
Offer these choices separately when available: create a personal identity, migrate the
legacy persona, or use no personal identity for a corporate-only project. Never select the
only personal candidate without confirmation.

A ready legacy persona may remain an assignment-only fallback when the user declines
migration. Do not write it into the v1 project selection. Pass any corporate choice as an
assignment override for that run. The project remains unconfigured and repeats discovery
on its next session.

Show every corporate candidate and require explicit selection. Include choices to create a
corporate identity or use no corporate identity. Never infer corporate selection from the
employer, topic, source material, or the presence of one candidate.

After the user confirms a personal-only, corporate-only, or combined choice, write it with
`configure-identities.py`. The writer validates every resulting package before changing
the selection file. Run `resolve-identities.py` and continue only when it returns the
confirmed identities. Apply the draft-status rule in
`skills/blog-writer/references/identity-composition.md` before using a newly selected draft.

On later sessions, a present project selection is authoritative. Do not run discovery or
ask again. If resolution reports a selected package as unusable, report the diagnostic and
ask the user to repair it or choose a replacement.
