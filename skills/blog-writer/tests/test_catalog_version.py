#!/usr/bin/env python3
"""Deterministic registry and manifest fixtures for the refresh gate."""

from __future__ import annotations

import contextlib
import io
import json
import runpy
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "check-catalog-version.py"
MODULE = runpy.run_path(str(SCRIPT))


class CatalogVersionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.manifest = Path(self.temp.name) / "plugin.json"
        self.manifest.write_text(
            json.dumps({"name": "jbaruch/blog-writer", "version": "1.1.36"}),
            encoding="utf-8",
        )

    def check(self, response=None, error=None):
        result = subprocess.CompletedProcess([], 0, json.dumps(response), "")
        with patch("subprocess.run", return_value=result, side_effect=error):
            with contextlib.redirect_stderr(io.StringIO()) as diagnostic:
                payload, code = MODULE["check"](self.manifest)
        return payload, code, diagnostic.getvalue()

    def registry(self, latest):
        return {"tile": {"fullName": "jbaruch/blog-writer", "latestVersion": latest}}

    def test_current_catalog_permits_comparison(self):
        payload, code, diagnostic = self.check(self.registry("1.1.36"))
        self.assertEqual(code, 0)
        self.assertEqual(
            payload, {"installed": "1.1.36", "latest": "1.1.36", "status": "current"}
        )
        self.assertEqual(diagnostic, "")

    def test_different_versions_refuse_comparison_in_both_directions(self):
        for latest in ("1.1.42", "1.1.35", "1.1.36-rc.1"):
            with self.subTest(latest=latest):
                payload, code, diagnostic = self.check(self.registry(latest))
                self.assertEqual(code, 1)
                self.assertEqual(payload["installed"], "1.1.36")
                self.assertEqual(payload["latest"], latest)
                self.assertEqual(payload["status"], "mismatch")
                self.assertIn("Update the executing", diagnostic)

    def test_registry_failures_never_permit_comparison(self):
        for error in (
            FileNotFoundError("tessl missing"),
            subprocess.TimeoutExpired("tessl", 30),
            subprocess.CalledProcessError(1, "tessl"),
        ):
            with self.subTest(error=error):
                payload, code, diagnostic = self.check(error=error)
                self.assertEqual(code, 2)
                self.assertEqual(payload["installed"], "1.1.36")
                self.assertIsNone(payload["latest"])
                self.assertIn("skip the refresh", diagnostic)

    def test_registry_schema_errors_never_permit_comparison(self):
        for response in (
            None,
            [],
            {},
            {"tile": []},
            self.registry(None),
            self.registry("garbage"),
            {"tile": {"fullName": "other/plugin", "latestVersion": "1.1.36"}},
        ):
            with self.subTest(response=response):
                payload, code, diagnostic = self.check(response)
                self.assertEqual(code, 2)
                self.assertEqual(payload["status"], "unknown")
                self.assertTrue(diagnostic)

    def test_invalid_registry_json_is_reported(self):
        with patch(
            "subprocess.run",
            return_value=subprocess.CompletedProcess([], 0, "not json", ""),
        ):
            with contextlib.redirect_stderr(io.StringIO()):
                payload, code = MODULE["check"](self.manifest)
        self.assertEqual(code, 2)
        self.assertEqual(payload["installed"], "1.1.36")

    def test_unusable_manifests_refuse_comparison_without_registry_call(self):
        for content in (
            "{",
            "[]",
            '{"name":"other/plugin","version":"1.1.36"}',
            '{"name":"jbaruch/blog-writer"}',
        ):
            with self.subTest(content=content):
                self.manifest.write_text(content, encoding="utf-8")
                with patch("subprocess.run") as registry:
                    with contextlib.redirect_stderr(io.StringIO()):
                        payload, code = MODULE["check"](self.manifest)
                registry.assert_not_called()
                self.assertEqual(code, 2)
                self.assertIsNone(payload["installed"])
        self.manifest.unlink()
        _, code, _ = self.check()
        self.assertEqual(code, 2)

    def test_default_manifest_belongs_to_executing_plugin(self):
        self.assertEqual(
            MODULE["MANIFEST"], SCRIPT.parents[2] / ".tessl-plugin/plugin.json"
        )


if __name__ == "__main__":
    unittest.main()
