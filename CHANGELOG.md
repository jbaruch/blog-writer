# Changelog

## Unreleased

### Added

- **Optional `persona/framework.md` for post-level voice overrides** — A persona can now ship a `persona/framework.md` declaring post-level architecture (opening modes, argument shape by post type, density philosophy, first-person rules, closing modes, off-voice moves). When the file exists and has content, the skill reads it immediately after `persona/voice.md` and it overrides the *Blog Anatomy* section plus the narrative-density doctrine in `references/tone-guide.md`. Personas without the file are unaffected — the generic Blog Anatomy still applies. Originally contributed by @shelajev.
