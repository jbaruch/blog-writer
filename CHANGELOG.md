# Changelog

## Unreleased

### Fixed

- **Pattern #1 missed the "X rather than Y" variant** (#22) — the reference covered "Not X, but Y" and "Not just X, but also Y" but not the comparative form, which does identical structural work (negation plus affirmation competing for one slot) while reading as measured prose. It is the hardest of the three to catch by eye, because it does not sound like a mic drop. Added the variant to pattern #1 and a literal "rather than" sweep to the Pass 1 mechanical checks.
- **Pass 1 had no mechanical check for pattern #7** (#5) — only #8's em-dash density count existed, so paired em-dashes collapsed into "too many em-dashes" and individual occurrences survived all three passes. Added a #7 sweep that flags every ` — X — ` pair regardless of count, and made #8's entry state that it is the density check only, so a passing count no longer reads as clearing #7.
- **Eval scenario-2 (voice-profile onboarding) was scoring 0/0** — its output spec and all 11 criteria targeted the absolute `~/.claude/blog-writer-persona/` path, which the eval grader (working-directory only) cannot see, so every criterion failed in both baseline and with-context. Redirected outputs to the working directory; the scenario now grades real output (baseline 91 → with-context 100).

### Removed

- **Retired four no-lift eval scenarios** per `jbaruch/coding-policy: plugin-evals` ("lift, not attainment"), confirmed across two runs: the `blog-writer-framework-override` scenario (contrived, near-zero lift), and scenario-1 / scenario-5 / scenario-6 (anti-pattern cleanup, soul check, tightening) whose baselines run 94–99% — coincidence with universal competence, no headroom for the tile to show lift. Kept scenarios (0, 2, 3, 4, 7, 8) all contribute positive lift.

### Added

- **Optional `persona/framework.md` for post-level voice overrides** — A persona can now ship a `persona/framework.md` declaring post-level architecture (opening modes, argument shape by post type, density philosophy, first-person rules, closing modes, off-voice moves). When the file exists and has content, the skill reads it immediately after `persona/voice.md` and it overrides the *Blog Anatomy* section plus the narrative-density doctrine in `references/tone-guide.md`. Personas without the file are unaffected — the generic Blog Anatomy still applies. Originally contributed by @shelajev.
