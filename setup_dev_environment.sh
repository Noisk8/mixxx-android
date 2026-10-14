#!/usr/bin/env bash
# setup_dev_environment.sh — Prepara el entorno de desarrollo de Mixxx Android
# Compatible con Ubuntu/Debian, Fedora/RHEL y Arch Linux (y derivados).
#
# Uso:
#   ./setup_dev_environment.sh
#
# El script pide sudo si es necesario, instala las dependencias de sistema,
# configura Android SDK/NDK, crea android_env.sh y un keystore de desarrollo.

set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
    echo "[setup] Se requieren privilegios de sudo. Ejecutando con sudo..." >&2
    exec sudo bash "$0" "$@"
fi

# ---------- Detectar SO ----------
if [[ -r /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
else
    echo "[error] No se pudo detectar el sistema operativo" >&2
    exit 1
fi

OS_ID="${ID:-}"
OS_LIKE="${ID_LIKE:-}"

is_debian() { [[ "$OS_ID" =~ (ubuntu|debian|linuxmint|pop|zorin) ]] || [[ "$OS_LIKE" =~ debian ]]; }
is_fedora() { [[ "$OS_ID" =~ (fedora|rhel|centos|rocky|almalinux) ]] || [[ "$OS_LIKE" =~ (fedora|rhel) ]]; }
is_arch()   { [[ "$OS_ID" =~ (arch|manjaro|endeavouros|garuda) ]] || [[ "$OS_LIKE" =~ arch ]]; }

PKG_MANAGER=""
if is_debian; then PKG_MANAGER="apt"; fi
if is_fedora;  then PKG_MANAGER="dnf"; fi
if is_arch;    then PKG_MANAGER="pacman"; fi

if [[ -z "$PKG_MANAGER" ]]; then
    echo "[error] Distribucion no soportada: ${OS_ID} (${OS_LIKE})" >&2
    echo "        Soportadas: Ubuntu/Debian, Fedora/RHEL, Arch Linux" >&2
    exit 1
fi

TARGET_USER="${SUDO_USER:-${USER:-root}}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [[ -z "$TARGET_HOME" ]]; then
    TARGET_HOME="/home/$TARGET_USER"
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log() { echo -e "${GREEN}[setup]${NC} $*"; }
warn() { echo -e "${YELLOW}[setup]${NC} $*"; }
err() { echo -e "${RED}[error]${NC} $*" >&2; }

log "Sistema detectado: ${OS_ID} (gestor: ${PKG_MANAGER})"
log "Usuario objetivo: ${TARGET_USER} (home: ${TARGET_HOME})"
log "Proyecto: ${PROJECT_ROOT}"

# ---------- 1. Paquetes base ----------
case "$PKG_MANAGER" in
    apt)
        log "Actualizando indices apt..."
        apt-get update
        log "Instalando dependencias (Debian/Ubuntu)..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            build-essential ccache cmake ninja-build make \
            autoconf autoconf-archive bison flex pkg-config \
            python3 python3-pip python3-jinja2 \
            openjdk-17-jdk \
            libasound2-dev libegl1-mesa-dev libglu1-mesa-dev libltdl-dev \
            libx11-xcb-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
            libxrender-dev linux-libc-dev libghc-resolv-dev \
            'git' 'unzip' 'wget'
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            '^libxcb.*-dev' || true
        ;;
    dnf)
        log "Instalando dependencias (Fedora/RHEL)..."
        dnf install -y \
            gcc-c++ ccache cmake ninja-build make \
            autoconf autoconf-archive bison flex pkgconfig \
            python3 python3-pip python3-jinja2 \
            java-17-openjdk-devel git unzip wget \
            alsa-lib-devel mesa-libEGL-devel mesa-libGLU-devel \
            libtool-ltdl-devel libxcb-devel libXi-devel \
            libxkbcommon-devel libxkbcommon-x11-devel \
            libXrender-devel libX11-devel kernel-headers
        # Dependencias XCB presentes en Fedora (best-effort)
        dnf install -y 'libxcb*' 2>/dev/null || true
        ;;
    pacman)
        log "Instalando dependencias (Arch Linux)..."
        pacman -Sy --noconfirm --needed \
            base-devel ccache cmake ninja make pkgconf \
            autoconf autoconf-archive bison flex \
            python python-pip python-jinja2 \
            jdk17-openjdk git unzip wget \
            alsa-lib mesa glu libtool \
            libxcb libxi libxkbcommon libxkbcommon-x11 libxrender linux-api-headers
        # Dependencias XCB adicionales (best-effort)
        pacman -Sy --noconfirm --needed $(pacman -Ssq '^libxcb' 2>/dev/null) 2>/dev/null || true
        ;;
