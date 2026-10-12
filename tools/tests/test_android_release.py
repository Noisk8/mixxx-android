import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools import android_release


class AndroidReleaseTest(unittest.TestCase):
    def setUp(self):
        self.release = {
            "version": "0.7.1",
            "version_code": 10,
            "codename": "Comic Book Guy",
            "min_sdk": 35,
        }

    def read(self, release):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "release.json"
            path.write_text(json.dumps(release), encoding="utf-8")
            return android_release.read_release(path)

    def test_name_and_metadata(self):
        self.assertEqual(self.read(self.release), self.release)
        self.assertEqual(
            android_release.apk_name(self.release),
            "Mixxx-Android-v0.7.1-Comic-Book-Guy.apk",
        )

    def test_invalid_codes(self):
        for code in [True, 0, -1, "10", 2100000001]:
            with self.subTest(code=code), self.assertRaises(ValueError):
                self.read({**self.release, "version_code": code})

    def test_invalid_name_and_version(self):
        for field, value in [
            ("version", "0.7-beta"),
            ("version", 7),
            ("codename", "../Bart"),
            ("codename", ""),
            ("codename", "Comic  Book"),
        ]:
            with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                self.read({**self.release, field: value})

    def verify(self, package, signature_failure=False, fingerprint=None):
        with tempfile.TemporaryDirectory() as directory:
            sdk = Path(directory)
            tools = sdk / "build-tools" / "35.0.0"
            tools.mkdir(parents=True)
            (tools / "apksigner").touch()
            (tools / "aapt").touch()
            with patch.object(android_release.subprocess, "run") as signature:
                with patch.object(
                    android_release.subprocess, "check_output", side_effect=lambda command, **kwargs:
                        "Signer #1 certificate SHA-256 digest: " + (fingerprint or android_release.signing_fingerprint())
                        if "--print-certs" in command else package
                ):
                    if signature_failure:
                        signature.side_effect = android_release.subprocess.CalledProcessError(
                            1, "apksigner"
                        )
                    android_release.verify_apk(sdk / "test.apk", sdk, self.release)
                    signature.assert_called_once()

    def test_matching_apk(self):
        self.verify(
            "package: name='org.mixxx' versionCode='10' "
            "versionName='0.7.1 (Comic Book Guy)'\nsdkVersion:'35'\n"
        )

    def test_changed_certificate_is_rejected(self):
        with self.assertRaises(ValueError):
            self.verify("", fingerprint="0" * 64)

    def test_false_minimum_sdk_is_rejected(self):
        with self.assertRaises(ValueError):
            self.verify(
                "package: name='org.mixxx' versionCode='10' "
                "versionName='0.7.1 (Comic Book Guy)'\nsdkVersion:'28'\n"
            )

    def test_stale_apk_is_rejected(self):
        with self.assertRaises(ValueError):
            self.verify(
                "package: name='org.mixxx' versionCode='9' versionName='0.7-beta'\n"
            )

    def test_unsigned_apk_is_rejected(self):
        with self.assertRaises(android_release.subprocess.CalledProcessError):
            self.verify("", signature_failure=True)


if __name__ == "__main__":
    unittest.main()
