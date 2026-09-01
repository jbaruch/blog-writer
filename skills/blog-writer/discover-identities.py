#!/usr/bin/env python3
"""Enumerate manifest-valid writing identities beneath a shared root.

Exit 0 prints valid personal and corporate candidates plus rejected visible entries.
Exit 1 means the root layout is invalid. Exit 2 means invocation or I/O failed.
"""

from __future__ import annotations

import argparse
import json
import stat
import sys
from pathlib import Path

from identity_lib import (
    IdentityError,
    ToolError,
    inside,
    resolve_relative,
    validate_identity,
)


def discover_kind(root: Path, kind: str) -> tuple[list[dict], list[dict]]:
    kind_root = root / kind
    try:
        kind_mode = kind_root.stat().st_mode
    except FileNotFoundError:
        return [], []
    except OSError as exc:
        raise ToolError(
            f"cannot inspect {kind} identity path {kind_root}: {exc}"
        ) from exc
    try:
        if not stat.S_ISDIR(kind_mode):
            raise IdentityError(f"{kind} identity path is not a directory: {kind_root}")
        resolved_root = root.resolve(strict=True)
        resolved_kind_root = kind_root.resolve(strict=True)
        if not inside(resolved_root, resolved_kind_root):
            raise IdentityError(f"{kind} identity path escapes root: {kind_root}")
        entries = sorted(kind_root.iterdir(), key=lambda item: item.name)
    except IdentityError:
        raise
    except (OSError, RuntimeError) as exc:
        raise ToolError(
            f"cannot enumerate {kind} identities at {kind_root}: {exc}"
        ) from exc

    candidates: list[dict] = []
    invalid: list[dict] = []
    for entry in entries:
        if entry.name.startswith("."):
            continue
        try:
            entry_mode = entry.stat().st_mode
        except FileNotFoundError:
            invalid.append(
                {
                    "type": kind,
                    "path": str(entry),
                    "error": f"identity candidate is a dangling symlink: {entry}",
                }
            )
            continue
        except OSError as exc:
            raise ToolError(
                f"cannot inspect identity candidate {entry}: {exc}"
            ) from exc
        try:
            if not stat.S_ISDIR(entry_mode):
                raise IdentityError(f"identity candidate is not a directory: {entry}")
            try:
                resolved_entry = entry.resolve(strict=True)
            except (OSError, RuntimeError) as exc:
                raise IdentityError(
                    f"cannot resolve identity candidate {entry}: {exc}"
                ) from exc
            if not inside(resolved_kind_root, resolved_entry):
                raise IdentityError(f"identity candidate escapes {kind_root}: {entry}")
            identity = validate_identity(str(entry), kind, kind_root)
            candidates.append(
                {
                    "name": identity["name"],
                    "status": identity["status"],
                    "path": identity["root"],
                }
            )
        except IdentityError as exc:
            invalid.append({"type": kind, "path": str(entry), "error": str(exc)})
    return candidates, invalid


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    args = parser.parse_args()

    try:
        root = resolve_relative(args.root, Path.cwd())
        try:
            root_mode = root.stat().st_mode
        except FileNotFoundError:
            raise IdentityError(
                f"identity root does not exist: {root}; run setup-identity-root.py "
                "to establish it or pass an existing directory with --root"
            ) from None
        except OSError as exc:
            raise ToolError(f"cannot inspect identity root {root}: {exc}") from exc
        if not stat.S_ISDIR(root_mode):
            raise IdentityError(f"identity root is not a directory: {root}")

        personal, personal_invalid = discover_kind(root, "personal")
        corporate, corporate_invalid = discover_kind(root, "corporate")
        print(
            json.dumps(
                {
                    "ok": True,
                    "root": str(root),
                    "personal": personal,
                    "corporate": corporate,
                    "invalid": personal_invalid + corporate_invalid,
                }
            )
        )
        return 0
    except IdentityError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    except ToolError as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
