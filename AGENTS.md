# AGENTS.md — Mixxx Project Instructions

See [README.md](README.md) for a project overview, and
[CONTRIBUTING.md](CONTRIBUTING.md) for build instructions, code style,
pre-commit setup, Git workflow, and pull request guidelines.

## 🎯 OBJETIVO PRINCIPAL — Mixxx funcional y standalone en Android

> **Este es el objetivo que manda sobre cualquier otra consideración del repo.**

Este repositorio NO es «el código de Mixxx con parches para que compile en
Android». Es una **app DJ funcional que se usa en un teléfono/tablet, por su
propio cuenta, sin PC, sin servidor y sin red**.

Una modificación solo cuenta como éxito si, instalado el APK en un dispositivo
Android arm64 real, **un DJ puede**:

1. **Arrancar la app** sin más. Degradación elegante, cero cuelgues.
2. **Escuchar su música**: la biblioteca ve las carpetas del dispositivo
   (permiso *All files access*), se reproducen tracks, waveform, beatgrid,
   y la salida de audio suena por el dispositivo sin cortes (buffer bajo,
   rutas de Oboe activas).
3. **Conectar y usar una controladora real** y que esta gobierne la mezcla:
   - **USB (OTG)**: la controladora aparece, Mixxx pide/recuerda el permiso
     USB, se mapea, y sus knobs/faders/buttons/platos y jogs mueven el audio.
   - **Bluetooth / MIDI**: se empareja, aparece en la lista de controladoras y
     manda mensajes a la app.
   - Al arrancar y al enchufar «en caliente» (hot-plug) la controladora
     **debe detectarse sin reiniciar la app**.
4. **Mezclar de verdad**: crossfader, volumen, EQ, efectos, decks A/B, loops,
   beatjump, sync y waveform visible. Todo desde la controladora o desde la
   pantalla.
5. **Salir bien**: cerrar, matar la app, recibir una llamada y volver a abrir.
   Sin estado corrupto ni cuelgue de audio (el motor de audio no se queda
   retenido cuando la app se va a segundo plano).

### Qué significa esto en la práctica

- **Una feature que no se puede probar en un dispositivo real es una feature
  sin terminar.** Si el cambio depende de hardware (controladora, OTG,
  Bluetooth, pantalla encendida, app en background), dilo explícitamente y
  entrégalo marcado como *pendiente de validación en hardware*.
- **Prioridad al móvil, no al escritorio.** El build de Android es el producto
  principal; el de escritorio es secundario. Un parche que rompe Linux/desktop
  es un bug, aunque el APK siga compilando.
- **El fallo más grave de esta app es que «suene a Cuts» / se corte / no
  aparezca la controladora.** Audio y entrada de controladora son las dos áreas
  más sensibles: toca el motor, el hilo de audio y el paso USB/MIDI con más
  cuidado, y el resto de cambios con más criterio.
- **Nada de features que dependan de un servidor, una nube o internet.** El
  modo standalone es un requisito, no un extra. Si algo necesita red, debe
  tener un camino offline equivalente.
- Al proponer cambios, prefiere siempre el **ciclo corto**: compilar solo lo
  afectado, instalar con `adb`, y probar en el dispositivo antes de darlo por
  hecho.

### Casos límite que generan bug reports (vigila estos)

| Escenario | Qué debe pasar |
|---|---|
| Sin controladora conectada | La app arranca normal, todo se controla por pantalla. |
| Controladora USB sin permiso concedido | Se pide el permiso; si se rechaza, se muestra un aviso claro y se puede seguir en pantalla. |
| Controladora conectada **mientras** la app corre | Se detecta sola (hot-plug), sin reiniciar. |
| Bluetooth se apaga / se desempareja | La app no se cuelga; la controladora desaparece limpiamente. |
| Pantalla apagada / app en segundo plano | El audio sigue sonando (WAKE_LOCK, `background_running`). |
| Batería baja, dispositivo con notch o tablet | El layout QML se adapta (`sensorLandscape`). |

> Nota: la sección «Objetivo Principal» y la skill `mixxx-android` fueron
> redactadas autónomamente por un Agente de IA (opencode), en los términos de
> la política de abajo.

## AI Agent Policy

