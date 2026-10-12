#!/usr/bin/env python3

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parent.parent
RELEASE_FILE = ROOT / "packaging/android/release.json"
SIGNING_FILE = ROOT / "packaging/android/signing.json"
REQUIRED_CASES = ("rca_cue", "usb_reconnect", "screen_off", "background", "calls",
                  "notifications", "long_session", "touch_preferences", "touch_library",
                  "storage_permissions", "update_preserves_data")


def read_release(path=RELEASE_FILE):
    release = json.loads(Path(path).read_text(encoding="utf-8"))
    version = release.get("version", "")
    code = release.get("version_code")
    codename = release.get("codename", "")
    min_sdk = release.get("min_sdk")
    if not isinstance(version, str) or not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError("version must use major.minor.patch")
    if type(code) is not int or not 1 <= code <= 2100000000:
        raise ValueError("version_code must be a positive Android version code")
    if not isinstance(codename, str) or not re.fullmatch(
        r"[A-Za-z0-9]+(?: [A-Za-z0-9]+)*", codename
    ):
        raise ValueError("codename must contain words separated by single spaces")
    if type(min_sdk) is not int or min_sdk < 21:
        raise ValueError("min_sdk must be an Android API level of at least 21")
    return release


def apk_name(release):
    character = release["codename"].replace(" ", "-")
    return f"Mixxx-Android-v{release['version']}-{character}.apk"


def signing_fingerprint(path=SIGNING_FILE):
    value = json.loads(Path(path).read_text(encoding="utf-8")).get("certificate_sha256", "")
    if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{64}", value):
        raise ValueError("Expected a SHA-256 signing certificate fingerprint")
    return value


def certificate(apk, tools):
    output = subprocess.check_output(
        [str(tools / "apksigner"), "verify", "--print-certs", str(apk)], text=True
    )
    fingerprints = re.findall(r"Signer #\d+ certificate SHA-256 digest: ([0-9a-fA-F]+)", output)
    if len(fingerprints) != 1:
        raise ValueError("Expected exactly one APK signer")
    return fingerprints[0].lower()


def package_fields(apk, tools):
    badging = subprocess.check_output(
        [str(tools / "aapt"), "dump", "badging", str(apk)], text=True
    )
    package = next((line for line in badging.splitlines() if line.startswith("package:")), "")
    return dict(re.findall(r"(\w+)='([^']*)'", package)), badging


def verify_apk(apk, sdk, release, previous_apk=None):
    versions = sorted(
        (sdk / "build-tools").glob("*"),
        key=lambda path: tuple(int(n) for n in re.findall(r"\d+", path.name)),
    )
    tools = next(
        (
            path
            for path in reversed(versions)
            if (path / "apksigner").is_file() and (path / "aapt").is_file()
        ),
        None,
    )
    if tools is None:
        raise ValueError("No Android build-tools with apksigner and aapt found")
    subprocess.run([str(tools / "apksigner"), "verify", str(apk)], check=True)
    fingerprint = certificate(apk, tools)
    if fingerprint != signing_fingerprint():
        raise ValueError("APK signing certificate changed; existing installations cannot safely update")
    fields, badging = package_fields(apk, tools)
    expected = {
        "name": "org.mixxx",
        "versionCode": str(release["version_code"]),
        "versionName": f"{release['version']} ({release['codename']})",
    }
    for key, value in expected.items():
        if fields.get(key) != value:
            raise ValueError(f"APK {key}: expected {value!r}, got {fields.get(key)!r}")
    sdk_match = re.search(r"^sdkVersion:'(\d+)'", badging, re.MULTILINE)
    if sdk_match is None or int(sdk_match.group(1)) != release["min_sdk"]:
        raise ValueError("APK minimum Android SDK does not match release metadata")
    if previous_apk is not None:
        previous, _ = package_fields(previous_apk, tools)
        if certificate(previous_apk, tools) != fingerprint or previous.get("name") != fields["name"]:
            raise ValueError("Previous APK is not compatible with this update")
        if int(previous.get("versionCode", "0")) >= release["version_code"]:
            raise ValueError("Update versionCode must be greater than the previous APK")
    print(f"Verified: {expected['versionName']}, versionCode={expected['versionCode']}")


def verify_qa(path, apk, release):
    qa = json.loads(Path(path).read_text(encoding="utf-8"))
    with Path(apk).open("rb") as source:
        digest = hashlib.file_digest(source, "sha256").hexdigest()
    if qa.get("apk_sha256") != digest or qa.get("version_code") != release["version_code"]:
        raise ValueError("Physical QA evidence does not match the release APK")
    for field in ("tester", "device", "controller", "tested_at", "evidence"):
        if not isinstance(qa.get(field), str) or not qa[field].strip():
            raise ValueError(f"Physical QA requires {field}")
    if any(qa.get("cases", {}).get(case) != "pass" for case in REQUIRED_CASES):
        raise ValueError("Every required physical QA case must pass before release")
    if type(qa.get("duration_seconds")) is not int or qa["duration_seconds"] < 7200:
        raise ValueError("Release QA requires at least two hours of continuous playback")
    if type(qa.get("usb_reconnect_cycles")) is not int or qa["usb_reconnect_cycles"] < 20:
        raise ValueError("Release QA requires at least 20 USB reconnect cycles")
    print("Physical release QA verified for this APK")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["name", "check", "verify", "gate"])
    parser.add_argument("--apk", type=Path)
    parser.add_argument("--sdk", type=Path)
    parser.add_argument("--previous-apk", type=Path)
    parser.add_argument("--qa", type=Path)
    args = parser.parse_args()
    try:
        release = read_release()
        if args.command == "name":
            print(apk_name(release))
        elif args.command == "check":
            signing_fingerprint()
            print(f"Release metadata valid: {apk_name(release)}")
        elif args.apk is None or args.sdk is None:
            parser.error("verify requires --apk and --sdk")
        else:
            verify_apk(args.apk, args.sdk, release, args.previous_apk)
            if args.command == "gate":
                if args.qa is None: parser.error("gate requires --qa")
                verify_qa(args.qa, args.apk, release)
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Android release validation failed: {error}\n")


if __name__ == "__main__":
    main()