esac

# ---------- 2. Android SDK / NDK ----------
SDK_ROOT="${ANDROID_SDK:-${TARGET_HOME}/Android/Sdk}"
SDK_ROOT="${ANDROID_SDK:-${SDK_ROOT}}"
NDK_VERSION="27.2.12479018"
CMDLINE_TOOLS_REV="11076708"

log "Configurando Android SDK en: ${SDK_ROOT}"
mkdir -p "${SDK_ROOT}"
chown -R "${TARGET_USER}:${TARGET_USER}" "${SDK_ROOT}"

CMDLINE_BIN="${SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager"
if [[ ! -x "${CMDLINE_BIN}" ]]; then
    log "Descargando command-line tools de Android..."
    TMP_DIR="$(mktemp -d)"
    trap "rm -rf '${TMP_DIR}'" EXIT
    wget -q --show-progress \
        "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_REV}_latest.zip" \
        -O "${TMP_DIR}/cmdline-tools.zip"
    log "Extrayendo command-line tools..."
    unzip -q "${TMP_DIR}/cmdline-tools.zip" -d "${TMP_DIR}/extracted"
    rm -rf "${SDK_ROOT}/cmdline-tools"
    mkdir -p "${SDK_ROOT}/cmdline-tools"
    mv "${TMP_DIR}/extracted/cmdline-tools" "${SDK_ROOT}/cmdline-tools/latest"
    chown -R "${TARGET_USER}:${TARGET_USER}" "${SDK_ROOT}/cmdline-tools"
else
    log "command-line tools ya presentes"
fi

# JAVA_HOME
JAVA_HOME_DETECTED=""
if command -v javac >/dev/null 2>&1; then
    JAVA_HOME_DETECTED="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
elif [[ -d /usr/lib/jvm/java-17-openjdk-amd64 ]]; then
    JAVA_HOME_DETECTED=/usr/lib/jvm/java-17-openjdk-amd64
elif [[ -d /usr/lib/jvm/java-17-openjdk ]]; then
    JAVA_HOME_DETECTED=/usr/lib/jvm/java-17-openjdk
fi

# Licencias + paquetes Android
log "Aceptando licencias de Android SDK..."
runuser -u "${TARGET_USER}" -- bash -c "yes | '${CMDLINE_BIN}' --licenses >/dev/null 2>&1 || true"

log "Instalando platform/tools/build-tools/NDK de Android (esto puede tardar)..."
runuser -u "${TARGET_USER}" -- \
    "${CMDLINE_BIN}" "platforms;android-35" "platform-tools" "build-tools;35.0.0" "ndk;${NDK_VERSION}"

# ---------- 3. android_env.sh ----------
ENV_FILE="${PROJECT_ROOT}/android_env.sh"
log "Generando ${ENV_FILE} ..."
BUILDENV_NAME="mixxx-deps-2.7-arm64-android-1c20f84a"
BUILDENV_URL="https://downloads.mixxx.org/dependencies/2.7/Linux/${BUILDENV_NAME}.zip"
BUILDENV_SHA256="6786c09f491166352880984842ffa6f554e974f30a3766a2392298444c1be83c"
BUILDENV_BASEPATH="${PROJECT_ROOT}/buildenv"

