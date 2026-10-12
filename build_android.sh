#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
source android_env.sh
python3 tools/android_release.py check
apk_name=$(python3 tools/android_release.py name)
cd build-android
cmake -E rm -f android-build/mixxx.apk
cmake --build . --parallel 4 --target apk
python3 ../tools/android_release.py verify \
  --apk android-build/build/outputs/apk/release/android-build-release-signed.apk \
  --sdk "${ANDROID_SDK}"
cp android-build/build/outputs/apk/release/android-build-release-signed.apk \
  "../${apk_name}"
cd ..
sha256sum "$apk_name" > "${apk_name}.sha256"
echo "APK generated: ${apk_name}"
df -h /
