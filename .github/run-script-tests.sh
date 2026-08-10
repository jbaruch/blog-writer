#!/usr/bin/env bash
#
# Runs every script test suite in the plugin.
#
# Discovers suites by glob, so a suite added later is picked up without editing
# this file or the workflow. Kept separate from `.github/lint-shell.sh` so CI can
# run the diagnostics gate as its own step ahead of the tests, and separate from
# `.github/pre-publish.sh`, which chains both for the publish pipeline.
#
# Usage:
#   .github/run-script-tests.sh
#
# Exit codes:
#   0  every discovered suite passed
#   1  at least one suite failed, or no suite was found where one is expected

set -euo pipefail

readonly TEST_ROOT="skills"

if [ ! -d "$TEST_ROOT" ]; then
  echo "error: ${TEST_ROOT}/ not found — run this from the repository root" >&2
  exit 1
fi

suites=()
while IFS= read -r suite; do
  suites+=("$suite")
done < <(find "$TEST_ROOT" -type f -name 'test_*.sh' | sort)

if [ "${#suites[@]}" -eq 0 ]; then
  echo "error: no test suites found under ${TEST_ROOT}/ (expected files named test_*.sh) — every shipped script needs tests per testing-standards" >&2
  exit 1
fi

echo "Running ${#suites[@]} script test suite(s)"

failed=0
for suite in "${suites[@]}"; do
  echo
  echo "--- ${suite}"
  if bash "$suite"; then
    continue
  fi
  echo "error: suite failed: ${suite}" >&2
  failed=$((failed + 1))
done

echo
if [ "$failed" -ne 0 ]; then
  echo "error: ${failed} of ${#suites[@]} suite(s) failed" >&2
  exit 1
fi

echo "All ${#suites[@]} suite(s) passed"
