#!/usr/bin/env python3
"""Check the executing plugin's catalog against the registry before refresh.

Usage: check-catalog-version.py
Reads the version shipped beside this script, independent of cwd.
Stdout: {installed: str|null, latest: str|null, status: current|mismatch|unknown}.
Exit 0 permits comparison. Exit 1 means versions differ. Exit 2 means verification failed.
No files are changed. Diagnostics on stderr tell the caller how to proceed.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from urllib.request import urlopen

PLUGIN = "jbaruch/blog-writer"
VERSION_FILE = Path(__file__).resolve().with_name("catalog-version.txt")
RELEASE_METADATA = (
    f"https://github.com/{PLUGIN}/releases/latest/download/acr-package.json"
)
VERSION = re.compile(r"\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?")


def version(value: object) -> str:
    if not isinstance(value, str) or not VERSION.fullmatch(value):
        raise ValueError("missing or invalid plugin version")
    return value


def check(version_file: Path) -> tuple[dict, int]:
    result = {"installed": None, "latest": None, "status": "unknown"}
    try:
        result["installed"] = version(version_file.read_text(encoding="utf-8").strip())
        with urlopen(RELEASE_METADATA, timeout=30) as response:
            remote = json.load(response)
        if (
            not isinstance(remote, dict)
            or remote.get("metadataVersion") != 1
            or remote.get("name") != PLUGIN
            or remote.get("repository") != f"https://github.com/{PLUGIN}"
        ):
            raise ValueError(f"ACR release metadata must name {PLUGIN}")
        latest = version(remote.get("version"))
        if remote.get("tag") != f"v{latest}":
            raise ValueError("ACR release tag does not match its package version")
        result["latest"] = latest
    except (OSError, ValueError) as error:
        print(
            f"Catalog version check failed: {error}. Check the bundled version file and "
            "GitHub release access, then retry. Skip the refresh comparison meanwhile.",
            file=sys.stderr,
        )
        return result, 2
    if result["installed"] != result["latest"]:
        result["status"] = "mismatch"
        print(
            "Catalog versions differ. Update the executing blog-writer installation "
            "to the latest release and rerun this check before comparing. "
            "Continue drafting with the existing catalog meanwhile.",
            file=sys.stderr,
        )
        return result, 1
    result["status"] = "current"
    return result, 0


def main() -> int:
    result, code = check(VERSION_FILE)
    print(json.dumps(result))
    return code


if __name__ == "__main__":
    sys.exit(main())
