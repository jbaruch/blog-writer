# Personal Identity Ownership and Migration

## Owners and readers

- `create-personal-identity` is the sole owner and writer. It reads every manifest and
  provenance field when it creates, updates, migrates, or audits a package.
- `resolve-identities.py` is the validating reader for `blog-writer`. It requires
  `schema_version: 1`, `type: personal`, a lowercase kebab-case `name`, `status` set to
  `draft` or `approved`, `entrypoint: identity.md`, and `sources: sources.md`.
- A missing `resources` field defaults to an empty ordered list. Each present resource must
  be an object with a lowercase kebab-case `role` and a non-empty `path`. The path must not
  start with `~`; it must be relative and stay inside the package. No other required field
  has a default; a missing or malformed value makes resolution fail.
- `blog-writer` reads only the files returned by a successful resolver result. It may inspect
  a draft but asks before using one for publishable content. It never writes the package or
  invents missing fields.

No reader may migrate, substitute, or rewrite a personal identity package.

## Supported legacy migration

For migration only, legacy v0 is a directory with no `identity.json` and a non-empty
`voice.md`. It may also contain `framework.md`, `examples.md`, `bio.md`, and `product.md`.
No other pre-v1 shape is supported.

Only `create-personal-identity` upgrades v0. Treat the legacy directory as a read-only
source and compile a new package at the destination resolved through
`skills/blog-writer/references/identity-storage.md`:

1. Inspect every legacy file and ask the user for a lowercase kebab-case identity name.
2. Copy `voice.md` into the new package; declare it as the `voice` resource.
3. Copy each non-empty `framework.md`, `examples.md`, and `bio.md`; declare them as
   `composition`, `examples`, and `bio` resources in that order.
4. Copy `product.md` without declaring it as a personal resource. Record its exclusion in
   `sources.md` and ask whether its corporate material should seed a corporate identity.
5. Create `identity.md` with concise shared guidance and routing derived from the declared
   resources.
6. Create `sources.md` with each legacy file's path, scope, authority, and migration notes.
7. Create `identity.json` under the v1 contract with the chosen name, the ordered resources,
   and `status: draft`.
8. Run the approval loop and rewrite only `status` to `approved` after explicit approval.

The completed manifest stamps the new package as `schema_version: 1`. Leave the legacy
directory, symlink, and files unchanged. Preserve all unresolved conflicts. A
manifest-bearing v1 source routes to Step 3 instead of migration. Stop on every other
manifest schema and ask for an updated plugin or an owner-defined migration. Never silently
downgrade, discard, substitute, or rewrite an unsupported package.
