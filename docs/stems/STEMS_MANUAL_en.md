<!-- START_AI_GENERATED_DISCLAIMER -->
<!-- This manual was written by an AI Agent (Claude) from the code and from tests on a Lenovo Tab M11. -->

# 🎚 Stems manual — Mixxx Android

*[Versión en castellano](MANUAL_STEMS_es.md)*

**Stems** are the parts of a song on their own: **drums**, **bass**, **vocals** and **the rest** (synths, guitars, pads…). With them you can drop the vocals to play an instrumental, keep only the vocals for a live acapella, cut the bass of a track while the other one comes in, and so on.

Mixxx Android separates the stems **on the device itself**, with AI, without uploading anything. You only need a connection once, to download the models.

> Inspired by the live stems of **Dani Roman** ([@danigiavanni](https://www.instagram.com/danigiavanni)) and his [mixxx-stems](https://github.com/dromangdev/mixxx-stems) project.

---

## Contents

1. [How it works](#1-how-it-works)
2. [What you need](#2-what-you-need)
3. [Getting started: download a model](#3-getting-started-download-a-model)
4. [Which model to choose](#4-which-model-to-choose)
5. [Separate a track or a list](#5-separate-a-track-or-a-list)
6. [The queue](#6-the-queue)
7. [Using the stems on the deck](#7-using-the-stems-on-the-deck)
8. [Options (Settings → Stems)](#8-options-settings--stems)
9. [Where the stems are saved](#9-where-the-stems-are-saved)
10. [Separating while you play](#10-separating-while-you-play)
11. [Deleting stems and freeing space](#11-deleting-stems-and-freeing-space)
12. [Problems and error messages](#12-problems-and-error-messages)
13. [FAQ](#13-faq)
14. [Credits and licenses](#14-credits-and-licenses)

---

## 1. How it works

1. **You choose** which tracks to separate: one track or a whole list (a playlist, a crate, a Rekordbox playlist…). Nothing is ever separated on its own.
2. The app separates the tracks **one at a time, in the background**, while you keep using Mixxx.
3. The result is saved in a stem file **next to the original track**, which is not changed.
4. When you load that track on a deck, Mixxx uses the stems automatically and the **STEM** tab shows up in the pads. **The cues, beatgrid, BPM and key of the track are kept.**

Separating is heavy work: ideally **prepare your tracks before the session**, for example a whole playlist with the tablet charging.

---

## 2. What you need

| | Spleeter + Wiener | HTDemucs |
|---|---|---|
| Download (once) | 75 MB | 149 MB |
| Free memory (RAM) | ~250 MB | 2–2.5 GB |
| Recommended | Any phone or tablet | 6 GB of RAM or more |

- **Android 10 or later**, 64-bit ARM (like the rest of the app).
- **Space** for the stem files: about **18–36 MB per 5 minute track**, depending on the size option (see [Options](#8-options-settings--stems)).
- **An internet connection** only to download the models.

---

## 3. Getting started: download a model

1. Open **⚙️ Settings → 🎚 Stems**.
2. In **🧠 MODELS**, tap **⬇ 75 MB** on *Spleeter + Wiener* (recommended to start) and/or **⬇ 149 MB** on *HTDemucs*.
3. Wait until it finishes. You'll see the percentage and can **CANCEL** at any time. If it stops, tap again: it continues with the missing files.
4. When **✓** shows next to the name, the model is ready. The app checks that the downloaded files are not damaged.
5. Tap **⏱ MEASURE**: it separates 20 seconds of test audio and tells you **how long your device takes** for a 5 minute track. That time is shown afterwards when you choose the model.

> You can also download a model right from the **🎚 STEMS** window of the library, with the **⬇ DOWNLOAD** button.

To delete a model and get the space back: **DELETE** next to it. The stems already made are not deleted.

---

## 4. Which model to choose

| | **Spleeter + Wiener** | **HTDemucs** |
|---|---|---|
| Speed (5 min track) | **1–4 min** | **8–30 min** |
| Memory | ~250 MB | 2–2.5 GB |
| Quality | Good. The vocals may sound a bit metallic | **The best**: cleaner vocals and bass |
| Bass | Reinforced with the low end of the track | Very good |
| Best for | Separating on the go, big playlists, phones | Preparing your key tracks calmly |

**Times measured on a Lenovo Tab M11 (6 GB):** Spleeter + Wiener ~58 s (~76 s before v1.6.0) and HTDemucs ~15 min per 5 minute track. Every device is different: use **⏱ MEASURE** to know yours.

**Tips:**
- **Techno, house, electronic music:** Spleeter + Wiener is usually enough. Below ~150 Hz the bass gets everything that is not drums, so the bass sounds continuous, without gaps.
- **Acapellas and tracks with lots of vocals or guitars (rock, pop):** HTDemucs separates the vocals from the guitars much better.
- **Lots of tracks:** Spleeter. A 30 track playlist takes ~40 min with Spleeter against ~7 hours with HTDemucs.

---

## 5. Separate a track or a list

1. Go to the library (the **LIB** view or the library below the decks).
2. **One track:** select it and tap **🎚 STEMS** in the bottom bar.
   **A whole list:** open the list (playlist, crate, Rekordbox playlist, history…) **without selecting a track** and tap **🎚 STEMS**. With a track selected, you can switch between **SELECTED TRACK** and **WHOLE LIST**.
3. In the window:
   - You'll see how many tracks the list has and how many **already have stems** (those are skipped).
   - Choose the **model** by tapping its card (it shows **✓**). The estimated time on your device is shown.
   - If some tracks have stems, you can choose **Separate again the tracks that have stems: YES / NO**. Useful to redo them with HTDemucs.
   - If you are playing, an **orange warning** shows up (see [Separating while you play](#10-separating-while-you-play)).
4. Tap **🎚 SEPARATE** (or **🎚 SEPARATE N** for a list). The tracks go to the queue.

The library button shows **🎚 STEMS ✓** when the selected track already has stems.

---

## 6. The queue

While tracks are waiting, the **top bar** shows an indicator like **🎚 45% · 3** (progress of the current track · tracks waiting). Tap it to open the queue. It is also in **Settings → Stems → 📋 QUEUE**.

In the queue:
- Each track shows its state: 🕒 waiting, ⏳ separating (with the stage, the % and the **time left**), ✅ ready, ⚠️ error, ⏹ canceled.
- **⏸ PAUSE / ▶ RESUME:** stops the separation without losing the work done on the current track. While paused it uses no CPU.
- **CANCEL ALL:** empties the queue.
- **×** on a track: removes it from the queue (if it is being separated, it stops and the partial work is deleted).
- **CLEAR DONE:** removes the finished or failed tracks from the list.

**Good to know:**
- When a track is done, a message shows at the bottom: *"Stems ready…"*. **If that track was already loaded on a deck, load it again** to use the stems.
- **With the screen off or in another app** the separation goes on: you'll see a *"Separating stems — Track 2 of 5: 40%"* notification. The first time, Android may ask permission to show notifications; allow it to see the progress.
- **If you close the app**, the queue is kept. When you open it again it is **paused**: tap **▶ RESUME** to go on. That way it doesn't start by itself if Android closed the app for lack of memory.

---

## 7. Using the stems on the deck

Load a track with stems on a deck. The overview waveform shows the colors of each stem.

### Classic skin

The pads panel gets a third tab, **STEM**, under **CUE** and **LOOP**. Tap it:

| Action | Result |
|---|---|
| **Tap** DRUMS / BASS / OTHER / VOCALS | Mutes that stem (shown dark and struck through). Tap again to bring it back |
| **Long press** a stem | **Solo**: only that stem plays. Another long press on it brings all of them back |

**Examples:**
- **Instrumental:** tap **VOCALS**.
- **Acapella:** long press **VOCALS**.
- **Bass swap while mixing:** tap **BASS** on the incoming track and, at the drop, tap it again and mute the bass of the outgoing one.

### Booth skin

In the **DJ** view, tap the pad mode bar (**HOT CUE ⇅**) until it says **STEMS ⇅** (only there if the track has stems). The pads become four buttons, one per stem, that work like those of Classic: **tap** to mute or unmute it, **long press** to play only that one (another long press brings all back).

In **Booth** and **Lite**, the **🎚 %** indicator in the top bar opens the queue while tracks are being separated. Lite has no stem controls: the track plays in full.

### In every skin

Everything else works as usual: keylock, loops, hotcues, scratching, effects and sync. When you load another track, all stems play again (standard Mixxx option).

---

## 8. Options (Settings → Stems)

| Option | Buttons | What it does |
|---|---|---|
| **Model** | ASK · SPLEETER · HTDEMUCS | The model chosen by default in the 🎚 STEMS window. With ASK the first downloaded one is chosen and you change it yourself |
| **Size of the stem files** | LIGHT ~18 MB · NORMAL ~24 MB · HIGH ~36 MB | Compression quality (AAC at 96, 128 or 192 kbps per stem), per 5 minute track. NORMAL is transparent for DJing; HIGH if you also use the stems for producing |
| **While a deck plays** | GO ON SLOWER · PAUSE | With GO ON SLOWER the separation uses half the cores while any deck plays. With PAUSE, the queue waits until you stop all decks |
| **Only while charging** | YES · NO | With YES, the queue only moves on while the device is charging (handy for HTDemucs) |

---

## 9. Where the stems are saved

**Next to each track**, in a hidden **`.stems`** folder:

```
Music/
├── Artist - Track.mp3
└── .stems/
    └── Artist - Track.mp3.stem.mp4
```

- The file is a **`.stem.mp4`**, the stem format of Native Instruments (Traktor and other programs read it too). It holds the original mix and the 4 stems.
- The folder is **hidden**, so **the stems don't show up twice** in your library.
- If you **move or rename** the track, also move its file in `.stems` (same name plus `.stem.mp4`), or separate it again.
- **USB drives that Android doesn't mount** (Rekordbox sticks formatted without a partition table, which Mixxx reads by itself, read-only) and other folders that can't be written: the stems are saved **inside the app**. They work the same, but only on this device.

---

## 10. Separating while you play

Separating uses a lot of CPU. Mixxx runs it at **low priority** so that the audio and the screen come first, but on modest devices **it may cause audio dropouts**. That's why:

- The 🎚 STEMS window **warns you** if a deck is playing.
- By default, while a deck plays it uses **half the CPU** (slower).
- To play with no risk at all, choose **While a deck plays → PAUSE** in Settings → Stems: the queue will wait until you stop.
- The safest: **prepare your playlists before the session**.

---

## 11. Deleting stems and freeing space

- **Of a track or a list:** in the library, open **🎚 STEMS** and tap **🗑 DELETE STEMS**. Only the stem files are deleted; the original tracks are not touched.
- **Those kept inside the app:** Settings → Stems → **💾 STORAGE** shows their size and deletes them with **DELETE**.
- **The models:** Settings → Stems → **DELETE** next to each model.

---

## 12. Problems and error messages

| Message | What happens | What to do |
|---|---|---|
| *The model is missing or damaged* | The model is not downloaded or a file is corrupt | Settings → Stems: DELETE the model and download it again |
| *Not enough memory* | HTDemucs stopped because Android was running out of memory | Close other apps, load fewer decks/effects, or use Spleeter |
| *The file can't be found* | The track was moved or deleted after being queued | Queue it again |
| *The audio of the file can't be read* | Unsupported format, damaged file or shorter than 1 second | Try another copy of the file |
| *Too long* | More than 20 minutes (recorded sets, mixes) | Stems are meant for single tracks |
| *The stem file can't be saved* | No space or no write permission | Free some space; check the app's file access permission |
| *The AI engine can't be loaded* | The device is not compatible with ONNX Runtime | Report it with your device model |
| *The download failed* | No connection or the download was interrupted | Tap ⬇ again; it continues where it stopped |

**Other cases:**
- **The STEM tab doesn't show up:** the track has no stems, or it was loaded before they were ready. Load it again.
- **The queue doesn't move:** check the reason in the queue: *Paused* (tap RESUME), *Waiting until the decks stop playing* or *Waiting for the charger*.
- **Dropouts when separating while playing:** choose *While a deck plays → PAUSE*.

---

## 13. FAQ

**Is my original file changed?** No. The stems go in a separate file.

**Do I need internet to separate?** No, only to download the models once. The separation runs 100% on the device: your tracks are not uploaded anywhere.

**Can I use the stems in another program?** Yes: `.stem.mp4` is the standard Native Instruments format (Traktor, for example).

**Can I separate on a phone?** Yes. Spleeter runs well on almost any phone. HTDemucs needs a lot of free RAM (2–2.5 GB).

**Why isn't everything separated automatically?** To not waste battery, space or CPU on tracks you won't use. You choose what to separate.

**Can I redo a track with the other model?** Yes: 🎚 STEMS → choose the model → *Separate again the tracks that have stems: YES*.

**What if I mix tracks with and without stems?** No problem: tracks without stems work as always.

---

## 14. Credits and licenses

- **Idea and inspiration:** Dani Roman ([@danigiavanni](https://www.instagram.com/danigiavanni)), [dromangdev/mixxx-stems](https://github.com/dromangdev/mixxx-stems).
- **Spleeter** by Deezer — MIT license.
- **HTDemucs** (Demucs v4) by Meta — MIT license. ONNX conversion by StemSplitio; quantized to 8 bits for mobile devices.
- **ONNX Runtime** by Microsoft — MIT license.
- **Mixxx** — GPL v2 license.

<!-- END_AI_GENERATED_DISCLAIMER -->
