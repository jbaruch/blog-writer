#!/usr/bin/env bash
#
# Runs every script test suite in the plugin.
#
# Discovers suites in both test directories. CI runs the diagnostics before
# invoking this script.
#
# Usage:
#   .github/run-script-tests.sh
#
# Exit codes:
#   0  every discovered suite passed
#   1  at least one suite failed, or no suite was found where one is expected

set -euo pipefail

# Package tests live outside the published skill trees.
readonly TEST_ROOTS=(tests .github)

for root in "${TEST_ROOTS[@]}"; do
  if [ ! -d "$root" ]; then
    echo "error: ${root}/ not found — run this from the repository root" >&2
    exit 1
  fi
done

# Discovery runs in its own command substitution so its exit status is checked.
# Reading it through a process substitution discards that status, so a `find`
# that failed part-way — an unreadable directory, a bad predicate — would yield
# a short list the gate then reports clean, which is the silent under-checking
# these gates exist to prevent.
if ! discovered=$(find "${TEST_ROOTS[@]}" -type f -name 'test_*.sh' | sort); then
  echo "error: could not enumerate test suites under ${TEST_ROOTS[*]} — re-run from the repository root and check the search paths are readable" >&2
  exit 2
fi

suites=()
while IFS= read -r suite; do
  if [ -n "$suite" ]; then
    suites+=("$suite")
  fi
done <<<"$discovered"

if [ "${#suites[@]}" -eq 0 ]; then
  echo "error: no test suites found under ${TEST_ROOTS[*]} (expected files named test_*.sh) — every shipped script needs tests per testing-standards" >&2
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
