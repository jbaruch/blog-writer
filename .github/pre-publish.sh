#!/usr/bin/env bash
#
# Repo-specific pre-publish gate, wired into the fleet publish pipeline via the
# reusable workflow's `pre-publish-script` input.
#
# Chains the gates CI runs as separate steps on pull requests, in the order
# `language-diagnostics` and `code-formatting` require — diagnostics at zero
# findings first, then the tests. Any one failing fails the gate, which blocks
# the publish. Both languages are gated: bash owns the environment plumbing and
# Python owns skills/blog-writer/sweep.py.
#
# Usage:
#   .github/pre-publish.sh
#
# Exit codes:
#   0  ShellCheck and the Python engines clean, and every test suite passed
#   1  a gate failed (the failing gate's own diagnostic is on stderr)
#   2  a required tool is missing

set -euo pipefail

gate_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "== Shell diagnostics =="
bash "${gate_dir}/lint-shell.sh"

echo
echo "== Python diagnostics =="
bash "${gate_dir}/lint-python.sh"

echo
echo "== Script tests =="
bash "${gate_dir}/run-script-tests.sh"
