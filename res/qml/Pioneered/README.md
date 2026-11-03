<!-- START_AI_GENERATED_DISCLAIMER -->
<!-- This documentation was prepared with the assistance of an AI Agent (Antigravity). -->

# Pioneered Skin for Mixxx Android (QML)

## Overview
This is a modern QML port of the classic **Pioneered** skin for Mixxx, adapted specifically for touchscreens and standalone Android usage (tablets and phones in landscape orientation).

## Origin and Attribution
- Original skin: **Pioneered** for Mixxx desktop by Sven Boekelder (`timewasternl`), with contributions from GorgiAstro, BvOBart, and bencejuhaasz.
- Reference repository: <https://github.com/timewasternl/Pioneered>
- License: **GNU General Public License v3.0 (GPL-3.0-or-later)**.
- Original icons (`keylock.svg`, `quantize.svg`) are sourced from the Deere theme included with Mixxx and licensed under GPL.
- Mixxx Android is licensed under **GPL-2.0-or-later**, ensuring full legal compatibility under GPL-3.0.

## Features
- **3-Tab Navigation Bar**:
  - `OVERVIEW`: Main mixing screen with stacked scrolling waveforms, 3-unit BeatFX section, and dual touch decks.
  - `BROWSE`: Full library navigation with search, folder tree, and pinned mini decks for mixing while browsing.
  - `SAMPLES`: 16 touch sampler pads (8 per deck side) with instant cue/play triggering and track title info.
- **Pioneer XDJ Aesthetics**:
  - Authentic color palette: `#000000` pitch black background, `#c3d541` Pioneer lime active tabs, `#112f5c` deep blue deck banners, `#6ee128` green PLAY, `#eb870f` orange CUE, `#2d85cd` blue SYNC, `#d73535` red active FX/sampler.
- **Touch-First Controls**:
  - Minimum 48dp touch targets on transport and main buttons.
  - Multitouch capable: DJs can trigger cue/play/faders on both decks simultaneously without gesture stealing.
  - Zero hover or tooltip dependencies.
  - Proportional layout scaling from small phone screens (480x420) to full tablets.
- **Hardware & Android System Parity**:
  - Topbar retains one-touch **SPLIT CUE** toggle (`[Master], headSplit`), **REC** toggle with blinking timer (`[Recording], status`), **LOAD 1** and **LOAD 2** quick load buttons, and Settings gear button.
  - Full seamless hot-switching in Settings → Interface → Skin without interrupting audio or loaded tracks.

<!-- END_AI_GENERATED_DISCLAIMER -->
