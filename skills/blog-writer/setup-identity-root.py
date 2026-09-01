#!/usr/bin/env python3
"""Probe or establish the canonical shared writing-identity root.

The canonical path is ``$HOME/.claude/blog-writer-identities``. It may be a real
directory or a symlink to a user-selected shared directory. The script never
repoints an established root and never modifies the legacy persona path.

Exit 0 prints one JSON object describing the root, its personal and corporate
package directories, the action, and the legacy persona state. Exit 1 means a
requested path exists in an unusable shape. Exit 2 means invocation or I/O failed.
"""

from __future__ import annotations

import argparse
import json
import stat
import sys
from pathlib import Path


class StorageError(ValueError):
    """A storage path exists in an unusable shape."""


class ToolError(RuntimeError):
    """The storage lifecycle could not inspect or create a path."""


def inspect_path(path: Path, *, check_voice: bool = False) -> dict[str, object]:
    try:
        mode = path.lstat().st_mode
    except FileNotFoundError:
        return {
            "path": str(path),
            "exists": False,
            "usable": False,
            "kind": "none",
            "target": None,
            "migration_ready": False,
        }
    except OSError as exc:
        raise ToolError(f"cannot inspect {path}: {exc}") from exc

    kind = "directory"
    usable = True
    target: Path | None = path
    if stat.S_ISLNK(mode):
        try:
            target = path.resolve(strict=True)
        except FileNotFoundError:
            kind = "dangling-symlink"
            usable = False
            target = None
        except RuntimeError:
            kind = "symlink-loop"
            usable = False
            target = None
        except OSError as exc:
            raise ToolError(f"cannot resolve symlink {path}: {exc}") from exc
        else:
            try:
                if stat.S_ISDIR(target.stat().st_mode):
                    kind = "symlink"
                else:
                    kind = "symlink-to-file"
                    usable = False
            except OSError as exc:
                raise ToolError(
                    f"cannot inspect symlink target {target}: {exc}"
                ) from exc
    elif stat.S_ISDIR(mode):
        try:
            target = path.resolve(strict=True)
        except OSError as exc:
            raise ToolError(f"cannot resolve directory {path}: {exc}") from exc
    else:
        kind = "file"
        usable = False
        try:
            target = path.resolve(strict=False)
        except (OSError, RuntimeError) as exc:
            raise ToolError(f"cannot resolve occupied path {path}: {exc}") from exc

    migration_ready = False
    diagnostic: str | None = None
    if check_voice and usable and target is not None:
        voice = target / "voice.md"
        try:
            voice_mode = voice.stat().st_mode
        except FileNotFoundError:
            pass
        except OSError as exc:
            raise ToolError(f"cannot inspect legacy voice {voice}: {exc}") from exc
        else:
            if stat.S_ISREG(voice_mode):
                try:
                    migration_ready = bool(voice.read_text(encoding="utf-8").strip())
                except UnicodeError:
                    diagnostic = f"legacy voice is not UTF-8: {voice}"
                except OSError as exc:
                    raise ToolError(f"cannot read legacy voice {voice}: {exc}") from exc

    result: dict[str, object] = {
        "path": str(path),
        "exists": True,
        "usable": usable,
        "kind": kind,
        "target": str(target) if target is not None else None,
        "migration_ready": migration_ready,
    }
    if diagnostic:
        result["diagnostic"] = diagnostic
    return result


def reject_unusable(state: dict[str, object], label: str) -> None:
    if not state["exists"] or state["usable"]:
        return
    kind = state["kind"]
    path = state["path"]
    if kind == "dangling-symlink":
        raise StorageError(
            f"{label} {path} is a symlink whose target is missing; repair or remove "
            "the link, then re-run"
        )
    if kind == "symlink-loop":
        raise StorageError(
            f"{label} {path} is a symlink loop; repair or remove the link, then re-run"
        )
    raise StorageError(
        f"{label} {path} is {kind}, not a directory; move it aside, then re-run"
    )


def ensure_directory(path: Path, label: str) -> bool:
    state = inspect_path(path)
    reject_unusable(state, label)
    if state["exists"]:
        return False
    try:
        path.mkdir(parents=True)
    except OSError as exc:
        raise ToolError(f"cannot create {label} {path}: {exc}") from exc
    return True


