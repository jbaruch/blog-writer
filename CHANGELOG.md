# Changelog

### Changed

- **Migrated the plugin manifest from `tile.json` to `.tessl-plugin/plugin.json`** — the legacy `tile.json` form is retired; `summary` becomes `description` and the `skills` map becomes an array. Reconciled the residual "tile" wording to "plugin" across the publish workflow's display name, `references/ai-anti-patterns.md` examples, and `evals/scenario-7/criteria.json`. The `docs.tessl.io` page references in `example-persona/product.md` keep "tiles" — those are live external URLs and page titles. Also dropped the forbidden `## Unreleased` heading so the publish pipeline's stamp step heads these entries with the published version.

### Fixed

- **Eval scenario-2 (voice-profile onboarding) was scoring 0/0** — its output spec and all 11 criteria targeted the absolute `~/.claude/blog-writer-persona/` path, which the eval grader (working-directory only) cannot see, so every criterion failed in both baseline and with-context. Redirected outputs to the working directory; the scenario now grades real output (baseline 91 → with-context 100).

### Removed

- **Retired four no-lift eval scenarios** per `jbaruch/coding-policy: plugin-evals` ("lift, not attainment"), confirmed across two runs: the `blog-writer-framework-override` scenario (contrived, near-zero lift), and scenario-1 / scenario-5 / scenario-6 (anti-pattern cleanup, soul check, tightening) whose baselines run 94–99% — coincidence with universal competence, no headroom for the plugin to show lift. Kept scenarios (0, 2, 3, 4, 7, 8) all contribute positive lift.

### Added

- **Optional `persona/framework.md` for post-level voice overrides** — A persona can now ship a `persona/framework.md` declaring post-level architecture (opening modes, argument shape by post type, density philosophy, first-person rules, closing modes, off-voice moves). When the file exists and has content, the skill reads it immediately after `persona/voice.md` and it overrides the *Blog Anatomy* section plus the narrative-density doctrine in `references/tone-guide.md`. Personas without the file are unaffected — the generic Blog Anatomy still applies. Originally contributed by @shelajev.
