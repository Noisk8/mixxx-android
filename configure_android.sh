#!/bin/bash
set -e
cd "$(dirname "$0")"
source android_env.sh
mkdir -p build-android
cd build-android
cmake -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$MIXXX_VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DCMAKE_SYSTEM_NAME=Android \
  -DBULK=ON \
  -DQT6=ON \
  -DQML=ON \
  -DHID=ON \
  -DVCPKG_TARGET_TRIPLET=arm64-android \
  -DVCPKG_DEFAULT_HOST_TRIPLET=x64-linux-release \
  -DBUILD_TESTING=OFF \
  -DBUILD_BENCH=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DBATTERY=ON \
  -DBROADCAST=ON \
  -DDOWNLOAD_MANUAL=ON \
  -DKEYFINDER=ON \
  -DLILV=ON \
  -DOPUS=ON \
  -DQTKEYCHAIN=ON \
  -DVINYLCONTROL=ON \
  -DDEBUG_ASSERTIONS_FATAL=OFF \
  -DPIPEWIRE=OFF \
  -L \
  ..
echo "CONFIGURE_EXIT=$?"
