# post-shapes.json — Schema and Contract

State file backing audit 6 (shape convergence) in `references/structural-audits.md`. It
records the structural skeleton of each finished post so the next post can be shaped
differently on purpose.

**Location:** `_blog-skill/post-shapes.json` in the Blog Home Directory, beside
`series-tracker.md`.

**Owner:** the `blog-writer` skill. It is the only writer and the only migrator.

**The skill does not read or write this file directly.** Two scripts own every operation on
it, and the skill routes on their JSON output:

```text
skills/blog-writer/check-shape-convergence.sh   read + compare (read-only)
skills/blog-writer/record-post-shape.sh         append
```

## Why a file and not the series tracker

`series-tracker.md` is series-scoped and prose. Convergence is a cross-series problem — two
posts in different series can share a skeleton — and the comparison is mechanical enough to
want fixed fields. The two artifacts coexist: the tracker carries narrative continuity
(callbacks, running jokes, open teasers), this file carries shape.

## Shape

```json
{
  "posts": [
    {
      "schema_version": 1,
      "slug": "ops-war-stories-ep3",
      "date": "2026-08-11",
      "opening_mode": "public-embarrassment",
      "arc": "problem -> pivot -> technical-meat -> cta",
      "closing_mode": "concrete-stop",
      "interventions": ["open-thread"]
    }
  ]
}
```

## Fields

| Field | Type | Required | Meaning |
|---|---|---|---|
| `posts` | array | yes | Newest last. |
| `posts[].schema_version` | integer | yes | Stamped per record so a partially migrated history stays auditable. |
| `posts[].slug` | string | yes | The post's slug, matching its draft filename. |
| `posts[].date` | string | yes | `YYYY-MM-DD`, the date the post was finished. |
| `posts[].opening_mode` | string | yes | How the post opens. |
| `posts[].arc` | string | yes | Section spine, ` -> ` separated. |
| `posts[].closing_mode` | string | yes | How the post ends. |
| `posts[].interventions` | array of string | yes | Intervention-menu moves used. Empty array is valid and common. |

`schema_version` is per record rather than per file: a migration that upgrades some records
and is interrupted leaves a history that still describes itself accurately.

The three mode values are descriptive, not a closed enum — a new opening mode is a new
string. The constraint that matters is **reusing an existing string verbatim when the shape
is the same**, since the comparison is by equality. A synonym reads as a different shape and
hides the convergence the audit exists to catch.

## Reader contract — Phase 2

Run `check-shape-convergence.sh` with the planned shape. It reports whether a verdict is
possible (`can_fire`) and what the verdict is (`converged`, `converged_axes`).

How many prior posts it compares, how few are too few, and what counts as converged are the
script's decision contract — see its header, not restated here.

Route on the exit code:

| Exit | Meaning | What the skill does |
|---|---|---|
| 0 | Result is authoritative, including `can_fire: false` | Report the verdict, or report that the audit cannot fire, and continue |
| 1 | The file exists but cannot be used | Report the script's stderr diagnostic to the author and continue planning without audit 6. Do not delete or overwrite the file |
| 2 | Tool or usage error | Report the diagnostic and stop |

**An absent file is exit 0, not exit 1.** No history is the normal state for a new author
and never blocks planning. An unreadable or malformed file is a different thing and is
reported rather than folded into the empty case — that distinction is the script's, and the
skill must not re-collapse it.

The file is a hint, not authority (`jbaruch/coding-policy: stateful-artifacts`). If a record
disagrees with the actual published post, the post wins — correct the record.

## Writer contract — Phase 4

Run `record-post-shape.sh` once the author declares the post done. It stamps
`schema_version`, appends newest-last, and writes atomically through a staging file so an
interrupted run cannot truncate an author's history.

Two rules the caller owns, because no script can check them:

- Record the post **as it ended up**, not as it was first drafted. A post restructured in
  Phase 4 is recorded with its final shape.
- Reuse an existing mode string verbatim when the shape is the same.

Exit 1 means the history was refused and left untouched — a newer-schema or malformed file
is never overwritten. Report the diagnostic; do not work around it by deleting the file.

## Migration policy

- Only `blog-writer` migrates. A shape change bumps the scripts' supported version.
- Records above the supported version are skipped by the reader, counted in
  `skipped_newer_records`, and refused by the writer. Neither script rewrites them.
- A history written by a newer skill version means this install is lagging, not that the
  file is broken (`stateful-artifacts`, Migration Policy). Update the plugin rather than
  repairing the file.
- No other skill reads or writes this file.
