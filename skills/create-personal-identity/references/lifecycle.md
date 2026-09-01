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

## Migration

Before updating or migrating a package, inspect its `schema_version` and provenance. Handle
version 1 through the current package contract. Migrate an older version only when this
creator defines that migration; preserve valid guidance, source history, unresolved
conflicts, and approval state unless a consequential change requires `draft` review.

Stop on an unsupported schema and ask for an updated plugin or an owner-defined migration.
Never silently downgrade the schema, discard the selected identity, substitute another
identity, or rewrite an unsupported manifest into version 1.
