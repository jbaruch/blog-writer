---
alwaysApply: false
applyTo: "skills/**/*.md — when a skill or reference invokes a blog-writer script"
---

# Blog-Writer Script Location

## Scope

- Authority-of-record for blog-writer's scoped skill lookup under `coding-policy: script-delegation` Scoped Plugin Contracts
- Loaders: `blog-writer`, `cfp-abstract`, `create-personal-identity`, `create-corporate-identity`
- Files that invoke scripts: `skills/blog-writer/SKILL.md` and the shared references `sweep-review.md`, `identity-storage.md`, `identity-composition.md`, `catalog-refresh.md` under `skills/blog-writer/references/`

## Co-Shipped Targets

- Every target lives in `skills/blog-writer/`
- `sweep.py`, `check-shape-convergence.sh`, `record-post-shape.sh`
- `check-catalog-version.py`, `fetch-signs-of-ai-writing.sh`
- `setup-identity-root.py`, `discover-identities.py`, `resolve-identities.py`, `configure-identities.py`

## Lookup Contract

- Input: the base directory of the skill that loaded the file
- `<blog-writer-dir>` resolves to that directory when the loader is `blog-writer`
- For any other loader it resolves to the sibling `tessl__blog-writer` directory
- Each shared reference defines `<blog-writer-dir>` before its first command
- Every command names its interpreter, `bash` or `python3`
- Every command names one target above under `<blog-writer-dir>/`
- Each target's input/output contract is its top-of-file header
- `resolve-identities.py` and `configure-identities.py` document theirs in `skills/blog-writer/references/identity-composition.md` instead
- The lookup grants no runtime authority and waives no check a target performs

## Regression Coverage

- `skills/blog-writer/tests/test_script_location.sh` checks each command names a listed, existing target
- It checks each file defines the name above its first command
- It checks no command spells the consumer path
- In a simulated install it resolves `blog-writer` to its own base directory
- It resolves each other loader to the sibling `tessl__blog-writer` directory
- It parses every target the lookup reaches
