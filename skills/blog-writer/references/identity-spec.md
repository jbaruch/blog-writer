# Writing Identity Specification v1

Writing identities are compiled artifacts derived from source material. They let writing
skills consume stable guidance without reinterpreting raw samples, style guides, skills,
and feedback for every assignment.

## Package shape

Every identity is a directory with these required files:

- `identity.json` — machine-readable manifest
- `identity.md` — concise entry point and routing instructions
- `sources.md` — provenance, scope, and unresolved conflicts

Supporting Markdown files are optional. Their roles are declared in `identity.json`; do
not infer semantics from filenames alone. One file may serve more than one role, and every
declared role remains significant even when paths repeat.

```json
{
  "schema_version": 1,
  "type": "personal",
  "name": "author-name",
  "status": "approved",
  "entrypoint": "identity.md",
  "resources": [
    {"role": "voice", "path": "voice.md"},
    {"role": "examples", "path": "examples.md"}
  ],
  "sources": "sources.md"
}
```

## Manifest fields

- `schema_version`: integer; this specification currently defines version `1`.
- `type`: `personal` or `corporate`.
- `name`: stable lowercase identifier using letters, digits, and hyphens.
- `status`: `draft` or `approved`. Consumers may inspect drafts but must ask before using
  them to produce publishable content.
- `entrypoint`: the required literal path `identity.md`.
- `resources`: optional ordered list of `{role, path}` entries. Paths do not start with `~`,
  are relative to the identity directory, and stay inside it.
- `sources`: the required literal path `sources.md`.

Useful personal roles include `voice`, `composition`, `examples`, and `bio`. Useful
corporate roles include `brand`, `terminology`, `editorial-review`, and `product-context`.
Roles are extensible lowercase kebab-case strings.

## Guidance strength

Compiled guidance distinguishes:

- **Required** — an explicit policy or instruction from an authoritative source.
- **Preferred** — a strong convention supported by explicit guidance or consistent evidence.
- **Observed** — an inferred pattern that may help but must not become a hard rule.
- **Avoid** — an explicit prohibition or a consistently rejected pattern.
- **Unresolved** — contradictory or insufficient evidence requiring a decision.

Every consequential rule states its strength and scope. Quotes and examples are evidence,
not automatically rules.

## Provenance

`sources.md` records for each source:

- location or human-readable identifier
- source type and relevant date/version when known
- whether it supplied explicit guidance, observed behavior, or both
- conclusions derived from it
- authority and scope limits

Never claim approval, ownership, or authority that the source does not establish. Keep
unresolved contradictions visible.

## Composition semantics

Truth and assignment instructions are not identities. A writing consumer composes layers
in this order:

1. verified facts and source material
2. assignment-specific instructions
3. explicit corporate requirements
4. explicit personal preferences
5. inferred corporate conventions
6. inferred personal patterns
7. generic writing defaults

This order is a conflict-resolution heuristic, not permission to erase voice. Corporate
identity normally owns product terminology, approved claims, audience, and brand risk.
Personal identity normally owns cadence, humor, rhetorical devices, and first-person
expression. Ask when two explicit rules conflict and the assignment does not resolve them.

Corporate identity is optional and must be explicitly selected by the user or project
configuration. Never infer it from an employer, subject, product mention, or source URL.

## Ownership and lifecycle

`create-personal-identity` is the sole owner and writer of personal identity packages.
`create-corporate-identity` is the sole owner and writer of corporate identity packages.
The resolver validates their manifests and returns read-only metadata; `blog-writer` reads
the routed Markdown files and never migrates or rewrites an identity package.

Only an owner creator migrates an older package. A consumer treats an unsupported schema as
unusable and asks for an updated plugin or owner-led migration. It never silently drops the
selected identity, substitutes a different one, or rewrites the manifest.

`blog-writer` owns the project selection record at `_blog-skill/identity.json`.
`configure-identities.py` is its sole writer and `resolve-identities.py` is its reader. The
record always carries `schema_version`. Missing selection files are valid; missing identity
packages remain errors when their paths were explicitly selected.

## Storage and selection

The canonical shared root is `~/.claude/blog-writer-identities/`. It is a real directory or
a symlink to a user-selected shared directory. The shared storage lifecycle is defined in
`skills/blog-writer/references/identity-storage.md`.

Identity creators write default packages beneath the resolved root:

- personal: `~/.claude/blog-writer-identities/personal/<name>/`
- corporate: `~/.claude/blog-writer-identities/corporate/<name>/`

An identity may use another package directory only when the user supplies it as an explicit
custom path. Project-local placement is never a fallback for a missing canonical root.

A blog project selects one or both identities in `_blog-skill/identity.json`:

```json
{
  "schema_version": 2,
  "personal": "identities/personal/author-name",
  "corporate": "identities/corporate/company-name"
}
```

Relative paths resolve from `_blog-skill/`. In an existing selection file, an omitted
`personal` or `corporate` key explicitly disables that layer. A missing selection file is
different: it permits the legacy personal fallback described below. This distinction makes
corporate-only projects stable on machines that also have a legacy persona.

Selection paths may be relative, absolute, or use `~` for the current user's home. They
must not use named-user forms such as `~other-user/identity`.

`configure-identities.py` is the sole migrator from selection schema v1 to v2. On its next
write, it expands each resolvable v1 named-user path to an absolute path, preserves every
other selection, stamps v2, and writes the complete record atomically. It stops without
rewriting when an account cannot be resolved. `resolve-identities.py` reads both versions
during the rollout; it preserves v1 named-user expansion and enforces the v2 restriction.

The selection record may be a symlink only when its resolved target is a regular file
inside the blog home. The resolver and writer reject dangling, non-regular, and external
targets so repository-controlled links cannot read or overwrite files outside the project.

An assignment-specific command-line override takes precedence over project configuration.
Passing an empty override explicitly disables that layer for the assignment.

## Compatibility

The legacy `~/.claude/blog-writer-persona/` directory is a personal identity fallback only
when `_blog-skill/identity.json` is absent and no personal override was supplied. Its
`voice.md`, `framework.md`, `examples.md`, `bio.md`, and `product.md` remain readable, but
`product.md` may mix personal and corporate context. New identity creation must not add
corporate material to a personal identity. `create-personal-identity` alone may treat a
directory with no manifest and a non-empty `voice.md` as legacy v0 and compile a new package
from it. Migration leaves the legacy directory, symlink, and files unchanged. No legacy
corporate schema exists.
