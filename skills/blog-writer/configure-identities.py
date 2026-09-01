#!/usr/bin/env python3
"""Update a blog project's writing-identity selection atomically."""

from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path


class ConfigError(ValueError):
    """The existing selection record is invalid."""


class ToolError(RuntimeError):
    """The selection record could not be read or written."""


def load_config(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ConfigError(f"missing identity config: {path}") from exc
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise ConfigError(f"invalid JSON {path}: {exc}") from exc
    except OSError as exc:
        raise ToolError(f"cannot read {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise ConfigError(f"expected a JSON object: {path}")
    errors = []
    if value.get("schema_version") != 1:
        errors.append("schema_version must be 1")
    for key in ("personal", "corporate"):
        if key in value and (not isinstance(value[key], str) or not value[key]):
            errors.append(f"{key} must be a non-empty path string when present")
    if errors:
        raise ConfigError(f"invalid identity config {path}: " + "; ".join(errors))
    return value


def write_config(config_path: Path, config: dict) -> None:
    try:
        config_path.parent.mkdir(parents=True, exist_ok=True)
        if config_path.is_symlink():
            try:
                target = config_path.resolve(strict=True)
            except FileNotFoundError as exc:
                raise ConfigError(
                    f"identity config is a dangling symlink: {config_path}"
                ) from exc
            if not target.is_file():
                raise ConfigError(
                    f"identity config symlink target is not a file: {target}"
                )
        else:
            target = config_path

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
    except ConfigError:
        raise
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
        blog_home = Path(args.blog_home).expanduser().resolve()
        config_path = blog_home / "_blog-skill" / "identity.json"
        config_present = config_path.exists() or config_path.is_symlink()
        config = load_config(config_path) if config_present else {"schema_version": 1}

        for key, raw in (("personal", args.personal), ("corporate", args.corporate)):
            if raw is None:
                continue
            if raw:
                config[key] = raw
            else:
                config.pop(key, None)

        write_config(config_path, config)
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
    except ConfigError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    except ToolError as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
