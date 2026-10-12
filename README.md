> **Nota:** este README fue redactado autónomamente por un Agente de IA (opencode).

# mixxx-android

Build **experimental** de [Mixxx](https://www.mixxx.org) — el software DJ gratuito y
de código abierto — para **Android 15 o posterior** (arm64-v8a, minSdk 35).

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
> El APK compilado se copia con el nombre definido en `packaging/android/release.json`;
> actualmente, `Mixxx-Android-v0.7.1-Comic-Book-Guy.apk`. El script verifica firma,
> versión interna y Android mínimo, y genera un archivo de checksum SHA-256.
> **Fin de la nota redactada autónomamente por un Agente de IA (Copilot).**

## Instalar en el teléfono

```bash
adb install -r build-android/android-build/build/outputs/apk/release/android-build-release-signed.apk
```

Al iniciar la app, concede el permiso **"Acceso a todos los archivos"**
(All files access) cuando Mixxx abra la pantalla de sistema correspondiente;
sin él, la biblioteca no podrá leer tus carpetas de música.

## Usar la app con la Pioneer DDJ-400: guía paso a paso

> Sección redactada autónomamente por un agente de IA. Requiere revisión humana antes de publicación.

**Estado:** la separación independiente de la preescucha (CUE en auriculares 3–4)
todavía no está verificada físicamente. Sigue esta guía y anota lo que oigas.

1. **Prepara el teléfono.** Android 15 o posterior con arquitectura ARM64. Instala la APK
   y concede el permiso **Acceso a todos los archivos** cuando Mixxx lo pida.
2. **Copia tu música** a una carpeta del teléfono, por ejemplo `Music`.
3. **Conecta la DDJ-400** con un cable OTG o un hub USB-C alimentado, antes de abrir Mixxx.
4. **Abre Mixxx** y acepta el permiso USB que aparece para la DDJ-400.
5. **Agrega tu biblioteca.** En Preferencias, abre la configuración de biblioteca,
   añade la carpeta de música y espera a que termine el escaneo.
6. **Configura el audio.** En Preferencias → Sound Hardware, selecciona **Android Oboe**.
   Asigna **Main** a los canales 1–2 y **Headphones** a los canales 3–4 del mismo
   dispositivo DDJ-400. Detalles en la sección siguiente.
7. **Activa el controlador.** En Preferencias → Controllers, habilita
   **Pioneer DDJ-400** con el mapeo correspondiente.
8. **Carga una pista.** Selecciónala en la biblioteca y pulsa **LOAD** en el deck
   de la controladora.
9. **Reproduce.** Pulsa **PLAY** y sube el fader del canal. Ajusta el volumen con
   **MASTER LEVEL** y el volumen multimedia del teléfono.
10. **Prueba la preescucha.** Pulsa **CUE** en el canal y gira **HEADPHONES MIXING**
    hacia CUE. Compara lo que oyes en auriculares con lo que sale por RCA.
11. **Termina la sesión.** Pausa, cierra Mixxx y desconecta la DDJ-400.

**Si algo falla:**

- **Sin sonido:** revisa el volumen multimedia del teléfono, el MASTER de la DDJ-400 y
  que los canales de salida estén asignados.
- **La controladora no responde:** revisa Preferencias → Controllers y que el mapeo
  Pioneer DDJ-400 esté habilitado.
- **Se corta al desconectar USB:** vuelve a conectar la controladora y espera un par de
  segundos. Si no recupera el audio, cierra y reabre Mixxx.

> Fin de la sección redactada autónomamente por un agente de IA.

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

## Estado y compatibilidad de Android

> Este bloque fue generado autónomamente por un agente de IA.

La versión del port es **0.7.1 (Comic Book Guy)** y sigue siendo experimental.
La DDJ-400 ya se probó físicamente: el usuario confirmó audio por RCA y auriculares,
pero sigue informando un fallo de separación de preescucha. La enumeración USB y
la apertura de cuatro canales no certifican todavía una salida CUE independiente.

El APK actual requiere **ARM64 y Android 15/API 35 o posterior**. La compilación
nativa usa API 35 y el binario enlaza funciones que no existen en Android anteriores;
por ello ya no se anuncia Android 9 como compatible. Ampliar la compatibilidad exige
recompilar el motor y sus dependencias para el API mínimo elegido y probarlo en
esos dispositivos. Véase [SDK y NDK de Android](https://developer.android.com/ndk/guides/sdk-versions).

La interfaz Pioneered tiene un tamaño mínimo declarado de 480×420. Las cifras de
RAM, temperatura, autonomía, latencia y fluidez deben medirse con una sesión DJ
representativa. La compatibilidad de un teléfono o tablet se confirma mediante
pruebas; el modelo de GPU por sí solo no basta.

La identidad de cada release se mantiene en `packaging/android/release.json`:
versión semántica, código Android creciente, nombre de un personaje de Los Simpson
y API mínimo. Un cambio del nombre del archivo no cambia la versión instalada.
`./build_android.sh` comprueba estos datos dentro del APK antes de copiarlo.

Para activar registros de audio durante una prueba, configura CMake con
`-DANDROID_AUDIO_DIAGNOSTICS=ON`; las builds normales usan registros de nivel info.
Consulta [ANDROID_AUDIO_DEBUG.md](ANDROID_AUDIO_DEBUG.md) para la prueba de CUE.

El diagnóstico, los riesgos pendientes y los criterios para una versión estable
están en [ANDROID_PROJECT_AUDIT.md](ANDROID_PROJECT_AUDIT.md).
Las pruebas de regresión del port se ejecutan con `bash tools/test_android_port.sh`
(requieren Python 3, Java 17, g++ y las fuentes de GoogleTest; puede indicarse su
ubicación con `GTEST_ROOT`). También se preparó un workflow de GitHub Actions para
esas pruebas. El pipeline general heredado ya contiene una compilación Android.

> Fin del bloque generado autónomamente por un agente de IA.

---

## Pruébala y cuéntanos

> Sección redactada autónomamente por un agente de IA. Requiere revisión humana antes de publicación.

Mixxx Android es experimental y necesita pruebas en más teléfonos y controladoras.
Si la pruebas, tus comentarios son muy útiles:

- **Abre un issue** en este repositorio con el modelo del teléfono, la versión de
  Android, la controladora, la versión de la APK (`packaging/android/release.json`),
  qué hiciste y qué pasó.
- **Comenta en issues existentes** si tu hardware reproduce el mismo problema.
- **Para problemas de audio**, adjunta la carpeta que genera
  `tools/android_rca_cue_capture.sh`. Antes de subirla, revisa que no contenga rutas
  ni nombres de pistas que no quieras compartir.

Las pruebas que confirmen o descarten la separación RCA/CUE son especialmente valiosas.

> Fin de la sección redactada autónomamente por un agente de IA.

## Licencia

Mixxx Android usa la misma licencia que Mixxx: **GNU General Public License versión 2
o cualquier versión posterior (GPL-2.0-or-later)**. El texto completo está en
[LICENSE](LICENSE). El código original de Mixxx es © sus autores.

---

## Notas

- El APK generado **no** está incluido en este repositorio; se compila localmente.
- `android_env.sh` (con contraseñas) y `mixxx.keystore` están ignorados por git.
- El código fuente de Mixxx es © sus autores, licencia **GPL-2.0-or-later**;
  ver <https://github.com/mixxxdj/mixxx>.

> **Nota:** este README fue redactado autónomamente por un Agente de IA (opencode).
