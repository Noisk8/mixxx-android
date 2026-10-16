---
name: mixxx-android
description: Use when building, debugging, or validating the Mixxx Android app in this repo - audio output (Oboe), DJ controller support over USB OTG/Bluetooth, Android permissions, the arm64 APK build, or install/test on a device with adb. Triggers on "android", "apk", "adb", "controladora", "controller not detected", "no sound", "oboe", "midibridge", "hidenumerator", "configure_android.sh", "build_android.sh", "standalone".
---

# Mixxx en Android — cómo trabajar en este fork

> Redactado autónomamente por un Agente de IA (opencode). Ver la política de IA
> en `AGENTS.md`.

## La misión (léela antes de tocar nada)

El producto es una **app DJ usable por sí sola en un teléfono/tablet**: arranca,
suena, se le enchufa una controladora real (USB OTG o Bluetooth/MIDI) y esa
controladora gobierna la mezcla. **Sin PC, sin servidor, sin red.**

Detalle completo de la misión, criterios de aceptación y casos límite en la
sección «Objetivo Principal» de `AGENTS.md`. Si un cambio no se puede validar en
un dispositivo real, **dilo explícitamente y márcalo como pendiente de
validación en hardware**. No lo presentes como terminado.

## Entorno: qué es y qué no es

- Toolchain: NDK `27.2.12479018`, target `arm64-android`, minSdk 28, Qt 6 vía vcpkg.
- Las dependencias (Qt6, hidapi, libusb, taglib…) viven en el **buildenv**
  descargado por CMake, en `buildenv/mixxx-deps-2.7-arm64-android-*`, **no** en
  tu distro. `VCPKG_TARGET_TRIPLET=arm64-android`,
  `VCPKG_DEFAULT_HOST_TRIPLET=x64-linux-release`.
- `android_env.sh` (rutas del SDK/NDK, vars del keystore) y `mixxx.keystore`
  están en `.gitignore`. **Nunca los commitees ni los muevas.**
- El APK de release actual pesa ~300 MB; no es un error de build.

## Ciclo de trabajo

```bash
# 1. Configurar: SOLO si cambió CMakeLists.txt, el toolchain o el buildenv
./configure_android.sh

# 2. Compilar (incremental con ccache + Ninja). Para tocar solo una lib:
cmake --build build-android --target mixxx-lib --parallel 4
# y para el APK completo:
./build_android.sh

# 3. Instalar y probar en el dispositivo real
adb install -r build-android/android-build/build/outputs/apk/release/android-build-release-signed.apk

# 4. Ver logs (el arranque ya incluye --log-level debug en el manifest)
adb logcat -c && adb logcat -s mixxx QtAndroidMidi:V hid:* libusb:*
```

**Nunca des por buena una feature sin el paso 3.** Compilar no es funcionar.
En una función de controladora o de audio, un cambio que «solo compila» puede
significar «cuelga en real-time» o «la controladora desaparece».

### Emulador (para lo que NO depende de hardware)

El emulador sirve para: arranque de la app, biblioteca, skins/QML, layout,
reproducción de audio por el speaker del emulador, y escaneo de enumeradores
(sin dispositivo: el enumerador debe inicializarse y escanear sin crashear).
**No** sirve para validar OTG, permisos USB reales, ni Bluetooth. Para eso hace
falta el teléfono.

```bash
adb devices                      # comprueba que hay un dispositivo antes de compilar/instalar
adb shell getprop ro.product.cpu.abi   # debe ser arm64-v8a
```

## Mapa del código Android

### Audio (prioridad crítica: «suene a Cuts» o cortes = el peor bug)

- `src/soundio/soundmanagerconfig.cpp` — define las APIs; `loadDefaults()`
  selecciona `kAPIOboe` en Android. Si tocas esto, comprueba que no rompes
  Linux/desktop (el API por defecto de escritorio **no** debe cambiar).
- `src/soundio/sounddeviceportaudio.cpp` — implementa Oboe vía PortAudio
  (`PA_USE_OBOE`). Ahí están los callbacks de audio.
- `src/soundio/portaudioenumerator.cpp` — el fallback estéreo/48000 Hz para
  dispositivos de Android que no reportan canales ni sample rates (típico del
  speaker del teléfono). Es un parche **deliberado**, no lo «simplifiques».
- **Regla del motor**: el hilo de audio no asigna memoria ni toma locks. Si
  tocas ahí, justifica cada línea.

### Controladoras USB HID por OTG (la vía que sí funciona)

El recorrido completo, en orden:

1. `src/controllers/hid/hidenumerator.cpp` — `queryDevices()` en Android
   enumera vía `UsbManager.getDeviceList()` (JNI directo, **no** `hid_enumerate`),
   filtra por `getInterfaceClass() == LIBUSB_CLASS_HID` y llama a
   `recognizeDevice()` (que aplica la lista de mapeos de
   `res/controllers/`, inyectada en `CONTROLLER_HID_MAPPINGS`).
