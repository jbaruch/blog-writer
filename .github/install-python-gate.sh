#!/usr/bin/env bash
#
# Install the engines `.github/lint-python.sh` runs, at pinned versions.
#
# The pins live here and only here. They were previously env vars on the
# `test.yml` step that installed them, which left the publish pipeline with no
# way to get the same versions: `publish.yml` calls the reusable workflow, whose
# `pre-publish-script` input runs `.github/pre-publish.sh` on a runner that
# installs nothing of its own. The gate then exited 2 on a missing engine and
# skipped the publish — correctly, but the pipeline could never pass.
#
# Both callers now come here, so the two paths cannot drift onto different
# versions of the engines that gate the same code.
#
# Renewal cadence for the pins below: reviewed on the first Monday of each
# quarter, alongside SHELLCHECK_VERSION in `.github/workflows/test.yml`, against
# https://github.com/astral-sh/ruff/releases and
# https://github.com/microsoft/pyright/releases. No scanner tracks a version
# embedded in a script, so this cadence is the renewal mechanism
# `jbaruch/coding-policy: dependency-management` Freshness requires.
#
# Usage:
#   .github/install-python-gate.sh
#
# Idempotent: an engine already present at the pinned version is left alone, so
# re-running costs nothing (`file-hygiene` Idempotency).
#
# Exit codes:
#   0  both engines are on PATH at the pinned version
#   2  an installer is unavailable or the install failed

set -euo pipefail

readonly RUFF_VERSION=0.9.5
readonly PYRIGHT_VERSION=1.1.408

have_version() {
  local tool=$1 want=$2
  command -v "$tool" >/dev/null || return 1
  "$tool" --version 2>/dev/null | grep -qF "$want"
}

if have_version ruff "$RUFF_VERSION"; then
  echo "ruff ${RUFF_VERSION} already present"
else
  if ! command -v pipx >/dev/null; then
    echo "error: pipx not found on PATH — needed to install ruff ${RUFF_VERSION} outside the system Python; install pipx (or install ruff==${RUFF_VERSION} yourself) and re-run" >&2
    exit 2
  fi
  # --force so a differing version already installed is replaced rather than
  # reported as a conflict, which keeps the pin authoritative.
  if ! pipx install --force "ruff==${RUFF_VERSION}"; then
    echo "error: could not install ruff ${RUFF_VERSION} via pipx — check network access and that the version exists on PyPI" >&2
    exit 2
  fi
fi

if have_version pyright "$PYRIGHT_VERSION"; then
  echo "pyright ${PYRIGHT_VERSION} already present"
else
  if ! command -v npm >/dev/null; then
    echo "error: npm not found on PATH — needed to install pyright ${PYRIGHT_VERSION}; set up Node (the publish workflow's node-version input, or install Node locally) and re-run" >&2
    exit 2
  fi
  if ! npm install --global "pyright@${PYRIGHT_VERSION}"; then
    echo "error: could not install pyright ${PYRIGHT_VERSION} via npm — check network access and that the version exists on the registry" >&2
    exit 2
  fi
fi

for tool in ruff pyright; do
  if ! command -v "$tool" >/dev/null; then
    echo "error: ${tool} is still not on PATH after installing — check that the installer's bin directory is on PATH" >&2
    exit 2
  fi
done

echo "Python gate engines ready: $(ruff --version), $(pyright --version)"
