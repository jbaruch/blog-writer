# Catalog refresh

Check the executing plugin's catalog version before fetching the article:

```bash
python3 .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/check-catalog-version.py
```

The script reads its plugin manifest and the registry. Stdout carries `installed`,
`latest`, and `status`. Report both versions, including any unavailable value.

- **Exit 0** — continue with the article comparison below.
- **Exit 1** — report the update instruction on stderr. Skip the comparison and
  proceed immediately to Step 6 with the existing catalog. After updating the executing
  installation, reload its skill and references and rerun the version check before comparing.
- **Exit 2** — report the diagnostic. Skip the comparison and proceed immediately to
  Step 6 with the existing catalog. Do not report unverified freshness findings.

Fetch Wikipedia's "Signs of AI writing" article and compare it against
`skills/blog-writer/references/ai-anti-patterns.md`.

```bash
bash .tessl/plugins/jbaruch/blog-writer/skills/blog-writer/fetch-signs-of-ai-writing.sh
```

The script writes the raw wikitext to a file and prints `{"ok": true, "path": ..., "bytes": ...}`.
Read the file at `.path`.

- **Exit 0** — read the article and continue below.
- **Exit 1** — the fetch failed (network, HTTP error, or a body too short to be the
  article). Proceed with `skills/blog-writer/references/ai-anti-patterns.md` as-is.
- **Exit 2** — a tool or usage error (curl missing, destination not writable). Report the
  script's stderr diagnostic, then proceed with the current anti-pattern file as-is.

Report what the article carries and the anti-pattern file does not. Never edit
`skills/blog-writer/references/ai-anti-patterns.md` from this step. Give the author each finding in three
parts:

- what the article names, with its own wording for the tell
- the closest pattern already in the file, or that there is none
- whether its verdict is a count or a judgment, per the split in
  `skills/blog-writer/references/process.md` Phase 3 Pass 1

Say so plainly when the article carries nothing new. Then continue the session with the
current file either way — a finding changes the skill, never this run's draft.

