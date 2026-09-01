#!/usr/bin/env python3
"""Resolve v1 writing identities with a legacy persona fallback."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
ROLE_RE = NAME_RE


class IdentityError(ValueError):
    """Selected identity or project configuration is invalid."""


class ToolError(RuntimeError):
    """The resolver could not inspect the selected files."""


def inside(base: Path, candidate: Path) -> bool:
    try:
        candidate.relative_to(base)
        return True
    except ValueError:
        return False


def load_json(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise IdentityError(f"missing file: {path}") from exc
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise IdentityError(f"invalid JSON {path}: {exc}") from exc
    except OSError as exc:
        raise ToolError(f"cannot read {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise IdentityError(f"expected a JSON object: {path}")
    return value


def resolve_relative(raw: str, base: Path) -> Path:
    path = Path(raw).expanduser()
    if not path.is_absolute():
        path = base / path
    try:
        return path.resolve()
    except OSError as exc:
        raise ToolError(f"cannot resolve path {path}: {exc}") from exc


def validate_identity(raw_path: str, expected_type: str, base: Path) -> dict:
    root = resolve_relative(raw_path, base)
    manifest_path = root / "identity.json"
    manifest = load_json(manifest_path)
    errors: list[str] = []
    if manifest.get("schema_version") != 1:
        errors.append("schema_version must be 1")
    if manifest.get("type") != expected_type:
        errors.append(f"type must be {expected_type!r}")
    name = manifest.get("name")
    if not isinstance(name, str) or not NAME_RE.fullmatch(name):
        errors.append("name must be lowercase kebab-case")
    if manifest.get("status") not in {"draft", "approved"}:
        errors.append("status must be 'draft' or 'approved'")
    if manifest.get("entrypoint") != "identity.md":
        errors.append("entrypoint must be 'identity.md'")
    if manifest.get("sources") != "sources.md":
        errors.append("sources must be 'sources.md'")

    files: list[dict] = []

    def add_file(role: str, raw: object) -> None:
        if not isinstance(raw, str) or not raw:
            errors.append(f"{role} path must be a non-empty string")
            return
        candidate = resolve_relative(raw, root)
        if not inside(root, candidate):
            errors.append(f"{role} path escapes identity directory: {raw}")
        elif not candidate.is_file():
            errors.append(f"missing {role} file: {candidate}")
        else:
            files.append({"role": role, "path": str(candidate)})

    add_file("entrypoint", manifest.get("entrypoint"))
    resources = manifest.get("resources", [])
    if not isinstance(resources, list):
        errors.append("resources must be a list")
    else:
        for index, resource in enumerate(resources):
            if not isinstance(resource, dict):
                errors.append(f"resources[{index}] must be an object")
                continue
            role = resource.get("role")
            if not isinstance(role, str) or not ROLE_RE.fullmatch(role):
                errors.append(f"resources[{index}].role must be lowercase kebab-case")
                continue
            add_file(role, resource.get("path"))
    add_file("sources", manifest.get("sources"))

    if errors:
        raise IdentityError(
            f"invalid {expected_type} identity at {root}: " + "; ".join(errors)
        )
    return {
        "mode": "v1",
        "root": str(root),
        "name": name,
        "status": manifest["status"],
        "files": files,
    }


def legacy_persona(path: Path) -> dict | None:
    voice = path / "voice.md"
    try:
        if not voice.is_file():
            return None
        if not voice.read_text(encoding="utf-8").strip():
            return None
    except UnicodeError as exc:
        raise IdentityError(f"legacy voice is not UTF-8: {voice}") from exc
    except OSError as exc:
        raise ToolError(f"cannot read legacy voice {voice}: {exc}") from exc

    files = []
    for role, name in (
        ("voice", "voice.md"),
        ("composition", "framework.md"),
        ("examples", "examples.md"),
        ("bio", "bio.md"),
        ("legacy-product-context", "product.md"),
    ):
        candidate = path / name
        try:
            if candidate.is_file() and candidate.stat().st_size:
                files.append({"role": role, "path": str(candidate.resolve())})
        except OSError as exc:
            raise ToolError(f"cannot inspect legacy file {candidate}: {exc}") from exc
    return {
        "mode": "legacy",
        "root": str(path.resolve()),
        "name": "legacy-persona",
        "status": "approved",
        "files": files,
    }


def load_config(path: Path) -> dict:
    config = load_json(path)
    errors = []
    if config.get("schema_version") != 1:
        errors.append("schema_version must be 1")
    for key in ("personal", "corporate"):
        if key in config and (not isinstance(config[key], str) or not config[key]):
            errors.append(f"{key} must be a non-empty path string when present")
    if errors:
        raise IdentityError(f"invalid identity config {path}: " + "; ".join(errors))
    return config


def path_present(path: Path) -> bool:
    """Return whether path exists without hiding inspection failures."""
    try:
        path.lstat()
    except FileNotFoundError:
        return False
    except OSError as exc:
        raise ToolError(f"cannot inspect {path}: {exc}") from exc
    return True


def read_paths(*identities: dict | None) -> list[str]:
    ordered: list[str] = []
    seen: set[str] = set()
    for identity in identities:
        if not identity:
            continue
        for item in identity["files"]:
            path = item["path"]
            if path not in seen:
                ordered.append(path)
                seen.add(path)
    return ordered


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--blog-home", required=True)
    parser.add_argument("--personal")
    parser.add_argument("--corporate")
    parser.add_argument(
        "--legacy-persona",
        default=str(Path.home() / ".claude" / "blog-writer-persona"),
    )
    args = parser.parse_args()

    try:
        blog_home = Path(args.blog_home).expanduser().resolve()
        state_dir = blog_home / "_blog-skill"
        config_path = state_dir / "identity.json"
        config_present = path_present(config_path)
        config = load_config(config_path) if config_present else {}

        personal_explicit = args.personal is not None
        corporate_explicit = args.corporate is not None

        if personal_explicit:
            personal = (
                validate_identity(args.personal, "personal", state_dir)
                if args.personal
                else None
            )
        elif config_present:
            personal_raw = config.get("personal")
            personal = (
                validate_identity(personal_raw, "personal", state_dir)
                if personal_raw
                else None
            )
        else:
            personal = legacy_persona(Path(args.legacy_persona).expanduser())

        corporate_raw = (
            args.corporate if corporate_explicit else config.get("corporate")
        )
        corporate = (
            validate_identity(corporate_raw, "corporate", state_dir)
            if corporate_raw
            else None
        )

        if not personal and not corporate:
            raise IdentityError(
                "no writing identity selected and no ready legacy persona found; run an "
                "identity creator or configure _blog-skill/identity.json"
            )

        result = {
            "ok": True,
            "config": str(config_path) if config_present else None,
            "personal": personal,
            "corporate": corporate,
            "read_order": read_paths(personal, corporate),
        }
        print(json.dumps(result, indent=2))
        return 0
    except IdentityError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    except ToolError as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
