#!/usr/bin/env bash
#
# Repo-specific pre-publish gate, wired into the fleet publish pipeline via the
# reusable workflow's `pre-publish-script` input and run again on every pull
# request by .github/workflows/test.yml.
#
# Discovers and runs every script test suite in the plugin, so a suite added
# later is picked up without editing this file or the workflow. A failing suite
# fails the gate, which blocks the publish.
#
# Usage:
#   .github/pre-publish.sh
#
# Exit codes:
#   0  every discovered suite passed
#   1  at least one suite failed, or no suite was found where one is expected

set -euo pipefail

readonly TEST_GLOB_DIR="skills"

if [ ! -d "$TEST_GLOB_DIR" ]; then
  echo "error: ${TEST_GLOB_DIR}/ not found — run this from the repository root" >&2
  exit 1
fi

suites=()
while IFS= read -r suite; do
  suites+=("$suite")
done < <(find "$TEST_GLOB_DIR" -type f -name 'test_*.sh' | sort)

if [ "${#suites[@]}" -eq 0 ]; then
  echo "error: no test suites found under ${TEST_GLOB_DIR}/ (expected files named test_*.sh) — every shipped script needs tests per testing-standards" >&2
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
