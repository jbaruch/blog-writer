#!/usr/bin/env bash

main() {
  set -euo pipefail

  local script_dir repo_root
  script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
  repo_root=$(CDPATH='' cd -- "${script_dir}/../../.." && pwd)

  cd "${repo_root}"
  python3 -m unittest -v skills/blog-writer/tests/test_identity_tools.py
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
