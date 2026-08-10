#!/usr/bin/env bash
#
# ShellCheck gate for every shell script in the repo.
#
# Runs before the test suites, per `jbaruch/coding-policy: language-diagnostics`
# (the project's headless diagnostics engine at zero findings before tests) and
# `code-formatting` (lint checks before tests). This is the same command CI runs
# and the one to run locally before handing work off.
#
# Usage:
#   .github/lint-shell.sh
#
# Exit codes:
#   0  every script is clean
#   1  ShellCheck reported findings, or no script was found where one is expected
#   2  ShellCheck is not installed

set -euo pipefail

if ! command -v shellcheck >/dev/null; then
  echo "error: shellcheck not found on PATH — install it (brew install shellcheck / apt-get install shellcheck) and re-run" >&2
  exit 2
fi

scripts=()
while IFS= read -r script; do
  scripts+=("$script")
done < <(find .github skills -type f -name '*.sh' | sort)

if [ "${#scripts[@]}" -eq 0 ]; then
  echo "error: no shell scripts found under .github/ or skills/ — expected at least this repo's own gates" >&2
  exit 1
fi

echo "Linting ${#scripts[@]} shell script(s) with $(shellcheck --version | awk '/^version:/ {print $2}')"
for script in "${scripts[@]}"; do
  echo "  ${script}"
done

if ! shellcheck "${scripts[@]}"; then
  echo "error: ShellCheck reported findings — fix them before the tests run" >&2
  exit 1
fi

echo "All ${#scripts[@]} script(s) clean"
