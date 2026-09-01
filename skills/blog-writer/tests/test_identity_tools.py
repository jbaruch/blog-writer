#!/usr/bin/env python3

from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RESOLVER = ROOT / "skills/blog-writer/resolve-identities.py"
CONFIGURER = ROOT / "skills/blog-writer/configure-identities.py"


def make_identity(
    state: Path,
    kind: str,
    name: str,
    *,
    resources: list[dict[str, str]] | None = None,
    status: str = "approved",
) -> Path:
    root = state / "identities" / kind / name
    root.mkdir(parents=True)
    (root / "identity.md").write_text(f"# {name}\n", encoding="utf-8")
    (root / "guide.md").write_text(f"# {kind} guide\n", encoding="utf-8")
    (root / "sources.md").write_text("# Sources\n", encoding="utf-8")
    role = "voice" if kind == "personal" else "brand"
    manifest = {
        "schema_version": 1,
        "type": kind,
        "name": name,
        "status": status,
        "entrypoint": "identity.md",
        "resources": resources or [{"role": role, "path": "guide.md"}],
        "sources": "sources.md",
    }
    (root / "identity.json").write_text(json.dumps(manifest), encoding="utf-8")
    return root


class IdentityToolTests(unittest.TestCase):
    def run_tool(
        self, script: Path, home: Path, *args: str
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(script), "--blog-home", str(home), *args],
            text=True,
            capture_output=True,
            check=False,
        )

    def run_resolver(self, home: Path, *args: str) -> dict:
        result = self.run_tool(
            RESOLVER,
            home,
            "--legacy-persona",
            str(home / "missing-legacy"),
            *args,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)

    def test_personal_only_flow(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            personal = make_identity(state, "personal", "writer")
            state.joinpath("identity.json").write_text(
                json.dumps({"schema_version": 1, "personal": str(personal)}),
                encoding="utf-8",
            )

            result = self.run_resolver(home)

            self.assertEqual(result["personal"]["name"], "writer")
            self.assertIsNone(result["corporate"])

    def test_corporate_only_config_suppresses_legacy_persona(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            corporate = make_identity(state, "corporate", "acme")
            state.joinpath("identity.json").write_text(
                json.dumps({"schema_version": 1, "corporate": str(corporate)}),
                encoding="utf-8",
            )
            legacy = home / "legacy"
            legacy.mkdir()
            legacy.joinpath("voice.md").write_text("legacy voice", encoding="utf-8")

            result = self.run_tool(RESOLVER, home, "--legacy-persona", str(legacy))

            self.assertEqual(result.returncode, 0, result.stderr)
            parsed = json.loads(result.stdout)
            self.assertIsNone(parsed["personal"])
            self.assertEqual(parsed["corporate"]["name"], "acme")

    def test_missing_config_uses_legacy_persona(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            legacy = home / "legacy"
            legacy.mkdir()
            legacy.joinpath("voice.md").write_text("legacy voice", encoding="utf-8")

            result = self.run_tool(RESOLVER, home, "--legacy-persona", str(legacy))

            self.assertEqual(result.returncode, 0, result.stderr)
            parsed = json.loads(result.stdout)
            self.assertEqual(parsed["personal"]["mode"], "legacy")
            self.assertIsNone(parsed["corporate"])

    def test_uninspectable_config_path_is_a_tool_error(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            home.joinpath("_blog-skill").write_text(
                "not a directory\n", encoding="utf-8"
            )
            legacy = home / "legacy"
            legacy.mkdir()
            legacy.joinpath("voice.md").write_text("legacy voice", encoding="utf-8")

            result = self.run_tool(RESOLVER, home, "--legacy-persona", str(legacy))

            self.assertEqual(result.returncode, 2)
            self.assertIn("cannot inspect", result.stderr)
            self.assertNotIn("legacy-persona", result.stdout)

    def test_resolver_rejects_config_symlink_outside_blog_home(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            home = root / "blog"
            state = home / "_blog-skill"
            state.mkdir(parents=True)
            outside = root / "outside.json"
            outside.write_text('{"schema_version": 1}\n', encoding="utf-8")
            state.joinpath("identity.json").symlink_to(outside)

            result = self.run_tool(RESOLVER, home)

            self.assertEqual(result.returncode, 1)
            self.assertIn("config path escapes blog home", result.stderr)

    def test_resolver_rejects_state_directory_symlink_outside_blog_home(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            home = root / "blog"
            home.mkdir()
            outside_state = root / "outside-state"
            outside_state.mkdir()
            home.joinpath("_blog-skill").symlink_to(
                outside_state, target_is_directory=True
            )

            result = self.run_tool(RESOLVER, home)

            self.assertEqual(result.returncode, 1)
            self.assertIn("config path escapes blog home", result.stderr)

    def test_combined_flow_orders_personal_before_corporate(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            personal = make_identity(state, "personal", "writer")
            corporate = make_identity(state, "corporate", "acme")
            state.joinpath("identity.json").write_text(
                json.dumps(
                    {
                        "schema_version": 1,
                        "personal": str(personal),
                        "corporate": str(corporate),
                    }
                ),
                encoding="utf-8",
            )

            result = self.run_resolver(home)

            first_corporate = result["read_order"].index(
                result["corporate"]["files"][0]["path"]
            )
            self.assertEqual(first_corporate, len(result["personal"]["files"]))

    def test_duplicate_resource_path_preserves_every_role_and_reads_once(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            corporate = make_identity(
                state,
                "corporate",
                "acme",
                resources=[
                    {"role": "brand", "path": "guide.md"},
                    {"role": "editorial-review", "path": "guide.md"},
                ],
            )
            state.joinpath("identity.json").write_text(
                json.dumps({"schema_version": 1, "corporate": str(corporate)}),
                encoding="utf-8",
            )

            result = self.run_resolver(home)

            roles = [item["role"] for item in result["corporate"]["files"]]
            guide = str((corporate / "guide.md").resolve())
            self.assertIn("brand", roles)
            self.assertIn("editorial-review", roles)
            self.assertEqual(result["read_order"].count(guide), 1)

    def test_resource_path_escape_is_rejected(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            corporate = make_identity(
                state,
                "corporate",
                "acme",
                resources=[{"role": "brand", "path": "../outside.md"}],
            )

            result = self.run_tool(RESOLVER, home, "--corporate", str(corporate))

            self.assertEqual(result.returncode, 1)
            self.assertIn("escapes identity directory", result.stderr)
            self.assertEqual(result.stdout, "")

    def test_absolute_resource_path_inside_identity_is_rejected(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            guide = state / "identities" / "personal" / "writer" / "guide.md"
            personal = make_identity(
                state,
                "personal",
                "writer",
                resources=[{"role": "voice", "path": str(guide)}],
            )

            result = self.run_tool(RESOLVER, home, "--personal", str(personal))

            self.assertEqual(result.returncode, 1)
            self.assertIn("voice path must be relative", result.stderr)
            self.assertEqual(result.stdout, "")

    def test_tilde_resource_path_is_rejected_without_user_lookup(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            personal = make_identity(
                state,
                "personal",
                "writer",
                resources=[{"role": "voice", "path": "~missing-user/guide.md"}],
            )

            result = self.run_tool(RESOLVER, home, "--personal", str(personal))

            self.assertEqual(result.returncode, 1)
            self.assertIn("voice path must be relative", result.stderr)
            self.assertEqual(result.stdout, "")

    def test_required_file_names_are_enforced(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            personal = make_identity(state, "personal", "writer")
            manifest_path = personal / "identity.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            manifest["entrypoint"] = "guide.md"
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")

            result = self.run_tool(RESOLVER, home, "--personal", str(personal))

            self.assertEqual(result.returncode, 1)
            self.assertIn("entrypoint must be 'identity.md'", result.stderr)

    def test_draft_status_is_returned_for_caller_approval(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            personal = make_identity(state, "personal", "writer", status="draft")

            result = self.run_resolver(home, "--personal", str(personal))

            self.assertEqual(result["personal"]["status"], "draft")

    def test_configurer_creates_corporate_only_selection(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            corporate = home / "corporate"

            result = self.run_tool(
                CONFIGURER,
                home,
                "--personal",
                "",
                "--corporate",
                str(corporate),
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            config = json.loads(
                (home / "_blog-skill/identity.json").read_text(encoding="utf-8")
            )
            self.assertNotIn("personal", config)
            self.assertEqual(config["corporate"], str(corporate))

    def test_configurer_preserves_unmentioned_selection(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            state.mkdir()
            state.joinpath("identity.json").write_text(
                json.dumps({"schema_version": 1, "personal": "/personal"}),
                encoding="utf-8",
            )

            result = self.run_tool(CONFIGURER, home, "--corporate", "/corporate")

            self.assertEqual(result.returncode, 0, result.stderr)
            config = json.loads(
                state.joinpath("identity.json").read_text(encoding="utf-8")
            )
            self.assertEqual(config["personal"], "/personal")
            self.assertEqual(config["corporate"], "/corporate")

    def test_configurer_rejects_invalid_existing_config_without_rewriting(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            state.mkdir()
            config_path = state / "identity.json"
            original = '{"schema_version": 2}\n'
            config_path.write_text(original, encoding="utf-8")

            result = self.run_tool(CONFIGURER, home, "--personal", "/personal")

            self.assertEqual(result.returncode, 1)
            self.assertIn("schema_version must be 1", result.stderr)
            self.assertEqual(config_path.read_text(encoding="utf-8"), original)

    def test_configurer_preserves_valid_symlink(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            state.mkdir()
            target = home / "shared-selection.json"
            target.write_text('{"schema_version": 1}\n', encoding="utf-8")
            config_path = state / "identity.json"
            config_path.symlink_to(target)

            result = self.run_tool(CONFIGURER, home, "--personal", "/personal")

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(config_path.is_symlink())
            self.assertEqual(
                json.loads(target.read_text(encoding="utf-8"))["personal"],
                "/personal",
            )

    def test_configurer_rejects_symlink_outside_blog_home(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            home = root / "blog"
            state = home / "_blog-skill"
            state.mkdir(parents=True)
            target = root / "outside.json"
            original = '{"schema_version": 1, "personal": "/original"}\n'
            target.write_text(original, encoding="utf-8")
            state.joinpath("identity.json").symlink_to(target)

            result = self.run_tool(CONFIGURER, home, "--personal", "/replacement")

            self.assertEqual(result.returncode, 1)
            self.assertIn("config path escapes blog home", result.stderr)
            self.assertEqual(target.read_text(encoding="utf-8"), original)

    def test_configurer_rejects_state_directory_symlink_outside_blog_home(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            home = root / "blog"
            home.mkdir()
            outside_state = root / "outside-state"
            outside_state.mkdir()
            home.joinpath("_blog-skill").symlink_to(
                outside_state, target_is_directory=True
            )

            result = self.run_tool(CONFIGURER, home, "--personal", "/personal")

            self.assertEqual(result.returncode, 1)
            self.assertIn("config path escapes blog home", result.stderr)
            self.assertFalse(outside_state.joinpath("identity.json").exists())

    def test_configurer_rejects_clearing_the_final_layer(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            state = home / "_blog-skill"
            state.mkdir()
            config_path = state / "identity.json"
            original = '{"schema_version": 1, "personal": "/personal"}\n'
            config_path.write_text(original, encoding="utf-8")

            result = self.run_tool(CONFIGURER, home, "--personal", "")

            self.assertEqual(result.returncode, 1)
            self.assertIn("must include personal or corporate", result.stderr)
            self.assertEqual(config_path.read_text(encoding="utf-8"), original)

    def test_configurer_requires_a_layer_argument(self):
        with tempfile.TemporaryDirectory() as raw:
            result = self.run_tool(CONFIGURER, Path(raw))

            self.assertEqual(result.returncode, 2)
            self.assertIn("at least one", result.stderr)

    def test_importing_tools_runs_nothing(self):
        for script in (RESOLVER, CONFIGURER):
            with self.subTest(script=script.name):
                result = subprocess.run(
                    [
                        "python3",
                        "-c",
                        "import runpy,sys; runpy.run_path(sys.argv[1], run_name='test_import')",
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
