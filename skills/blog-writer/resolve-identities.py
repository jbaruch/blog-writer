#!/usr/bin/env python3
"""Resolve v1 writing identities with a legacy persona fallback."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import cast

from identity_lib import (
    IdentityError,
    ToolError,
    legacy_persona,
    load_selection_config,
    read_paths,
    resolve_relative,
    selection_target,
    validate_identity,
)


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
        blog_home = resolve_relative(args.blog_home, Path.cwd())
        state_dir = blog_home / "_blog-skill"
        config_path = state_dir / "identity.json"
        target = selection_target(config_path, blog_home)
        config_present = target is not None
        config = load_selection_config(target) if target else {"schema_version": 2}
        config_version = config["schema_version"]

        personal_explicit = args.personal is not None
        corporate_explicit = args.corporate is not None

        if personal_explicit:
            personal = (
                validate_identity(args.personal, "personal", state_dir)
                if args.personal
                else None
            )
        elif config_present:
            personal_raw = cast(str | None, config.get("personal"))
            personal = (
                validate_identity(
                    personal_raw,
                    "personal",
                    state_dir,
                    allow_named_user=config_version == 1,
                )
                if personal_raw
                else None
            )
        else:
            personal = legacy_persona(resolve_relative(args.legacy_persona, Path.cwd()))

        corporate_raw = cast(
            str | None,
            args.corporate if corporate_explicit else config.get("corporate"),
        )
        corporate = (
            validate_identity(
                corporate_raw,
                "corporate",
                state_dir,
                allow_named_user=not corporate_explicit and config_version == 1,
            )
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
