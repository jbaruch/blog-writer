#!/usr/bin/env python3
"""Update a blog project's writing-identity selection atomically."""

from __future__ import annotations

import argparse
import json
import os
import stat
import sys
import tempfile
from pathlib import Path

CURRENT_USER_PREFIXES = tuple(
    f"~{separator}" for separator in (os.sep, os.altsep) if separator
)


class ConfigError(ValueError):
    """The existing selection record is invalid."""


class ToolError(RuntimeError):
    """The selection record could not be read or written."""


def inside(base: Path, candidate: Path) -> bool:
    try:
        candidate.relative_to(base)
        return True
    except ValueError:
        return False


def selection_target(config_path: Path, blog_home: Path) -> Path | None:
    """Resolve an existing selection file without crossing the project boundary."""
    try:
        config_path.lstat()
    except FileNotFoundError:
        try:
            prospective = config_path.resolve(strict=False)
        except RuntimeError as exc:
            raise ConfigError(
                f"identity config path has a symlink loop: {config_path}"
            ) from exc
        except OSError as exc:
            raise ToolError(
                f"cannot resolve identity config path {config_path}: {exc}"
            ) from exc
        if not inside(blog_home, prospective):
            raise ConfigError(f"identity config path escapes blog home: {prospective}")
        return None
    except OSError as exc:
        raise ToolError(f"cannot inspect {config_path}: {exc}") from exc

    try:
        target = config_path.resolve(strict=True)
    except FileNotFoundError as exc:
        raise ConfigError(
            f"identity config is a dangling symlink: {config_path}"
        ) from exc
    except RuntimeError as exc:
        raise ConfigError(f"identity config has a symlink loop: {config_path}") from exc
    except OSError as exc:
        raise ToolError(f"cannot resolve identity config {config_path}: {exc}") from exc
    if not inside(blog_home, target):
        raise ConfigError(f"identity config path escapes blog home: {target}")

    try:
        target_mode = target.stat().st_mode
    except OSError as exc:
        raise ToolError(f"cannot inspect identity config {target}: {exc}") from exc
    if not stat.S_ISREG(target_mode):
        raise ConfigError(f"identity config is not a regular file: {target}")
    return target


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


def write_config(config_path: Path, target: Path, config: dict) -> None:
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
        target = selection_target(config_path, blog_home)
        config: dict[str, object] = (
            load_config(target) if target else {"schema_version": 1}
        )

        for key, raw in (("personal", args.personal), ("corporate", args.corporate)):
            if raw is None:
                continue
            if raw:
                if (
                    raw.startswith("~")
                    and raw != "~"
                    and not raw.startswith(CURRENT_USER_PREFIXES)
                ):
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
    except ConfigError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    except ToolError as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
