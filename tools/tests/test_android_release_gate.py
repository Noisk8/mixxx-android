import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from tools import android_release


class ReleaseGateTest(unittest.TestCase):
    def qa(self):
        return {"apk_sha256": hashlib.sha256(b"apk-test").hexdigest(), "version_code": 11,
                "tester": "Human DJ", "device": "Test phone", "controller": "DDJ-400",
                "tested_at": "2026-10-11", "evidence": "local measurements and listening notes",
                "duration_seconds": 7200, "usb_reconnect_cycles": 20,
                "cases": dict.fromkeys(android_release.REQUIRED_CASES, "pass")}

    def validate(self, qa):
        with tempfile.TemporaryDirectory() as directory:
            apk = Path(directory) / "test.apk"
            apk.write_bytes(b"apk-test")
            evidence = Path(directory) / "qa.json"
            evidence.write_text(json.dumps(qa), encoding="utf-8")
            android_release.verify_qa(evidence, apk, {"version_code": 11})

    def test_matching_completed_evidence(self): self.validate(self.qa())

    def test_old_apk_evidence_is_rejected(self):
        for change in [{"apk_sha256": "0" * 64}, {"version_code": 10}]:
            with self.assertRaises(ValueError): self.validate({**self.qa(), **change})

    def test_missing_physical_results_are_rejected(self):
        qa = self.qa()
        qa["cases"]["rca_cue"] = "pending"
        with self.assertRaises(ValueError): self.validate(qa)

    def test_incomplete_stress_test_is_rejected(self):
        for change in [{"duration_seconds": 60}, {"usb_reconnect_cycles": 1}, {"tester": ""}]:
            with self.assertRaises(ValueError): self.validate({**self.qa(), **change})
