#!/bin/bash
cd "$(dirname "$0")"
source android_env.sh
cd build-android
cmake --build . --parallel 4 --target apk
echo "BUILD_EXIT=$?"
df -h /
