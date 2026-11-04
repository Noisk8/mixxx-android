#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

echo "📱 Esperando conexión del móvil por USB..."
adb wait-for-device
DEV=$(adb devices | grep -v 'List' | grep 'device' | awk '{print $1}' | head -n 1)
echo "✅ Dispositivo detectado: $DEV"

echo "📁 Asegurando directorio para mapeos y grabaciones..."
adb shell mkdir -p /storage/emulated/0/Mixxx/controllers

echo "📦 Instalando versión optimizada en el dispositivo..."
adb install -r -d mixxx-android-release-signed.apk

echo "💾 Copiando APK a /sdcard/Download/mixxx-android.apk..."
adb push mixxx-android-release-signed.apk /sdcard/Download/mixxx-android.apk

echo "🚀 Lanzando MIXXX en el móvil..."
adb shell am start -S -n org.mixxx/.MainActivity

echo "🎉 ¡MIXXX instalado y ejecutándose correctamente!"
