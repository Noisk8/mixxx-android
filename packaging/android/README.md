# Mixxx on Android

The Android port builds the QML user interface (`--new-ui`) against the Oboe
backend of PortAudio. It targets tablets and Chromebooks as much as phones:
the whole DJ surface is laid out for landscape and is driven by multi-touch.

## Building

```sh
source tools/android_buildenv.sh setup
cmake -DCMAKE_TOOLCHAIN_FILE="${MIXXX_VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" \
      -DCMAKE_SYSTEM_NAME=Android \
      -DANDROID_ABI=arm64-v8a \
      -S . -B build-android
cmake --build build-android
```

`ANDROID_ABI` selects the target architecture (`arm64-v8a`, `x86_64`,
`armeabi-v7a`, `x86`). Only `arm64-v8a` has a published prebuilt dependency
archive, which covers phones, ARM tablets and ARM Chromebooks. To build for
another ABI — notably `x86_64` for Intel Chromebooks and the emulator — the
vcpkg dependency tree has to be built for that triplet first, see
<https://github.com/mixxxdj/mixxx/wiki/Compiling-dependencies-for-android>.

## Touch interaction

Touch input is handled by Qt Quick pointer handlers rather than `MouseArea`,
because Qt synthesizes mouse events from a single touch point only. Using
handlers is what allows two decks to be operated at the same time:

| Gesture                          | Action                                     |
| -------------------------------- | ------------------------------------------ |
| Drag on the waveform             | Scratch (independently per deck)           |
| Pinch on the waveform            | Waveform zoom (mouse wheel equivalent)     |
| Drag on the spinny               | Scratch (independently per deck)           |
| Drag on a knob or fader          | Change the value                           |
| Long press on a hotcue           | Open the hotcue popup (right click on desktop) |

## Controllers and the screens

> _The following section was written by an AI agent (Claude Code)._

The Android UI creates `[Skin]` controls that controller mappings can use
(see `res/qml/+android/MainWindow.qml`):

| Control | Action |
| ------- | ------ |
| `[Skin],mobile_library_toggle` | Shows the LIB view, or returns to the previous view |
| `[Skin],mobile_loader_deck1`, `[Skin],mobile_loader_deck2` | Opens the deck loader of deck 1/2 |
| `[Skin],mobile_fx_toggle` | Shows or hides the effects (FX bar; BEAT FX in the Booth skin) |

