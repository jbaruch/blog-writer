# Personal Identity Ownership and Migration

`create-personal-identity` is the sole owner and writer of personal identity packages.
Other skills may read a supported package but must not migrate, substitute, or rewrite it.

Before updating or migrating a package, inspect its `schema_version` and provenance. Handle
version 1 through the current package contract. Migrate an older version only when this
creator defines that migration; preserve valid guidance, source history, unresolved
conflicts, and approval state unless a consequential change requires `draft` review.

Stop on an unsupported schema and ask for an updated plugin or an owner-defined migration.
Never silently downgrade the schema, discard the selected identity, substitute another
identity, or rewrite an unsupported manifest into version 1.