2. `src/controllers/hid/hidcontroller.cpp` — `open()`: si no hay permiso,
   `requestPermission()` y espera el resultado; luego `openDevice()` y, clave,
   `hid_libusb_wrap_sys_device(fd, interfaceNumber)` para que hidapi hable con
   ese file descriptor.
3. `src/controllers/hid/hidiothread.cpp` — bucle de `hid_read()` /
   escritura de output reports. Es un hilo dedicado: **nunca** lo bloquees
   desde el hilo de audio.
4. `src/controllers/android.cpp` + `packaging/android/src/org/mixxx/UsbPermission.java`
   — el puente JNI del permiso USB (`getIntent`, `waitForPermission`,
   `usbDeviceAccessResult`). Hay un mutex y una condition variable que
   comparten ese estado: respeta ese contrato o tendrás deadlocks en el
   arranque.
5. `CMakeLists.txt:5384` — en Android se enlaza `hidapi::hidapi` (backend
   **libusb**), no `hidraw`. `libusb_set_option(nullptr,
   LIBUSB_OPTION_NO_DEVICE_DISCOVERY)` desactiva el descubrimiento: en Android
   solo valen los dispositivos envueltos a mano.

**Por qué libusb y no hidraw:** en Android una app no puede abrir
`/dev/hidraw*` (restricciones SELinux), así que el backend hidraw no sirve.
No cambies esto «para mejorarlo» sin comprobar en hardware.

### MIDI (USB class-MIDI y Bluetooth)

- `packaging/android/src/org/mixxx/MidiBridge.java` — wrapper JNI de
  `android.media.midi`: lista dispositivos, abre puertos in/out, mueve bytes.
- `src/controllers/midi/androidmidicontroller.cpp` — hace polling al bridge y
  **reensambla** el flujo de bytes en mensajes short (con *running status*),
  SysEx y realtime. Es la parte delicada: un error aquí produce basura MIDI
  silenciosa, no un crash.
- Se activa con la definición `__ANDROID_MIDI__` en `CMakeLists.txt` y se
  registra en `src/controllers/controllermanager.cpp`.

Cobertura: **solo** dispositivos USB/BT que expongan MIDI class. **No** cubre
MIDI DIN, puerto serie ni puertos heredados.

## Checklist antes de dar algo por terminado

- [ ] `./build_android.sh` pasa (y `ninja` no grew en objetos que no tocaste).
- [ ] Instalado con `adb install -r` en un **arm64 real**, no solo emulador.
- [ ] `adb logcat` sin excepciones ni re-spams de los logs de `mixxx.*`.
- [ ] La app arranca **sin** ninguna controladora conectada y no se cuelga.
- [ ] Audio audible por el dispositivo, sin cortes, con la app en background.
- [ ] La controladora aparece en la lista y **mueve algo** (mueve el crossfader
      o un knob y *suena*). Detectar ≠ funcionar.
- [ ] Desenchufar la controladora en caliente no rompe la app.
- [ ] `clang-format`/`cmake-format` conformes (`.pre-commit-config.yaml`).
- [ ] Nada de secretos en el diff: ni `android_env.sh`, ni `mixxx.keystore`.
- [ ] `git commit` / `git push` / abrir PR: **siempre a mano del humano**.

## Trampas conocidas

- **`configure_android.sh` es lento y descarga ~12 GB** (buildenv). No lo
  lances «por si acaso»; solo cuando toca de verdad.
- **`build_android.sh` usa `--parallel 4`** a propósito. Subirlo a 16 puede
  hacer que el linker se quede sin memoria.
- **`android.mm` / QWidget**: Android no compila todo lo de escritorio (ver el
  `if(ANDROID)` de `controllerhidreporttabsmanager` en `CMakeLists.txt`).
  Si metes código de escritorio en una ruta Android, rompe el build.
- **El manifest arranca con `--new-ui --log-level debug --developer`**. Si
  cambias ahí, cambias lo que ve el usuario, no solo tus logs.
- **`MANAGE_EXTERNAL_STORAGE`** es lo que hace posible la biblioteca. Sin
  «Acceso a todos los archivos», Mixxx ve una biblioteca vacía y parece roto.
- **`android.hardware.usb.host` está declarado `required="true"`** en el
  manifest: eso impide instalar en dispositivos sin soporte OTG.

## Cuando no sepas si algo es posible

No lo prometas. Di qué falta, qué habría que escribir, y márcalo pendiente de
validación en hardware. Este repo está en fase experimental: que compile es el
punto de partida, no la meta.
