#!/usr/bin/env python3
"""Exercise the ACR release metadata contract and the bundled catalog version."""

from __future__ import annotations

import contextlib
import io
import json
import re
import runpy
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills/blog-writer"
MODULE = runpy.run_path(str(SKILL / "check-catalog-version.py"))


def release(latest):
    return {
        "metadataVersion": 1,
        "name": "jbaruch/blog-writer",
        "repository": "https://github.com/jbaruch/blog-writer",
        "version": latest,
        "tag": f"v{latest}",
    }


class CatalogVersionTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.version_file = Path(temp.name) / "catalog-version.txt"
        self.version_file.write_text("1.1.36\n", encoding="utf-8")

    def check(self, response=None, error=None):
        check = MODULE["check"]
        with patch.dict(
            check.__globals__,
            {
                "urlopen": Mock(
                    return_value=io.StringIO(json.dumps(response)), side_effect=error
                )
            },
        ):
            with contextlib.redirect_stderr(io.StringIO()) as diagnostic:
                payload, code = check(self.version_file)
        return payload, code, diagnostic.getvalue()

    def test_current_catalog_permits_comparison(self):
        payload, code, diagnostic = self.check(release("1.1.36"))
        self.assertEqual(code, 0)
        self.assertEqual(
            payload, {"installed": "1.1.36", "latest": "1.1.36", "status": "current"}
        )
        self.assertEqual(diagnostic, "")

    def test_different_versions_refuse_comparison_in_both_directions(self):
        for latest in ("1.1.42", "1.1.35"):
            with self.subTest(latest=latest):
                payload, code, diagnostic = self.check(release(latest))
                self.assertEqual(code, 1)
                self.assertEqual(payload["installed"], "1.1.36")
                self.assertEqual(payload["latest"], latest)
                self.assertEqual(payload["status"], "mismatch")
                self.assertIn("Update the executing", diagnostic)

    def test_release_failure_never_permits_comparison(self):
        payload, code, diagnostic = self.check(error=TimeoutError("GitHub timed out"))
        self.assertEqual(code, 2)
        self.assertEqual(payload["installed"], "1.1.36")
        self.assertIsNone(payload["latest"])
        self.assertIn("Skip the refresh", diagnostic)

    def test_invalid_metadata_never_permits_comparison(self):
        for response in (
            None,
            [],
            {},
            release(None),
            release("garbage"),
            {**release("1.1.36"), "name": "other/plugin"},
            {**release("1.1.36"), "tag": "v1.1.42"},
            {**release("1.1.36"), "metadataVersion": 2},
        ):
            with self.subTest(response=response):
                payload, code, diagnostic = self.check(response)
                self.assertEqual(code, 2)
                self.assertEqual(payload["status"], "unknown")
                self.assertTrue(diagnostic)

    def test_unusable_version_file_refuses_comparison(self):
        self.version_file.write_text("garbage\n", encoding="utf-8")
        payload, code, _ = self.check()
        self.assertEqual(code, 2)
        self.assertIsNone(payload["installed"])
        self.version_file.unlink()
        _, code, _ = self.check()
        self.assertEqual(code, 2)

    def test_shipped_version_matches_release_manifest(self):
        manifest = (ROOT / "agent-plugin.yaml").read_text(encoding="utf-8")
        match = re.search(r"^version: (\S+)$", manifest, re.MULTILINE)
        self.assertIsNotNone(match)
        assert match is not None
        self.assertEqual(MODULE["VERSION_FILE"].parent, SKILL)
        self.assertEqual(MODULE["VERSION_FILE"].read_text().strip(), match[1])


if __name__ == "__main__":
    unittest.main()
