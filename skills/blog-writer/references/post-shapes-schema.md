# post-shapes.json — Schema and Contract

State file backing audit 6 (shape convergence) in `references/structural-audits.md`. It
records the structural skeleton of each finished post so the next post can be shaped
differently on purpose.

**Location:** `_blog-skill/post-shapes.json` in the Blog Home Directory, beside
`series-tracker.md`.

**Owner:** the `blog-writer` skill. It is the only writer and the only migrator.

## Why a file and not the series tracker

`series-tracker.md` is series-scoped and prose. Convergence is a cross-series problem —
two posts in different series can share a skeleton — and the comparison is mechanical
enough to want fixed fields. The two artifacts coexist: the tracker carries narrative
continuity (callbacks, running jokes, open teasers), this file carries shape.

## Shape

```json
{
  "schema_version": 1,
  "posts": [
    {
      "slug": "ops-war-stories-ep3",
      "date": "2026-08-11",
      "opening_mode": "public-embarrassment",
      "arc": "problem -> pivot -> technical-meat -> cta",
      "closing_mode": "concrete-stop",
      "interventions": ["open-thread"],
      "point_stated_count": 1
    }
  ]
}
```

## Fields

| Field | Type | Required | Meaning |
|---|---|---|---|
| `schema_version` | integer | yes | Currently `1`. Top level, not per record. |
| `posts` | array | yes | Newest last. Append on completion. |
| `posts[].slug` | string | yes | The post's slug, matching its draft filename. |
| `posts[].date` | string | yes | `YYYY-MM-DD`, the date the post was finished. |
| `posts[].opening_mode` | string | yes | How the post opens. Free text, but reuse prior values verbatim so comparison works. |
| `posts[].arc` | string | yes | Section spine, ` -> ` separated. |
| `posts[].closing_mode` | string | yes | How the post ends. |
| `posts[].interventions` | array of string | yes | Which intervention-menu moves were used. Empty array is valid and common. |
| `posts[].point_stated_count` | integer | no | How many times the main idea is stated (audit 1). Omit when not measured. |

Values are descriptive, not a closed enum — a new opening mode is a new string. The
constraint that matters is **reusing an existing string when the shape is the same**, since
audit 6 compares by equality.

## Reader contract — Phase 2

- Read before locking the section outline.
- **A missing file, an unreadable file, or fewer than two records means the audit cannot
  fire.** Say so and continue. This is the normal state for a new author and must never
  block planning.
- Compare the planned shape against the last three records on three axes:
  `opening_mode`, `arc`, `closing_mode`.
- Two or more axes matching across all three prior posts is convergence. Change one axis
  and record why.
- The file is a hint, not authority (`jbaruch/coding-policy: stateful-artifacts`). If a
  record disagrees with the actual published post, the post wins — correct the record.

## Writer contract — Phase 3/4

- Append one record when the author declares the post done, not when the draft is first
  written. A draft that gets restructured in Phase 4 should be recorded as it ended up.
- Never rewrite a prior record except to correct it against the real post.
- Never reorder. Newest last.
- Create the file with `schema_version: 1` and a single-element `posts` array when it does
  not exist.

## Migration policy

- Only `blog-writer` migrates. A shape change bumps `schema_version`.
- On reading an older `schema_version`, upgrade the record, rewrite the file, continue.
- On reading a **newer** `schema_version` than this document describes, treat it as no
  usable prior state — skip audit 6, say so, and do not write. A newer file means a newer
  skill version wrote it; overwriting would lose data.
- No other skill reads or writes this file.
