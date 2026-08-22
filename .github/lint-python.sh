#!/usr/bin/env bash
#
# Python diagnostics gate for every Python script in the repo.
#
# Runs before the test suites, per `jbaruch/coding-policy: language-diagnostics`
# (the project's headless diagnostics engine at zero findings before tests) and
# `code-formatting` (lint checks before tests). This is the same command CI runs
# and the one to run locally before handing work off.
#
# The shell side of the repo has `.github/lint-shell.sh`; this is its Python
# counterpart. Both gates run because the repo is deliberately two-language:
# environment plumbing (curl, symlinks, JSON records) stays in bash, and the
# text analysis in skills/blog-writer/sweep.py — sentence segmentation and
# per-sentence word counts — is work bash cannot do safely, since its regex
# engine has no lookbehind and its string handling is byte-oriented.
#
# Three engines, in the order the rules require:
#   ruff format --check   formatting, before lint (`code-formatting`)
#   ruff check            lint
#   pyright               the diagnostics engine `language-diagnostics` names
#                         for Python, at zero findings
#
# Usage:
#   .github/lint-python.sh
#
# Exit codes:
#   0  every script is formatted, lint-clean, and free of diagnostics
#   1  an engine reported findings, or no script was found where one is expected
#   2  a required engine is not installed

set -euo pipefail

missing=()
for tool in ruff pyright; do
  if ! command -v "$tool" >/dev/null; then
    missing+=("$tool")
  fi
done

if [ "${#missing[@]}" -ne 0 ]; then
  echo "error: not on PATH: ${missing[*]} — install with 'pip install ruff' and 'npm install -g pyright', then re-run" >&2
  exit 2
fi

# Discovery runs in its own command substitution so its exit status is checked.
# Reading it through a process substitution discards that status, so a `find`
# that failed part-way — an unreadable directory, a bad predicate — would yield
# a short list the gate then reports clean, which is the silent under-checking
# these gates exist to prevent.
if ! discovered=$(find .github skills -type f -name '*.py' | sort); then
  echo "error: could not enumerate Python scripts under .github/ or skills/ — re-run from the repository root and check the search paths are readable" >&2
  exit 2
fi

scripts=()
while IFS= read -r script; do
  if [ -n "$script" ]; then
    scripts+=("$script")
  fi
done <<<"$discovered"

if [ "${#scripts[@]}" -eq 0 ]; then
  echo "error: no Python scripts found under .github/ or skills/ — expected at least skills/blog-writer/sweep.py" >&2
  exit 1
fi

echo "Linting ${#scripts[@]} Python script(s) with $(ruff --version) and $(pyright --version)"
for script in "${scripts[@]}"; do
  echo "  ${script}"
done

if ! ruff format --check "${scripts[@]}"; then
  echo "error: formatting findings — run 'ruff format' on the reported files and commit the result" >&2
  exit 1
fi

if ! ruff check "${scripts[@]}"; then
  echo "error: ruff reported lint findings — fix them before the tests run" >&2
  exit 1
fi

if ! pyright "${scripts[@]}"; then
  echo "error: pyright reported diagnostics — fix them before the tests run" >&2
  exit 1
fi

echo "All ${#scripts[@]} script(s) clean"