def ensure_layout(root: Path) -> bool:
    try:
        resolved_root = root.resolve(strict=True)
    except (OSError, RuntimeError) as exc:
        raise ToolError(f"cannot resolve identity root {root}: {exc}") from exc
    missing: list[tuple[Path, str]] = []
    for kind in ("personal", "corporate"):
        kind_path = resolved_root / kind
        state = inspect_path(kind_path)
        reject_unusable(state, f"{kind} identity directory")
        if state["exists"]:
            target_raw = state["target"]
            if not isinstance(target_raw, str):
                raise ToolError(f"{kind} identity directory has no target: {kind_path}")
            try:
                Path(target_raw).relative_to(resolved_root)
            except ValueError as exc:
                raise StorageError(
                    f"{kind} identity directory escapes the shared root: {kind_path}"
                ) from exc
            continue
        missing.append((kind_path, f"{kind} identity directory"))
    for path, label in missing:
        ensure_directory(path, label)
    return bool(missing)


def emit(
    canonical: Path,
    root_state: dict[str, object],
    legacy_state: dict[str, object],
    action: str,
) -> None:
    target_raw = root_state["target"]
    target = Path(target_raw) if isinstance(target_raw, str) else None
    print(
        json.dumps(
            {
                "ok": True,
                "path": str(canonical),
                "exists": root_state["exists"],
                "kind": root_state["kind"],
                "target": target_raw,
                "personal_root": str(target / "personal") if target else None,
                "corporate_root": str(target / "corporate") if target else None,
                "action": action,
                "legacy": legacy_state,
            }
        )
    )


def requested_target(raw: str) -> Path:
    try:
        target = Path(raw).expanduser()
        if not target.is_absolute():
            target = Path.cwd() / target
        return target.absolute()
    except (RuntimeError, ValueError) as exc:
        raise StorageError(f"invalid shared identity directory {raw!r}: {exc}") from exc
    except OSError as exc:
        raise ToolError(
            f"cannot resolve shared identity directory {raw!r}: {exc}"
        ) from exc


def reject_target_within_canonical(target: Path, canonical: Path) -> None:
    try:
        resolved_target = target.resolve(strict=False)
        resolved_canonical = canonical.resolve(strict=False)
    except (OSError, RuntimeError) as exc:
        raise ToolError(
            f"cannot compare shared identity directory {target} with canonical "
            f"identity root {canonical}: {exc}"
        ) from exc

    try:
        resolved_target.relative_to(resolved_canonical)
    except ValueError:
        return
    raise StorageError(
        f"shared identity directory {target} must be outside canonical identity root "
        f"{canonical}; choose a different directory, then re-run"
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--probe", action="store_true")
    parser.add_argument("--target")
    args = parser.parse_args()
    if args.probe and args.target is not None:
        parser.error("--probe takes no --target; probing changes nothing")

    canonical = Path.home() / ".claude" / "blog-writer-identities"
    legacy = Path.home() / ".claude" / "blog-writer-persona"

    try:
        root_state = inspect_path(canonical)
        reject_unusable(root_state, "canonical identity root")
        legacy_state = inspect_path(legacy, check_voice=True)

        if args.probe:
            emit(canonical, root_state, legacy_state, "probed")
            return 0

        if root_state["exists"]:
            target_raw = root_state["target"]
            if not isinstance(target_raw, str):
                raise ToolError(f"canonical identity root has no target: {canonical}")
            changed = ensure_layout(Path(target_raw))
            root_state = inspect_path(canonical)
            emit(
                canonical,
                root_state,
                legacy_state,
                "prepared" if changed else "unchanged",
            )
            return 0

        target: Path | None = None
        if args.target is not None:
            target = requested_target(args.target)
            reject_target_within_canonical(target, canonical)

        try:
            canonical.parent.mkdir(parents=True, exist_ok=True)
        except OSError as exc:
            raise ToolError(
                f"cannot create canonical identity parent {canonical.parent}: {exc}"
            ) from exc

        if target is not None:
            ensure_directory(target, "shared identity directory")
            target_state = inspect_path(target)
            resolved_target_raw = target_state["target"]
            if not isinstance(resolved_target_raw, str):
                raise ToolError(f"shared identity directory has no target: {target}")
            resolved_target = Path(resolved_target_raw)
            ensure_layout(resolved_target)
            try:
                canonical.symlink_to(resolved_target, target_is_directory=True)
            except OSError as exc:
                raise ToolError(
                    f"cannot link {canonical} to {resolved_target}: {exc}"
                ) from exc
            action = "linked"
        else:
            ensure_directory(canonical, "canonical identity root")
            ensure_layout(canonical)
            action = "created"

        root_state = inspect_path(canonical)
        emit(canonical, root_state, legacy_state, action)
        return 0
    except StorageError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    except ToolError as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
