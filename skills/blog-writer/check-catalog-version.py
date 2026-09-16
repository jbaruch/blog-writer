#!/usr/bin/env python3
"""Check the executing plugin's catalog against the registry before refresh.

Usage: check-catalog-version.py [--manifest PATH]
The default manifest belongs to this script's plugin, independent of cwd.
Stdout: {installed: str|null, latest: str|null, status: current|mismatch|unknown}.
Exit 0 permits comparison; 1 means versions differ; 2 means verification failed.
No files are changed. Diagnostics on stderr tell the caller how to proceed.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

PLUGIN = "jbaruch/blog-writer"
MANIFEST = Path(__file__).resolve().parents[2] / ".tessl-plugin/plugin.json"
VERSION = re.compile(r"\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?")


def version(value: object) -> str:
    if not isinstance(value, str) or not VERSION.fullmatch(value):
        raise ValueError("missing or invalid plugin version")
    return value


def check(manifest: Path) -> tuple[dict, int]:
    result = {"installed": None, "latest": None, "status": "unknown"}
    try:
        local = json.loads(manifest.read_text(encoding="utf-8"))
        if not isinstance(local, dict) or local.get("name") != PLUGIN:
            raise ValueError(f"manifest must name {PLUGIN}")
        result["installed"] = version(local.get("version"))
        response = subprocess.run(
            ["tessl", "plugin", "info", PLUGIN, "--json"],
            capture_output=True,
            text=True,
            check=True,
            timeout=30,
        )
        remote = json.loads(response.stdout)
        tile = remote.get("tile") if isinstance(remote, dict) else None
        if not isinstance(tile, dict) or tile.get("fullName") != PLUGIN:
            raise ValueError(f"registry response must name {PLUGIN}")
        result["latest"] = version(tile.get("latestVersion"))
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print(
            f"Catalog version check failed: {error}. Check the plugin manifest and "
            "Tessl registry access, then retry; skip the refresh comparison meanwhile.",
            file=sys.stderr,
        )
        return result, 2
    if result["installed"] != result["latest"]:
        result["status"] = "mismatch"
        print(
            "Catalog versions differ. Update the executing blog-writer installation "
            "to the registry version and rerun this check before comparing; "
            "continue drafting with the existing catalog meanwhile.",
            file=sys.stderr,
        )
        return result, 1
    result["status"] = "current"
    return result, 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=MANIFEST)
    args = parser.parse_args()
    result, code = check(args.manifest)
    print(json.dumps(result))
    return code


if __name__ == "__main__":
    sys.exit(main())