`[ChannelN],LoadSelectedTrack` (LOAD) opens the deck loader of deck 1/2 when
no library is on screen; with a library on screen it loads the selected
track, and closes the deck loader if it was used. The DDJ-400 and DDJ-FLX4
mappings map SHIFT+LOAD (`0x96 0x68`/`0x7A`, measured on a DDJ-FLX4) to
`mobile_library_toggle`. The DDJ-400 and DDJ-FLX4 mappings map SHIFT+BEAT ▶ (`0x94 0x6B`,
from Pioneer's MIDI message lists) to `mobile_fx_toggle`.

> _End of AI-written section._

## Date added of scanned tracks

> _The following section was written by an AI agent (Claude Code)._

The scanner adds files alphabetically, folder by folder, so the "date added"
of a newly added folder would follow the file names. After each scan,
`src/library/androidscanorder.cpp` hands out the "date added" values of the
tracks that scan added again in the order of the file dates, oldest file
first. The values stay times of that scan, and tracks that were already in
the library are not changed.

> _End of AI-written section._

## Copying Rekordbox playlists

> _The following section was written by an AI agent (Claude Code)._

A Rekordbox playlist of a USB drive has a *COPY* button in the library. It
copies the files to `/storage/emulated/0/Music/Mixxx/<playlist name>`, adds
the copies to the library in the order of the playlist and gives them the
beatgrid, cues, key and color that Rekordbox exported, then creates a Mixxx
playlist with the same order (`src/library/rekordbox/rekordboxplaylistcopy.cpp`).
Copying the same playlist again only copies files that are not in the folder
yet and refills the Mixxx playlist.
The copy never replaces anything it didn't make: a Mixxx playlist with the
same name, or a folder that already has other files, is refused (the folder
of a copy has a `.mixxx-playlist-copy` file with the id of its playlist). The
free space is checked before (for mounted drives) and during the copy, and no
playlist is created if no file could be copied.

A copy of a whole USB stick can be used instead of the stick: each folder in
`/storage/emulated/0/Music/Mixxx/Rekordbox` that contains a Rekordbox export
(`PIONEER/rekordbox/export.pdb`) is listed like a stick named after the
folder (see `src/util/removablestorage.cpp`). The library scanner skips that
folder, so the tracks of the copies are not added to the library.
*Settings → Music Library → Rekordbox stick backup* makes such a copy: it
copies the `PIONEER` and `Contents` folders of a connected stick there, and
the audio files anywhere else on the stick (Rekordbox can play tracks from
any folder, e.g. the root). Later
backups mirror the stick: they copy what is new or changed and delete what
was removed from it, but only if the stick could be read completely
(`src/library/rekordbox/rekordboxdrivebackup.cpp`). A backup folder belongs
to one stick, identified by the serial number of its file system in a
`.mixxx-stick` file: backing up another stick (e.g. one with the same label)
into it is refused, so a mirror never deletes the files of a different stick.
The backups have a `.nomedia` file, so other music apps don't list them.

The Rekordbox data is read by `rekordboxandroid.inc`, which is included at
the end of the upstream `rekordboxfeature.cpp` so that it can use the ANLZ
reader there without changing it.

> _End of AI-written section._

## Android 10 to 13

> _The following section was written by an AI agent (Claude Code)._

Qt and the dependencies are built against the C library of API 35. Only
three of its functions that libQt6Core, libQt6Test and libmixxx use are
newer than Android 10 (`pthread_cond_clockwait`, `backtrace`,
`copy_file_range`), so the app runs from Android 10 on without rebuilding
Qt: `libmixxx_libccompat.so` (`src/util/androidlibccompat.c`) provides
them, and these libraries are patched with patchelf to load it
(`cmake/scripts/android_libccompat.cmake`, needs `patchelf`). `build.gradle`
here is the template of Qt with the patched libraries kept out of Gradle's
strip, which would break the patched layout. Android 9 is not supported:
AMidi, used for the MIDI controllers, needs Android 10.

> _End of AI-written section._

## Skins

> _The following section was written by an AI agent (Claude Code)._

*Settings → Interface → Skin* switches the main window at once (the decks
keep playing) and remembers the choice (`[Config],AndroidSkin`, through
`Mixxx.MobileApp.skin`). "Classic" is `res/qml/MainWindow.qml` (its
`+android` override); every other skin is a folder `res/qml/Skins/<Name>/`
with its own `MainWindow.qml`, whose root item takes the application window
(`required property ApplicationWindow applicationWindow`) and may provide
`menuBar` and `openQuickLoad(group)` like the Classic one. Skins reuse the
shared components (library, deck loaders, settings) by importing `"../.."`.
If a skin fails to load, Classic is loaded instead.

A skin can change the shared colors (library, settings, popups) with a
`skinTheme` property of its main window, an object of `Theme` property
names and values; `main.qml` applies it and undoes it when another skin is
loaded. The colors that the library components used to write into the code
are `library…` properties of `Theme` (`res/qml/Theme/+android/Theme.qml`),
whose defaults are the Classic look.

Android draws ◀ and ▶ as emoji and its fonts lack ❚ and the other
triangles, so the UI draws them: `Triangle.qml` (rotated for ▲ ▼),
`ArrowText.qml` for a text with an arrow, and `arrowLeft`/`arrowRight` of
the buttons (`res/qml/+android/Button.qml`). Texts don't contain them.

The **Booth** skin (`res/qml/Skins/Booth/`) is laid out like the screen of a
booth player, for landscape phones and tablets: the two waveforms stacked
over the whole width with quantize and slip next to them, the deck displays
below them (remaining time, tempo, BPM with the beatgrid panel, SYNC, CUE
and PLAY, hot cues A–H, overview) and BEAT FX (effect unit 1) on the right,
behind a button on phones. BROWSE shows the skin's browser in place of the
waveforms (`BoothBrowse.qml`): a column of sources, whose entries
(playlists, folders, drives) are listed one level at a time in place of the
tracks, the skin's own track columns and rows (`BoothSourceTree.qml`) and
an info panel of the selected track. It uses the shared library sources,
track menu, + ALL, COPY and controller browsing. LOAD 1/2
open the browser for one deck and return to the waveforms once a track is
loaded into it. UTILITY opens the shared settings with the skin's title and
colors (`title`, `headerColor` and `backgroundColor` of `Settings.qml`).

DJ (`BoothDjView.qml`) is for playing without a controller, in the style of
the PERFORMANCE layout of rekordbox: for each deck pads for hot cues, beat
jump (the left half of a pad back, the right half forward) or beat loops,
the loop size, SYNC, CUE, PLAY, SLIP, Q, MT, a jog that scratches and the
tempo (`BoothPerformanceDeck.qml`), a mixer with TRIM, EQ, headphones CUE,
meters and channel faders between them (`BoothMixer.qml`), and the
headphones, crossfader and master level below. The skin starts in it when
no controller with an enabled mapping is connected
(`Mixxx.ControllerManager.knownDevices`), and switches between it and the
waveforms when one is plugged in or out. Its knobs and faders
(`BoothKnob.qml`, `BoothFader.qml`) use pointer handlers, so several can be
moved at once. XY shows the XY pad of the Classic skin in the colors of the
skin (`XYPad.qml` has properties for its colors, and `closable`).

The **Lite** skin (`res/qml/Skins/Lite/`) draws and updates as little as
possible, for slow devices and to save battery. It has no waveforms: each
deck has a position bar that is read 5 times a second
(`playposition` changes with every audio buffer and would redraw the
window that often). It has no images, Canvas knobs (`LiteKnob.qml` is a
bar), animations, level meters, effects panel or XY pad. DECKS shows two
decks (`LiteDeck.qml`: track, position and time left, BPM and tempo, hot
cues A–D or A–H, a loop, SYNC, CUE, PLAY, tempo fader and nudge) and a
mixer between them (`LiteMixer.qml`: EQ, filter, headphones CUE, channel
faders and the crossfader). BROWSE loads the browser of the Booth skin only
while it is shown. It creates two decks when Mixxx starts with it. The
samplers stay, as controller mappings use them.

Settings → Interface → TOP BAR lists the items of the skin in use: a skin
can list its own in a `topBarItems` property of its main window (`main.qml`
exposes it as `skinItem`), otherwise the Classic items are listed. Booth
shares the names of the matching Classic items (`Mixxx.MobileApp.hiddenTopBarItems`)
and hides its tabs that are turned off.

> _End of AI-written section._

## Merging upstream Mixxx

### QML overrides

> _The following section was written by an AI agent (Claude Code)._

The upstream QML files in `res/qml/` are kept unmodified, so that merging
`mixxxdj/mixxx` does not conflict. The Android versions live next to them in
`+android/` folders, e.g. `res/qml/Settings/+android/Interface.qml` replaces
`res/qml/Settings/Interface.qml`.

The replacement happens when the APK is built:
`cmake/modules/apply_android_qml_overrides.cmake` copies each `+android` file
over the upstream one in the package's assets and removes the `+android`
folders. The app therefore sees the same files as if the upstream files had
been edited. Qt's runtime
[QML file selectors](https://doc.qt.io/qt-6/qtquick-positioning-qml-file-selectors.html)
are deliberately not used: from Qt 6.12 on, relative imports inside a
`+android` file (`import "."`, `import "../Theme"`) resolve against the
`+android` folder and the UI would fail to load.

Rules when changing the UI:

* To change an upstream QML file for Android, copy it to the `+android/`
  folder next to it and edit the copy. Never edit the upstream file.
* Write the copy as if it were in the original folder: its relative imports
  are resolved from there once it is packaged.
* Files that only exist in this fork (e.g. `res/qml/WaveDeckBar.qml`,
  `res/qml/Deck/TouchSpinny.qml`) are added as normal files, not into
  `+android/`.
* QML compiled into the binary (`res/qml/Mixxx/...`) cannot be overridden this
  way; use a fork-owned copy instead, as `Deck/TouchSpinny.qml` does for
  `Mixxx.Controls.Spinny`.
* After merging upstream, check whether upstream changed a file that has an
  override (`git diff <old-upstream> <new-upstream> -- res/qml`) and port the
  change into the override by hand if needed.
* Exception: user-visible strings that upstream left as plain literals are
  wrapped in `qsTr()` in place (e.g. "Recall" in `Deck/Loop.qml`, "Range" in
  `RangeButton.qml`, "Eject" in `Sampler.qml`), instead of copying a whole
  file just to translate a label. These one-line changes rarely conflict and
  are candidates to send upstream. Anything beyond `qsTr()` still goes into
  an override.

To run the Android UI on a desktop build, apply the overrides to a copy of
`res/qml`
(`cmake -DQML_DIR=<copy> -P cmake/modules/apply_android_qml_overrides.cmake`)
and start Mixxx with `--new-ui --resource-path` pointing at a resource folder
that contains it.

### C++ and CMake

The same goal applies to the C++ code: Android features live in their own
files, and upstream files only get small hooks.

* `cmake/modules/MixxxAndroid.cmake` adds the Android sources, definitions
  and build steps. `CMakeLists.txt` only includes it at the end; what has to
  happen at a fixed point (toolchain setup, Qt components, the Android
  packaging properties and permissions) stays in `CMakeLists.txt`.
* QML features only used by the Android UI are separate singletons:
  `Mixxx.MobileLibrary`, `Mixxx.MobileAudio`, `Mixxx.MobileControllers`,
  `Mixxx.Language`, `Mixxx.StreamingManager` and the
  `Mixxx.LibraryFeatureSource` type. The singletons that need core services
  get them in `src/qml/qmlmobilesingletons.cpp`, which `coreservices.cpp`
  calls once.
* `SoundManagerAndroid` holds the Android audio logic (routing to DJ
  controllers, fallback to the speaker, USB hotplug); `SoundManager` calls
  it at a few points. Likewise `AndroidUsbSoundDevices` for
  `PortAudioEnumerator`, `mappingmatcher.cpp` for `ControllerManager` and
  `librarycoverloader.cpp` for `AsyncImageProvider`.
* The remaining changes to upstream files are fixes of upstream code (for
  example in `qmlpreferencesproxy.cpp`, `controller.h` or the Oboe setup in
  `portaudioenumerator.cpp`). The best way to keep them from conflicting is to
  contribute them to mixxxdj/mixxx.

> _End of AI-written section._

## Translations

> _The following section was written by an AI agent (Claude Code)._

The UI language is chosen in *Settings → Interface → Language* and is applied
immediately. It is stored in the same `[Config],Locale` key as the desktop
preferences; "System default" follows the Android language. The selector only
lists the languages that have a `mixxx-android_<lang>` catalog (plus English):
the upstream catalogs don't cover the QML UI, so other languages would still
show it in English.

The source language of all UI strings is English (`qsTr("...")`). Strings of
the QML UI and of the Android-only C++ code are kept in their own catalogs,
`res/translations/mixxx-android_<lang>.ts`, which are loaded on top of the
upstream `mixxx_<lang>.qm` files. The upstream catalogs are never edited, so
merging `mixxxdj/mixxx` does not cause translation conflicts.

After changing UI strings, refresh the catalogs and the compiled `.qm` files
(Qt 6 `lupdate`/`lrelease` in `PATH` or `QT_BIN`):

```sh
tools/android_translations.sh        # update the existing catalogs
tools/android_translations.sh fr     # also start a new French catalog
```

Then fill in the `<translation>` entries (e.g. with Qt Linguist) and run the
script again. Commit both the `.ts` and the `.qm` files.

> _End of AI-written section._

## Permissions

* `READ_MEDIA_AUDIO` (Android 13+) resp. `READ_EXTERNAL_STORAGE` are requested
  at every start; without them the library scan finds nothing.
* `MANAGE_EXTERNAL_STORAGE` ("All files access") is optional and only needed to
  add music directories outside of the media store. Mixxx opens the system
  settings page for it once, on first run.
* `usb.host` is declared as *not* required so that devices without a USB host
  port — many tablets, Chromebooks and emulators — can install Mixxx. Wired
  MIDI/HID controllers are unavailable there.

## Known limitations

* Audio stops being reliable when Mixxx is sent to the background: there is no
  foreground service yet, so Android may throttle or kill the audio thread.
* Recording and broadcasting write to the app private directory unless "All
  files access" has been granted.
* The desktop (QWidget) skins are not built for Android, only the QML UI is.
