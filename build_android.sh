#!/bin/bash
# ============================================================================
# build_android.sh - Mixxx-Android build con protección de memoria Ollama
#                    y flujo de release (check -> build -> verify -> empaquetar)
# ============================================================================
# Hardware: AMD Ryzen 5 (6 núcleos/12 hilos), 16GB RAM (Vega 8 integrada)
# OS: Ubuntu 24.04
# ============================================================================

set -euo pipefail

echo "========================================="
echo "=== Mixxx-Android Build (Ollama Memory Guard + Release) ==="
echo "========================================="

cd "$(dirname "$0")"

# === PROTECCIÓN DE MEMORIA: evitar que Ollama compita por RAM con Ninja ===
echo ""
echo "=== Memoria antes de compilar ==="
free -h

if pgrep -x ollama >/dev/null 2>&1; then
    echo "=== Ollama detectado: bajando prioridad (nice 10) ==="
    pgrep -x ollama | xargs -r renice -n 10 -p 2>/dev/null \
        || echo "  (no se pudo ajustar renice de Ollama)"
else
    echo "=== Ollama no está corriendo - memoria disponible para Ninja ==="
fi

AVAILABLE_MEM=$(free -m | awk '/Mem:/ {print $7}')
echo "=== Memoria libre disponible: ${AVAILABLE_MEM}MB ==="

OLLAMA_WAS_STOPPED=0
if [ "${AVAILABLE_MEM}" -lt 2000 ]; then
    echo "=== ADVERTENCIA: memoria libre < 2GB - deteniendo Ollama temporalmente ==="
    if ollama stop 2>/dev/null; then
        OLLAMA_WAS_STOPPED=1
    fi
    sleep 2
fi

# === RELEASE: cargar entorno y validar metadatos ===
source android_env.sh
python3 tools/android_release.py check
apk_name=$(python3 tools/android_release.py name)
echo "=== APK objetivo: ${apk_name} ==="

# === COMPILACIÓN ===
echo ""
echo "=== Iniciando compilación Android (target: apk) ==="
cd build-android
cmake -E rm -f android-build/mixxx.apk
cmake --build . --parallel 4 --target apk

# === VERIFICACIÓN + EMPAQUETADO ===
python3 ../tools/android_release.py verify \
  --apk android-build/build/outputs/apk/release/android-build-release-signed.apk \
  --sdk "${ANDROID_SDK}"

cp android-build/build/outputs/apk/release/android-build-release-signed.apk "../${apk_name}"
cd ..
sha256sum "${apk_name}" > "${apk_name}.sha256"
echo ""
echo "=== APK generado: ${apk_name} ==="

# === RESTAURAR OLLAMA ===
if [ "${OLLAMA_WAS_STOPPED}" -eq 1 ] && ! pgrep -x ollama >/dev/null 2>&1; then
    echo "=== Reiniciando Ollama en segundo plano ==="
    ollama serve &
fi

echo ""
echo "=== Espacio en disco final ==="
df -h /
