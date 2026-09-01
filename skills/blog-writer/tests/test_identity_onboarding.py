#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SKILL_ROOT = ROOT / "skills/blog-writer"
SETUP = SKILL_ROOT / "setup-identity-root.py"
DISCOVER = SKILL_ROOT / "discover-identities.py"
CONFIGURER = SKILL_ROOT / "configure-identities.py"
RESOLVER = SKILL_ROOT / "resolve-identities.py"


def make_identity(
    root: Path, kind: str, name: str, *, status: str = "approved"
) -> Path:
    package = root / kind / name
    package.mkdir(parents=True)
    package.joinpath("identity.md").write_text(f"# {name}\n", encoding="utf-8")
    package.joinpath("guide.md").write_text(f"# {kind}\n", encoding="utf-8")
    package.joinpath("sources.md").write_text("# Sources\n", encoding="utf-8")
    role = "voice" if kind == "personal" else "brand"
    package.joinpath("identity.json").write_text(
        json.dumps(
            {
                "schema_version": 1,
                "type": kind,
                "name": name,
                "status": status,
                "entrypoint": "identity.md",
                "resources": [{"role": role, "path": "guide.md"}],
                "sources": "sources.md",
            }
        ),
        encoding="utf-8",
    )
    return package


class IdentityOnboardingTests(unittest.TestCase):
    def run_setup(self, home: Path, *args: str) -> subprocess.CompletedProcess[str]:
        environment = dict(os.environ)
        environment["HOME"] = str(home)
        return subprocess.run(
            ["python3", str(SETUP), *args],
            text=True,
            capture_output=True,
            check=False,
            env=environment,
            cwd=home,
        )

    def run_tool(self, script: Path, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(script), *args],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_probe_reports_missing_root_without_creating_it(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)

            result = self.run_setup(home, "--probe")

            self.assertEqual(result.returncode, 0, result.stderr)
            parsed = json.loads(result.stdout)
            self.assertFalse(parsed["exists"])
            self.assertEqual(parsed["kind"], "none")
            self.assertEqual(parsed["action"], "probed")
            self.assertFalse(home.joinpath(".claude").exists())

    def test_default_setup_creates_root_and_package_directories(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)

            result = self.run_setup(home)

            self.assertEqual(result.returncode, 0, result.stderr)
            parsed = json.loads(result.stdout)
            canonical = home / ".claude/blog-writer-identities"
            self.assertEqual(parsed["action"], "created")
            self.assertEqual(parsed["kind"], "directory")
            self.assertTrue(canonical.joinpath("personal").is_dir())
            self.assertTrue(canonical.joinpath("corporate").is_dir())

    def test_custom_setup_links_canonical_root_to_shared_directory(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw) / "home"
            home.mkdir()
            shared = Path(raw) / "shared"

            result = self.run_setup(home, "--target", str(shared))

            self.assertEqual(result.returncode, 0, result.stderr)
            parsed = json.loads(result.stdout)
            canonical = home / ".claude/blog-writer-identities"
            self.assertEqual(parsed["action"], "linked")
            self.assertEqual(parsed["kind"], "symlink")
            self.assertTrue(canonical.is_symlink())
            self.assertEqual(canonical.resolve(), shared.resolve())
            self.assertTrue(shared.joinpath("personal").is_dir())
            self.assertTrue(shared.joinpath("corporate").is_dir())

    def test_custom_setup_rejects_canonical_root_as_target_before_creating(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw) / "home"
            home.mkdir()
            canonical = home / ".claude/blog-writer-identities"

            result = self.run_setup(home, "--target", str(canonical))

            self.assertEqual(result.returncode, 1)
            self.assertIn("must be outside canonical identity root", result.stderr)
            self.assertFalse(home.joinpath(".claude").exists())
            self.assertFalse(canonical.exists())

    def test_custom_setup_rejects_nested_target_before_creating(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw) / "home"
            home.mkdir()
            canonical = home / ".claude/blog-writer-identities"
            nested = canonical / "shared"

            result = self.run_setup(home, "--target", str(nested))

            self.assertEqual(result.returncode, 1)
            self.assertIn("must be outside canonical identity root", result.stderr)
            self.assertFalse(home.joinpath(".claude").exists())
            self.assertFalse(canonical.exists())
            self.assertFalse(nested.exists())

    def test_custom_setup_rejects_unknown_named_user_before_creating(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw) / "home"
            home.mkdir()
            literal_target = home / "~blog-writer-missing-user/identities"

            result = self.run_setup(
                home,
                "--target",
                "~blog-writer-missing-user/identities",
            )

            self.assertEqual(result.returncode, 1)
            self.assertIn("invalid shared identity directory", result.stderr)
            self.assertFalse(home.joinpath(".claude").exists())
            self.assertFalse(literal_target.exists())

    def test_existing_directory_is_prepared_then_left_unchanged(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            canonical = home / ".claude/blog-writer-identities"
            canonical.mkdir(parents=True)

            first = self.run_setup(home)
            second = self.run_setup(home)

            self.assertEqual(first.returncode, 0, first.stderr)
            self.assertEqual(json.loads(first.stdout)["action"], "prepared")
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertEqual(json.loads(second.stdout)["action"], "unchanged")

    def test_occupied_package_directory_stops_before_layout_changes(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            canonical = home / ".claude/blog-writer-identities"
            canonical.mkdir(parents=True)
            canonical.joinpath("corporate").write_text("occupied\n", encoding="utf-8")

            result = self.run_setup(home)

            self.assertEqual(result.returncode, 1)
            self.assertIn("corporate identity directory", result.stderr)
            self.assertFalse(canonical.joinpath("personal").exists())
            self.assertEqual(
                canonical.joinpath("corporate").read_text(encoding="utf-8"),
                "occupied\n",
            )

    def test_existing_symlink_is_never_repointed(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw) / "home"
            home.mkdir()
            first = Path(raw) / "first"
            second = Path(raw) / "second"
            initial = self.run_setup(home, "--target", str(first))
            self.assertEqual(initial.returncode, 0, initial.stderr)

            result = self.run_setup(home, "--target", str(second))

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(result.stdout)["action"], "unchanged")
            self.assertEqual(
                home.joinpath(".claude/blog-writer-identities").resolve(),
                first.resolve(),
            )
            self.assertFalse(second.exists())

    def test_dangling_canonical_symlink_is_reported_and_preserved(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            canonical = home / ".claude/blog-writer-identities"
            canonical.parent.mkdir(parents=True)
            canonical.symlink_to(home / "missing", target_is_directory=True)

            result = self.run_setup(home, "--probe")

            self.assertEqual(result.returncode, 1)
            self.assertIn("target is missing", result.stderr)
            self.assertTrue(canonical.is_symlink())

    def test_file_at_canonical_path_is_reported_and_preserved(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            canonical = home / ".claude/blog-writer-identities"
            canonical.parent.mkdir(parents=True)
            canonical.write_text("occupied\n", encoding="utf-8")

            result = self.run_setup(home)

            self.assertEqual(result.returncode, 1)
            self.assertIn("not a directory", result.stderr)
            self.assertEqual(canonical.read_text(encoding="utf-8"), "occupied\n")

    def test_file_at_requested_target_is_rejected_before_linking(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw) / "home"
            home.mkdir()
            target = Path(raw) / "shared"
            target.write_text("occupied\n", encoding="utf-8")

            result = self.run_setup(home, "--target", str(target))

            self.assertEqual(result.returncode, 1)
            self.assertIn("shared identity directory", result.stderr)
            self.assertFalse(home.joinpath(".claude/blog-writer-identities").exists())

    def test_dangling_requested_target_is_rejected_without_repairing_it(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw) / "home"
            home.mkdir()
            target = Path(raw) / "shared"
            target.symlink_to(Path(raw) / "missing", target_is_directory=True)

            result = self.run_setup(home, "--target", str(target))

            self.assertEqual(result.returncode, 1)
            self.assertIn("target is missing", result.stderr)
            self.assertTrue(target.is_symlink())
            self.assertFalse(Path(raw).joinpath("missing").exists())
            self.assertFalse(home.joinpath(".claude/blog-writer-identities").exists())

    def test_legacy_symlink_is_discovered_without_modification(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw) / "home"
            home.mkdir()
            legacy_target = Path(raw) / "legacy"
            legacy_target.mkdir()
            legacy_target.joinpath("voice.md").write_text(
                "Legacy voice\n", encoding="utf-8"
            )
            legacy_link = home / ".claude/blog-writer-persona"
            legacy_link.parent.mkdir(parents=True)
            legacy_link.symlink_to(legacy_target, target_is_directory=True)

            result = self.run_setup(home, "--probe")

            self.assertEqual(result.returncode, 0, result.stderr)
            legacy = json.loads(result.stdout)["legacy"]
            self.assertEqual(legacy["kind"], "symlink")
            self.assertTrue(legacy["migration_ready"])
            self.assertEqual(legacy["target"], str(legacy_target.resolve()))
            self.assertTrue(legacy_link.is_symlink())
            self.assertEqual(legacy_link.resolve(), legacy_target.resolve())

            setup = self.run_setup(home)
            self.assertEqual(setup.returncode, 0, setup.stderr)
            self.assertTrue(legacy_link.is_symlink())
            self.assertEqual(legacy_link.resolve(), legacy_target.resolve())
            self.assertEqual(
                legacy_target.joinpath("voice.md").read_text(encoding="utf-8"),
                "Legacy voice\n",
            )

    def test_probe_rejects_target_argument(self):
        with tempfile.TemporaryDirectory() as raw:
            result = self.run_setup(Path(raw), "--probe", "--target", "shared")

            self.assertEqual(result.returncode, 2)
            self.assertIn("probing changes nothing", result.stderr)

    def test_discovery_lists_only_manifest_valid_candidates(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            personal = make_identity(root, "personal", "jbaruch")
            corporate = make_identity(root, "corporate", "port")
            invalid = root / "personal/broken"
            invalid.mkdir()
            invalid.joinpath("identity.json").write_text("{}\n", encoding="utf-8")

            result = self.run_tool(DISCOVER, "--root", str(root))

            self.assertEqual(result.returncode, 0, result.stderr)
            parsed = json.loads(result.stdout)
            self.assertEqual(
                parsed["personal"],
                [
                    {
                        "name": "jbaruch",
                        "status": "approved",
                        "path": str(personal.resolve()),
                    }
                ],
            )
            self.assertEqual(
                parsed["corporate"],
                [
                    {
                        "name": "port",
                        "status": "approved",
                        "path": str(corporate.resolve()),
                    }
                ],
            )
            self.assertEqual(len(parsed["invalid"]), 1)
            self.assertEqual(parsed["invalid"][0]["path"], str(invalid.resolve()))

    def test_discovery_missing_root_reports_setup_action(self):
        with tempfile.TemporaryDirectory() as raw:
            missing = Path(raw) / "missing"

            result = self.run_tool(DISCOVER, "--root", str(missing))

            self.assertEqual(result.returncode, 1)
            self.assertIn("identity root does not exist", result.stderr)
            self.assertIn("run setup-identity-root.py", result.stderr)
            self.assertIn("--root", result.stderr)
            self.assertFalse(missing.exists())

    def test_discovery_handles_zero_one_and_multiple_candidates(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            root.joinpath("personal").mkdir()
            root.joinpath("corporate").mkdir()
            first = self.run_tool(DISCOVER, "--root", str(root))
            self.assertEqual(first.returncode, 0, first.stderr)
            self.assertEqual(json.loads(first.stdout)["personal"], [])

            make_identity(root, "personal", "one")
            second = self.run_tool(DISCOVER, "--root", str(root))
            self.assertEqual(len(json.loads(second.stdout)["personal"]), 1)

            make_identity(root, "personal", "two")
            third = self.run_tool(DISCOVER, "--root", str(root))
            self.assertEqual(
                [item["name"] for item in json.loads(third.stdout)["personal"]],
                ["one", "two"],
            )

    def test_discovery_rejects_package_symlink_outside_root(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw) / "identities"
            outside = Path(raw) / "outside"
            root.joinpath("personal").mkdir(parents=True)
            make_identity(Path(raw), "outside", "writer")
            source = outside / "writer"
            source_manifest = json.loads(
                source.joinpath("identity.json").read_text(encoding="utf-8")
            )
            source_manifest["type"] = "personal"
            source.joinpath("identity.json").write_text(
                json.dumps(source_manifest), encoding="utf-8"
            )
            root.joinpath("personal/writer").symlink_to(
                source, target_is_directory=True
            )

            result = self.run_tool(DISCOVER, "--root", str(root))

            self.assertEqual(result.returncode, 0, result.stderr)
            parsed = json.loads(result.stdout)
            self.assertEqual(parsed["personal"], [])
            self.assertIn("escapes", parsed["invalid"][0]["error"])

    def test_clean_project_selects_shared_candidates_once(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            home = root / "home"
            blog = root / "blog"
            shared = root / "shared-identities"
            home.mkdir()
            blog.mkdir()
            setup = self.run_setup(home, "--target", str(shared))
            self.assertEqual(setup.returncode, 0, setup.stderr)
            resolved_root = json.loads(setup.stdout)["target"]
            personal = make_identity(shared, "personal", "jbaruch")
            corporate = make_identity(shared, "corporate", "port")

            discovered = self.run_tool(DISCOVER, "--root", resolved_root)
            self.assertEqual(discovered.returncode, 0, discovered.stderr)
            candidates = json.loads(discovered.stdout)
            self.assertEqual(
                [item["name"] for item in candidates["personal"]], ["jbaruch"]
            )
            self.assertEqual(
                [item["name"] for item in candidates["corporate"]], ["port"]
            )
            self.assertFalse(blog.joinpath("_blog-skill/identity.json").exists())

            configured = self.run_tool(
                CONFIGURER,
                "--blog-home",
                str(blog),
                "--personal",
                str(personal),
                "--corporate",
                str(corporate),
            )
            self.assertEqual(configured.returncode, 0, configured.stderr)
            config = json.loads(
                blog.joinpath("_blog-skill/identity.json").read_text(encoding="utf-8")
            )
            self.assertEqual(config["schema_version"], 2)

            first_resolution = self.run_tool(
                RESOLVER,
                "--blog-home",
                str(blog),
                "--legacy-persona",
                str(root / "none"),
            )
            second_resolution = self.run_tool(
                RESOLVER,
                "--blog-home",
                str(blog),
                "--legacy-persona",
                str(root / "none"),
            )
            self.assertEqual(first_resolution.returncode, 0, first_resolution.stderr)
            self.assertEqual(second_resolution.returncode, 0, second_resolution.stderr)
            for result in (first_resolution, second_resolution):
                parsed = json.loads(result.stdout)
                self.assertEqual(parsed["personal"]["name"], "jbaruch")
                self.assertEqual(parsed["corporate"]["name"], "port")
                self.assertIsNotNone(parsed["config"])

    def test_importing_new_tools_runs_nothing(self):
        for script in (SETUP, DISCOVER):
            with self.subTest(script=script.name):
                result = subprocess.run(
                    [
                        "python3",
                        "-c",
                        (
                            "import runpy,sys; "
                            "sys.path.insert(0, str(__import__('pathlib').Path(sys.argv[1]).parent)); "
                            "runpy.run_path(sys.argv[1], run_name='test_import')"
                        ),
                        str(script),
                    ],
                    text=True,
                    capture_output=True,
                    check=False,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, "")
                self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