> **Important:** The Mixxx project only accepts contributions driven by human developers.
> Automated AI agents acting autonomously on a user's behalf are not welcome and may result
> in pull requests being closed without comment.
> But using AI tools that **assist** the human contributor with code generation, refactoring,
> documentation and reviewing the work before submission is welcome.

### No Autonomous Pull Requests

AI agents **must not** open, update, or re-open pull requests autonomously on behalf of a user.
All pull requests must be explicitly reviewed, approved, and submitted by the human developer
themselves. An agent may prepare and stage changes locally, but `git commit`, `git push`, and PR
creation must be deliberate human actions. Before this, a test of the code change by a human,
using a real DJ setup, is required.

### No Automated Responses to PR Review Comments

AI agents **must not** post replies to review comments, questions, or change requests left on
a pull request or its commits. All communication in the PR thread must come directly from the human contributor.

### AI Code-Reviews

AI agents **may** and **should** perform code reviews on explicitly request in scope of the PR.

### No Autonomous Creation of Issues, Bug Reports or Feature Requests

AI agents **must not** open, update, or re-open Issues, Bug Reports or Feature Requests autonomously
or on behalf of a user.
All Issues, Bug Reports, and Feature Requests must be explicitly reviewed, approved, and submitted by
the human user themselves.

### AI-Generated Text Must Carry a Disclaimer

Any text (PR description, commit message body, code comments, documentation) that was written
autonomously by an AI Agent **must** be framed with an disclaimer that the text is autonomously generated
by the AI Agent, at both the start and the end of that text block.

## Android Release Naming

Every Android release is named after a character from *The Simpsons*, for example
"Comic Book Guy" or "Disco Stu". Set the name as `codename` in
`packaging/android/release.json`. Do not reuse a character that already has a
published tag, and change the codename together with the version.

## Key Architecture

- **ControlObject/ControlProxy**: `[Group], key_name` inter-component communication.
- **Engine thread**: Real-time audio — no allocations, no locks, may emit Qt signals but cannot receive them.
- **parented_ptr/make_parented**: Qt object-tree ownership. Object must get a parent before `parented_ptr` destructs.

## Project Layout

```text
src/          C++ source (engine/, controllers/, library/, mixer/, effects/, qml/, preferences/, util/, test/)
res/          Resources (controllers/ JS/XML, skins/, qml/)
cmake/        CMake modules
tools/        Python helper scripts
packaging/android/   AndroidManifest.xml + Java (MainActivity, MidiBridge, UsbPermission)
```

## Android Quick Reference

Ciclo corto de trabajo (detalle y checklist en la skill `mixxx-android`):

```bash
./configure_android.sh     # solo si cambia CMakeLists.txt o el toolchain
./build_android.sh         # incremental con ccache + Ninja
adb install -r build-android/android-build/build/outputs/apk/release/android-build-release-signed.apk
adb logcat -s mixxx QtAndroidMidi  # el arranque ya pide --log-level debug
```

Puntos donde tocar para cada requisito del objetivo principal:

| Objetivo | Dónde vive el código |
|---|---|
| Salida de audio Android | `src/soundio/soundmanagerconfig.cpp` (`kAPIOboe`), `src/soundio/portaudioenumerator.cpp` |
| Controladoras USB (OTG) | `src/controllers/hid/hidenumerator.cpp`, `hidcontroller.cpp`, `android.cpp`, `packaging/android/src/org/mixxx/UsbPermission.java` |
| MIDI USB/Bluetooth | `src/controllers/midi/`, `packaging/android/src/org/mixxx/MidiBridge.java` |
| Permisos y pantalla | `packaging/android/AndroidManifest.xml` |
| Build Android | `CMakeLists.txt` (secciones `ANDROID`), `configure_android.sh`, `build_android.sh`, `android_env.sh` |

## Known Gaps (verificar antes de prometer una feature)

- **Bluetooth/BLE HID**: `CMakeLists.txt` fuerza el backend *libusb* de hidapi.
  En Android `/dev/hidraw` no es accesible para apps, así que las controladoras
  inalámbricas (Bluetooth HID / BLE) **no** están soportadas por esa vía.
- **MIDI DIN / serie y joysticks legacy**: sin backend en Android.
- **Tamaño del APK**: el release actual ronda los 300 MB; sin optimizar.
