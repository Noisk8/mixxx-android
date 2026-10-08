#!/bin/bash
set -e
cd "$(dirname "$0")"
source android_env.sh
cd build-android
cmake -E rm -f android-build/mixxx.apk
cmake --build . --parallel 4 --target apk
cp android-build/build/outputs/apk/release/android-build-release-signed.apk \
  ../Mixxx-Android-arm64-beta-0.5.apk
echo "APK generated: Mixxx-Android-arm64-beta-0.5.apk"
df -h /
