> **Nota:** este README fue redactado autónomamente por un Agente de IA (opencode).

# mixxx-android

Build **experimental** de [Mixxx](https://www.mixxx.org) — el software DJ gratuito y
de código abierto — para **Android** (arm64-v8a, minSdk 28).

Este repositorio contiene un snapshot del código fuente de Mixxx con los cambios
necesarios para compilarlo como APK de Android y probarlo en teléfonos y tablets.

## Contenido

Scripts de compilación:

| Archivo | Descripción |
|---|---|
| `configure_android.sh` | Configura CMake (Ninja, cross-compile `arm64-android`) |
| `build_android.sh` | Compila y genera el APK firmado |
| `android_env.sh.example` | Plantilla con las variables de entorno (SDK/NDK, keystore) |

Cambios experimentales respecto al código original de Mixxx:

- El botón de engranaje abre el **diálogo clásico** de preferencias
  (mantenerlo presionado abre la interfaz QML nueva).
- Corrección para agregar, quitar y re-enlazar carpetas de música en los
  ajustes QML (el código original fallaba porque `QUrl::toLocalFile()`
  devuelve una cadena vacía para rutas sin esquema).
- Compilación con `-DPIPEWIRE=OFF` (imprescindible: PipeWire no existe en
  Android y rompe el enlace).

## Requisitos

- Linux (probado en **Ubuntu 24.04**), unos 25 GB de disco libre y 8 GB de RAM

### 1. Dependencias de Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y \
  build-essential ccache cmake ninja-build make \
  autoconf autoconf-archive bison flex pkg-config python3-jinja2 \
  openjdk-17-jdk \
  google-android-cmdline-tools-13.0-installer google-android-licenses \
  libasound2-dev libegl1-mesa-dev libglu1-mesa-dev libltdl-dev \
  libx11-xcb-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
  libxrender-dev linux-libc-dev libghc-resolv-dev '^libxcb.*-dev'
```

Qué instala cada grupo:

| Paquetes | Para qué sirven |
|---|---|
| `build-essential cmake ninja-build make ccache` | Compilador C++, CMake, generador Ninja y caché de compilación |
| `autoconf autoconf-archive bison flex pkg-config python3-jinja2` | Herramientas que necesitan los scripts de vcpkg/dependencias |
| `openjdk-17-jdk` | Java para Gradle y las herramientas de Android (`keytool` para el keystore) |
| `google-android-cmdline-tools-13.0-installer google-android-licenses` | `sdkmanager` y licencias del SDK de Android |
| `libasound2-dev libegl1-mesa-dev libglu1-mesa-dev libltdl-dev libx11-xcb-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev libxrender-dev '^libxcb.*-dev' linux-libc-dev libghc-resolv-dev` | Librerías de audio/gráficas (ALSA, OpenGL/EGL, X11/XCB, XKB) que Qt y Mixxx necesitan en el host durante la compilación |

En otras distros (Fedora, Arch, …) instala los equivalentes:
compilador C++ + CMake + Ninja + ccache, JDK 17, y las librerías de
desarrollo de ALSA, OpenGL/EGL, X11/XCB y XKB.

### 2. Android SDK y NDK

Con las dependencias anteriores instaladas (`sdkmanager` disponible en el
PATH):

```bash
(sudo yes | sdkmanager --licenses) || true
sudo sdkmanager "platforms;android-35" "platform-tools" \
  "build-tools;35.0.0" "ndk;27.2.12479018"
```

Esto instala el SDK en `/usr/lib/android-sdk` (NDK 27.2.12479018,
plataforma Android 35, build-tools 35.0.0). Si ya tienes un SDK de Android
en otra ruta, edita `android_env.sh` con tus rutas.

> **Alternativa de un solo paso:** `source tools/android_buildenv.sh setup`
> (script oficial de Mixxx) ejecuta las dos secciones anteriores de una vez:
> instala los paquetes de apt, acepta las licencias del SDK y descarga el
> NDK.

## Compilar

### 1. Variables de entorno

```bash
cp android_env.sh.example android_env.sh
```

Edita `android_env.sh` y revisa especialmente las rutas y contraseñas del
keystore de firma (ver paso 2).

### 2. Keystore de firma (solo la primera vez)

```bash
keytool -genkeypair -v -keystore mixxx.keystore -alias mixxx \
    -keyalg RSA -keysize 2048 -validity 10000
```

Anota la contraseña y ponla en `android_env.sh`
(`QT_ANDROID_KEYSTORE_STORE_PASS`, `QT_ANDROID_KEYSTORE_KEY_PASS`).
El keystore y `android_env.sh` están en `.gitignore`: nunca se suben al repo.

### 3. Configurar y construir

```bash
./configure_android.sh
./build_android.sh
```

La primera configuración descarga automáticamente el buildenv de dependencias
de Mixxx (Qt6 + herramientas de vcpkg, ~12 GB descomprimido) en `buildenv/`.
La primera compilación completa tarda del orden de 30–60 minutos; las
recompilaciones son incrementales (ccache + Ninja).

### 4. Resultado

```
build-android/android-build/build/outputs/apk/release/android-build-release-signed.apk
```

> **Nota:** esta indicación fue redactada autónomamente por un Agente de IA (Copilot).
> El APK compilado se copia como `Mixxx-Android-arm64-beta-0.3.apk` en la raíz del proyecto.
> **Fin de la nota redactada autónomamente por un Agente de IA (Copilot).**

## Instalar en el teléfono

```bash
adb install -r build-android/android-build/build/outputs/apk/release/android-build-release-signed.apk
```

Al iniciar la app, concede el permiso **"Acceso a todos los archivos"**
(All files access) cuando Mixxx abra la pantalla de sistema correspondiente;
sin él, la biblioteca no podrá leer tus carpetas de música.

> **Aviso de autoría:** La siguiente sección fue redactada autónomamente por un agente de IA.

## Configurar el audio de la Pioneer DDJ-400

La DDJ-400 tiene una interfaz USB de audio integrada. En Mixxx, asigna la salida
principal a los canales 1–2 y la preescucha de auriculares a los canales 3–4,
como indica el [manual de Mixxx para la DDJ-400](https://manual.mixxx.org/2.7/en/hardware/controllers/pioneer_ddj_400.html).

### Conectar y seleccionar la interfaz

1. Conecta la DDJ-400 al teléfono con un adaptador USB-C OTG o un hub USB-C
   compatible con modo host. Se recomienda un hub alimentado para evitar
   problemas de energía.
2. Conecta la DDJ-400 antes de abrir Mixxx, o reinicia Mixxx después. Acepta en
   Android cualquier permiso solicitado para el dispositivo USB.
3. Abre **Preferencias → Sound Hardware / Hardware de sonido** y selecciona
   **Android Oboe** como API de sonido.
4. En la pestaña **Output / Salida**, asigna el mismo dispositivo DDJ-400 a
   estas dos rutas:

   | Ruta en Mixxx | Dispositivo | Canales |
   |---|---|---|
   | **Main / Principal** | DDJ-400 (puede aparecer como `USB-Audio - DDJ-400`) | **Channels 1–2** |
   | **Headphones / Auriculares** | El mismo dispositivo DDJ-400 | **Channels 3–4** |

5. Aplica o guarda los cambios. Si no aparecen los canales 3–4, Android no está
   exponiendo las cuatro salidas necesarias para la preescucha independiente.

### Usar la preescucha de auriculares

1. Conecta los auriculares al conector **PHONES** de la DDJ-400.
2. Con una pista cargada, pulsa el botón **CUE** del canal que quieras
   preescuchar.
3. Gira **HEADPHONES MIXING** hacia **CUE** para oír la preescucha y sube
   **HEADPHONES LEVEL** lentamente desde el mínimo. **MASTER CUE** envía el
   master a los auriculares.
4. Para el sonido principal, conecta los altavoces o el amplificador a las
   salidas RCA **MASTER** de la DDJ-400 y sube **MASTER LEVEL** gradualmente.

Los controles físicos de CUE requieren también que Mixxx reconozca la DDJ-400
en **Preferencias → Controllers / Controladores**, que esté habilitada y que use
el mapeo **Pioneer DDJ-400**. El mapeo MIDI y las salidas de audio son ajustes
independientes.

> Al conectar la DDJ-400 por OTG, el teléfono deja de estar conectado por USB al
> computador para ADB. Reconecta el cable al computador después de la prueba
> para recopilar registros.

> **Fin del bloque redactado autónomamente por un agente de IA.**

## Notas

- El APK generado **no** está incluido en este repositorio; se compila localmente.
- `android_env.sh` (con contraseñas) y `mixxx.keystore` están ignorados por git.
- El código fuente de Mixxx es © sus autores, licencia **GPL-2.0-or-later**;
  ver <https://github.com/mixxxdj/mixxx>.

> **Nota:** este README fue redactado autónomamente por un Agente de IA (opencode).
