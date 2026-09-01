#!/usr/bin/env python3
"""Validate and update a blog project's writing-identity selection atomically."""

from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path

from identity_lib import (
    CURRENT_SELECTION_SCHEMA,
    IdentityError,
    ToolError,
    load_selection_config,
    resolve_relative,
    selection_target,
    uses_named_user_path,
    validate_identity,
)


class ConfigError(ValueError):
    """The requested selection update is invalid."""


def migrate_config(config: dict) -> dict[str, object]:
    migrated: dict[str, object] = dict(config)
    if migrated["schema_version"] == CURRENT_SELECTION_SCHEMA:
        return migrated
    for key in ("personal", "corporate"):
        raw = migrated.get(key)
        if isinstance(raw, str) and uses_named_user_path(raw):
            try:
                migrated[key] = str(Path(raw).expanduser())
            except (RuntimeError, ValueError) as exc:
                raise ConfigError(f"cannot migrate {key} path {raw!r}: {exc}") from exc
    migrated["schema_version"] = CURRENT_SELECTION_SCHEMA
    return migrated


def validate_config_identities(config: dict[str, object], state_dir: Path) -> None:
    """Reject a selection unless every resulting package resolves successfully."""
    for kind in ("personal", "corporate"):
        raw = config.get(kind)
        if raw is None:
            continue
        if not isinstance(raw, str):
            raise ConfigError(f"{kind} must be a path string")
        validate_identity(raw, kind, state_dir)


def write_config(config_path: Path, target: Path, config: dict[str, object]) -> None:
    try:
        config_path.parent.mkdir(parents=True, exist_ok=True)
        descriptor, temporary_raw = tempfile.mkstemp(
            prefix=".identity.", suffix=".tmp", dir=target.parent
        )
        temporary = Path(temporary_raw)
        try:
            with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
                json.dump(config, handle, indent=2)
                handle.write("\n")
                handle.flush()
                os.fsync(handle.fileno())
            os.replace(temporary, target)
        finally:
            try:
                temporary.unlink(missing_ok=True)
            except OSError as exc:
                print(
                    f"warning: could not remove staging file {temporary}: {exc}",
                    file=sys.stderr,
                )
    except OSError as exc:
        raise ToolError(f"cannot write identity config {config_path}: {exc}") from exc


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--blog-home", required=True)
    parser.add_argument("--personal")
    parser.add_argument("--corporate")
    args = parser.parse_args()
    if args.personal is None and args.corporate is None:
        parser.error("at least one of --personal or --corporate is required")

    try:
        blog_home = resolve_relative(args.blog_home, Path.cwd())
        state_dir = blog_home / "_blog-skill"
        config_path = state_dir / "identity.json"
        target = selection_target(config_path, blog_home)
        config: dict[str, object] = (
            load_selection_config(target)
            if target
            else {"schema_version": CURRENT_SELECTION_SCHEMA}
        )

        for key, raw in (("personal", args.personal), ("corporate", args.corporate)):
            if raw is None:
                continue
            if raw:
                if uses_named_user_path(raw):
                    raise ConfigError(
                        f"{key} path must not use named-user expansion: {raw}"
                    )
                config[key] = raw
            else:
                config.pop(key, None)

        if not any(key in config for key in ("personal", "corporate")):
            raise ConfigError(
                "identity selection must include personal or corporate; "
                "set another layer before clearing the final selection"
            )

        config = migrate_config(config)
        validate_config_identities(config, state_dir)
        write_config(config_path, target or config_path, config)
        print(
            json.dumps(
                {
                    "ok": True,
                    "config": str(config_path),
                    "personal": config.get("personal"),
                    "corporate": config.get("corporate"),
                }
            )
        )
        return 0
    except (ConfigError, IdentityError) as exc:
        print(str(exc), file=sys.stderr)
        return 1
    except ToolError as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