KEYSTORE_PASS="${MIXXX_KEYSTORE_PASS:-mixxxdev}"
KEYSTORE_PATH="${PROJECT_ROOT}/mixxx.keystore"

if [[ ! -f "${KEYSTORE_PATH}" ]]; then
    log "Generando keystore de desarrollo (${KEYSTORE_PATH})..."
    runuser -u "${TARGET_USER}" -- \
        keytool -genkeypair -v \
            -keystore "${KEYSTORE_PATH}" \
            -alias mixxx -keyalg RSA -keysize 2048 -validity 10000 \
            -storepass "${KEYSTORE_PASS}" -keypass "${KEYSTORE_PASS}" \
            -dname "CN=Mixxx Dev,O=Mixxx,C=US"
fi
chown "${TARGET_USER}:${TARGET_USER}" "${KEYSTORE_PATH}"

cat > "${ENV_FILE}" <<EOF
# Generado automaticamente por setup_dev_environment.sh
# No subir al repositorio (esta en .gitignore).

export ANDROID_SDK="${SDK_ROOT}"
export ANDROID_NDK_HOME="${SDK_ROOT}/ndk/${NDK_VERSION}"
export JAVA_HOME="${JAVA_HOME_DETECTED}"

export BUILDENV_NAME="${BUILDENV_NAME}"
export BUILDENV_BASEPATH="${BUILDENV_BASEPATH}"
export BUILDENV_URL="${BUILDENV_URL}"
export BUILDENV_SHA256="${BUILDENV_SHA256}"
export MIXXX_VCPKG_ROOT="\${BUILDENV_BASEPATH}/\${BUILDENV_NAME}"
export VCPKG_TARGET_TRIPLET=arm64-android

export QT_ANDROID_KEYSTORE_ALIAS=mixxx
export QT_ANDROID_KEYSTORE_KEY_PASS=${KEYSTORE_PASS}
export QT_ANDROID_KEYSTORE_PATH=${KEYSTORE_PATH}
export QT_ANDROID_KEYSTORE_STORE_PASS=${KEYSTORE_PASS}

export PATH="${SDK_ROOT}/cmdline-tools/latest/bin:${SDK_ROOT}/platform-tools:\${PATH}"
export PATH="${TARGET_HOME}/.local/bin:\${PATH}"
EOF
chown "${TARGET_USER}:${TARGET_USER}" "${ENV_FILE}"

# ---------- 4. Pre-commit (opcional) ----------
log "Intentando instalar pre-commit (opcional)..."
if command -v python3 >/dev/null 2>&1; then
    # Algunos sistemas bloquean pip por PEP 668: intentar normal y,
    # si falla, usar --break-system-packages (o el paquete del sistema).
    if ! runuser -u "${TARGET_USER}" -- python3 -m pip install --user --quiet pre-commit 2>/dev/null; then
        if ! runuser -u "${TARGET_USER}" -- python3 -m pip install --user --quiet --break-system-packages pre-commit 2>/dev/null; then
            case "$PKG_MANAGER" in
                apt) apt-get install -y python3-pre-commit 2>/dev/null || true ;;
            esac
            warn "No se pudo instalar pre-commit automaticamente (puedes hacerlo manualmente)."
        fi
    fi
fi

# ---------- Final ----------
chown -R "${TARGET_USER}:${TARGET_USER}" "${PROJECT_ROOT}" 2>/dev/null || true

log "============================================================="
log "Entorno listo."
log "SDK root:  ${SDK_ROOT}"
log "NDK:       ${SDK_ROOT}/ndk/${NDK_VERSION}"
log "Env file:  ${ENV_FILE}"
log ""
log "Pasos siguientes (como ${TARGET_USER}):"
log "  cd ${PROJECT_ROOT}"
log "  source android_env.sh"
log "  ./configure_android.sh"
log "  ./build_android.sh"
log "============================================================="