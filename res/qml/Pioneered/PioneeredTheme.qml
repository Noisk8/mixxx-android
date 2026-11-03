// Pioneered Theme
// Pioneer XDJ inspired dark theme for Mixxx Android
// Copyright (C) 2017 Sven Boekelder (timewasternl)
// Copyright (C) 2026 Mixxx Development Team
// SPDX-License-Identifier: GPL-3.0-or-later

pragma Singleton
import QtQuick 2.12

QtObject {
    id: root

    // Alert / BeatFX / Sampler
    readonly property color activeRed: "#d73535"
    readonly property color activeRedPressed: "#9e1f1f"

    // Core Backgrounds
    readonly property color backgroundColor: "#000000"
    readonly property color borderActive: "#c3d541"
    readonly property color borderColor: "#32323c"
    readonly property color cardBackground: "#0d0f14"
    readonly property color cardBackgroundElevated: "#151820"
    readonly property color cueOrange: "#eb870f"
    readonly property color cueOrangePressed: "#b86300"

    // Deck Accents
    readonly property color deck1Accent: "#00b0ff"
    readonly property color deck1AccentDim: "#0a3866"
    readonly property color deck2Accent: "#ff6000"
    readonly property color deck2AccentDim: "#662800"
    readonly property color headerBackground: "#32323c"

    // Touch sizing
    readonly property int minTouchTarget: 48

    // Transport Colors (Authentic Pioneer hardware)
    readonly property color playGreen: "#6ee128"
    readonly property color playGreenPressed: "#4db815"
    readonly property color syncBlue: "#2d85cd"
    readonly property color syncBluePressed: "#1a5b8c"

    // Pioneer Brand Accent Colors
    readonly property color tabActive: "#c3d541"
    readonly property color tabBorderInactive: "#32323c"
    readonly property color tabInactive: "#808595"
    readonly property color textMuted: "#666b7a"

    // Text & Borders
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#9da3b4"
    readonly property color titleBannerBackground: "#112f5c"
}
