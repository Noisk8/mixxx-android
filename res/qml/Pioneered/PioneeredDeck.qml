// Pioneered Deck Component
// Pioneer XDJ inspired touch deck layout with full transport & overview
// Copyright (C) 2017 Sven Boekelder (timewasternl)
// Copyright (C) 2026 Mixxx Development Team
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Mixxx 1.0 as Mixxx
import ".." as Skin
import "."

Rectangle {
    id: root

    required property int channelNumber // 1 or 2

    readonly property var currentTrack: deckPlayer?.currentTrack
    readonly property color deckAccent: isDeck1 ? PioneeredTheme.deck1Accent : PioneeredTheme.deck2Accent
    readonly property color deckAccentDim: isDeck1 ? PioneeredTheme.deck1AccentDim : PioneeredTheme.deck2AccentDim
    readonly property var deckPlayer: Mixxx.PlayerManager.getPlayer(root.group)
    required property string group // e.g. "[Channel1]" or "[Channel2]"
    readonly property bool isDeck1: root.channelNumber === 1
    readonly property bool isLoaded: !!deckPlayer?.isLoaded
    property int timeMode: 0 // 0: REMAIN, 1: ELAPSED

    border.color: playControl.value > 0 ? PioneeredTheme.borderColor : "#222530"
    border.width: 1
    clip: true
    color: PioneeredTheme.cardBackground
    radius: 4

    // Mixxx Control Bindings
    Mixxx.ControlProxy {
        id: playControl

        group: root.group
        key: "play"
    }
    Mixxx.ControlProxy {
        id: cueControl

        group: root.group
        key: "cue_default"
    }
    Mixxx.ControlProxy {
        id: bpmControl

        group: root.group
        key: "bpm"
    }
    Mixxx.ControlProxy {
        id: visualBpmControl

        group: root.group
        key: "visual_bpm"
    }
    Mixxx.ControlProxy {
        id: rateControl

        group: root.group
        key: "rate"
    }
    Mixxx.ControlProxy {
        id: rateRangeControl

        group: root.group
        key: "rateRange"
    }
    Mixxx.ControlProxy {
        id: durationControl

        group: root.group
        key: "duration"
    }
    Mixxx.ControlProxy {
        id: playPositionControl

        group: root.group
        key: "playposition"
    }
    Mixxx.ControlProxy {
        id: keyControl

        group: root.group
        key: "visual_key"
    }
    Mixxx.ControlProxy {
        id: keylockControl

        group: root.group
        key: "keylock"
    }
    Mixxx.ControlProxy {
        id: quantizeControl

        group: root.group
        key: "quantize"
    }
    Mixxx.ControlProxy {
        id: syncEnabledControl

        group: root.group
        key: "sync_enabled"
    }
    Mixxx.ControlProxy {
        id: syncModeControl

        group: root.group
        key: "sync_mode"
    }
    Mixxx.ControlProxy {
        id: rateTempUpControl

        group: root.group
        key: "rate_temp_up"
    }
    Mixxx.ControlProxy {
        id: rateTempDownControl

        group: root.group
        key: "rate_temp_down"
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 3

        // ================= ROW 1: HEADER TITLE BANNER =================
        // Pioneer Deep Blue Title Banner (#112f5c)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: PioneeredTheme.titleBannerBackground
            radius: 2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                spacing: 6

                // Note icon ♫
                Text {
                    color: PioneeredTheme.tabActive
                    font.pixelSize: 12
                    text: "♫"
                }

                // Track Title & Artist
                Text {
                    Layout.fillWidth: true
                    color: PioneeredTheme.textPrimary
                    elide: Text.ElideRight
                    font.bold: true
                    font.pixelSize: 11
                    text: {
                        if (!root.isLoaded)
                            return qsTr("Deck %1 (No track loaded)").arg(root.channelNumber);
                        var t = root.currentTrack?.title || "";
                        var a = root.currentTrack?.artist || "";
                        return a.length > 0 ? (a + " — " + t) : t;
                    }
                }

                // Track Number Pill
                Rectangle {
                    Layout.preferredHeight: 18
                    Layout.preferredWidth: trackNumText.implicitWidth + 8
                    color: "#0a1e3b"
                    radius: 2
                    visible: root.isLoaded && (root.currentTrack?.trackNumber > 0)

                    Text {
                        id: trackNumText

                        anchors.centerIn: parent
                        color: "#90caf9"
                        font.bold: true
                        font.pixelSize: 9
                        text: "TRK " + (root.currentTrack?.trackNumber || 1)
                    }
                }
            }
        }

        // ================= ROW 2: PIONEER DIGITAL DASHBOARD =================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            spacing: 4

            // Deck Channel Tag (Deck 1 / Deck 2)
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 54
                border.color: root.deckAccent
                border.width: 1.5
                color: playControl.value > 0 ? root.deckAccentDim : "#141722"
                radius: 3

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: "#90a4ae"
                        font.bold: true
                        font.pixelSize: 8
                        text: "DECK"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: root.deckAccent
                        font.bold: true
                        font.pixelSize: 15
                        text: "" + root.channelNumber
                    }
                }
            }

            // Digital Time Display (Click toggles REMAIN / ELAPSED)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                border.color: timeMouse.containsMouse ? root.deckAccent : PioneeredTheme.borderColor
                border.width: 1
                color: "#05070a"
                radius: 3

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    spacing: 4

                    Text {
                        color: PioneeredTheme.tabActive
                        font.bold: true
                        font.pixelSize: 8
                        text: root.timeMode === 0 ? "REMAIN" : "TIME"
                    }
                    Text {
                        Layout.fillWidth: true
                        color: "#ffffff"
                        font.bold: true
                        font.family: "monospace"
                        font.pixelSize: 15
                        horizontalAlignment: Text.AlignRight
                        text: {
                            var dur = durationControl.value || 0;
                            var pos = playPositionControl.value || 0;
                            if (dur <= 0)
                                return "--:--.--";

                            var cur = Math.max(0, Math.min(dur, dur * pos));
                            var rem = Math.max(0, dur - cur);
                            var target = (root.timeMode === 0) ? rem : cur;

                            var m = Math.floor(target / 60);
                            var s = Math.floor(target % 60);
                            var ms = Math.floor((target % 1) * 10);
                            return (root.timeMode === 0 ? "-" : "") + m + ":" + (s < 10 ? "0" : "") + s + "." + ms;
                        }
                    }
                }
                MouseArea {
                    id: timeMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.timeMode = (root.timeMode === 0 ? 1 : 0)
                }
            }

            // Tempo / Rate Percentage
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 50
                border.color: PioneeredTheme.borderColor
                border.width: 1
                color: "#05070a"
                radius: 3

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: "#808595"
                        font.bold: true
                        font.pixelSize: 7
                        text: "TEMPO"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: root.deckAccent
                        font.bold: true
                        font.pixelSize: 10
                        text: {
                            var range = rateRangeControl.value > 0 ? rateRangeControl.value : 0.08;
                            var p = (rateControl.value || 0) * (range * 100);
                            return (p >= 0 ? "+" : "") + p.toFixed(1) + "%";
                        }
                    }
                }
            }

            // BPM Hero Display
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 68
                border.color: syncModeControl.value >= 2 ? "#ff9100" : (syncEnabledControl.value > 0 ? "#00e676" : root.deckAccent)
                border.width: 1.5
                color: "#05070a"
                radius: 3

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: "#808595"
                        font.bold: true
                        font.pixelSize: 7
                        text: "BPM"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: syncModeControl.value >= 2 ? "#ffb74d" : "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                        text: {
                            var b = visualBpmControl.value > 0 ? visualBpmControl.value : bpmControl.value;
                            return b > 0 ? b.toFixed(1) : "--.-";
                        }
                    }
                }
            }
        }

        // ================= ROW 3: HARDWARE MODES & MINI CONTROLS =================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 4

            // Musical Key Badge (♭♯)
            Rectangle {
                Layout.preferredHeight: 26
                Layout.preferredWidth: 54
                border.color: keyControl.value ? root.deckAccent : PioneeredTheme.borderColor
                border.width: 1
                color: keyControl.value ? "#101828" : "#0d0f14"
                radius: 3

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        color: PioneeredTheme.tabActive
                        font.pixelSize: 9
                        text: "♭♯"
                    }
                    Text {
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 10
                        text: keyControl.value ? keyControl.value.toString() : "--"
                    }
                }
            }

            // Keylock Toggle
            Rectangle {
                Layout.preferredHeight: 26
                Layout.preferredWidth: 44
                border.color: keylockControl.value > 0 ? PioneeredTheme.tabActive : PioneeredTheme.borderColor
                border.width: 1
                color: keylockControl.value > 0 ? "#1c3144" : "#101218"
                radius: 3

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        color: keylockControl.value > 0 ? PioneeredTheme.tabActive : PioneeredTheme.textSecondary
                        font.bold: true
                        font.pixelSize: 9
                        text: "KEY"
                    }
                    Rectangle {
                        color: keylockControl.value > 0 ? PioneeredTheme.tabActive : "#444955"
                        height: 5
                        radius: 2.5
                        width: 5
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: keylockControl.value = (keylockControl.value > 0 ? 0 : 1)
                }
            }

            // Quantize Toggle
            Rectangle {
                Layout.preferredHeight: 26
                Layout.preferredWidth: 44
                border.color: quantizeControl.value > 0 ? "#e040fb" : PioneeredTheme.borderColor
                border.width: 1
                color: quantizeControl.value > 0 ? "#2a1c38" : "#101218"
                radius: 3

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        color: quantizeControl.value > 0 ? "#e040fb" : PioneeredTheme.textSecondary
                        font.bold: true
                        font.pixelSize: 9
                        text: "QTZ"
                    }
                    Rectangle {
                        color: quantizeControl.value > 0 ? "#e040fb" : "#444955"
                        height: 5
                        radius: 2.5
                        width: 5
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: quantizeControl.value = (quantizeControl.value > 0 ? 0 : 1)
                }
            }
            Item {
                Layout.fillWidth: true
            }

            // Pitch Bend - / + Buttons for Touch Nudge
            Rectangle {
                Layout.preferredHeight: 26
                Layout.preferredWidth: 34
                border.color: PioneeredTheme.borderColor
                border.width: 1
                color: bendDownMouse.pressed ? "#32384a" : "#141722"
                radius: 3

                Text {
                    anchors.centerIn: parent
                    color: bendDownMouse.pressed ? "#ffffff" : PioneeredTheme.textSecondary
                    font.pixelSize: 10
                    text: "◀"
                }
                MouseArea {
                    id: bendDownMouse

                    anchors.fill: parent

                    onPressed: rateTempDownControl.value = 1
                    onReleased: rateTempDownControl.value = 0
                }
            }
            Rectangle {
                Layout.preferredHeight: 26
                Layout.preferredWidth: 34
                border.color: PioneeredTheme.borderColor
                border.width: 1
                color: bendUpMouse.pressed ? "#32384a" : "#141722"
                radius: 3

                Text {
                    anchors.centerIn: parent
                    color: bendUpMouse.pressed ? "#ffffff" : PioneeredTheme.textSecondary
                    font.pixelSize: 10
                    text: "▶"
                }
                MouseArea {
                    id: bendUpMouse

                    anchors.fill: parent

                    onPressed: rateTempUpControl.value = 1
                    onReleased: rateTempUpControl.value = 0
                }
            }
        }

        // ================= ROW 4: MINI OVERVIEW WAVEFORM =================
        // Pioneered iconic bottom mini overview
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            border.color: "#252834"
            border.width: 1
            clip: true
            color: "#000000"
            radius: 3

            Skin.WaveformOverview {
                anchors.fill: parent
                anchors.margins: 1
                group: root.group
            }
        }

        // ================= ROW 5: MAIN TOUCH TRANSPORT CONTROLS =================
        // Minimum 48dp touch targets, authentic Pioneer styling
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: 6

            // CUE BUTTON (Pioneer Amber #eb870f)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                border.color: PioneeredTheme.cueOrange
                border.width: 2
                color: cueMouse.pressed ? PioneeredTheme.cueOrangePressed : "#181410"
                radius: 6

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: cueMouse.pressed ? "#000000" : PioneeredTheme.cueOrange
                        font.bold: true
                        font.pixelSize: 14
                        text: "CUE"
                    }
                }
                MouseArea {
                    id: cueMouse

                    anchors.fill: parent
                    preventStealing: true

                    onPressed: cueControl.value = 1
                    onReleased: cueControl.value = 0
                }
            }

            // PLAY / PAUSE BUTTON (Pioneer Green #6ee128)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                border.color: PioneeredTheme.playGreen
                border.width: 2
                color: playControl.value > 0 ? PioneeredTheme.playGreen : (playMouse.pressed ? PioneeredTheme.playGreenPressed : "#0e1a10")
                radius: 6

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        color: playControl.value > 0 ? "#000000" : PioneeredTheme.playGreen
                        font.bold: true
                        font.pixelSize: 16
                        text: playControl.value > 0 ? "❚❚" : "▶"
                    }
                    Text {
                        color: playControl.value > 0 ? "#000000" : PioneeredTheme.playGreen
                        font.bold: true
                        font.pixelSize: 12
                        text: playControl.value > 0 ? "PLAYING" : "PLAY"
                    }
                }
                MouseArea {
                    id: playMouse

                    anchors.fill: parent
                    preventStealing: true

                    onClicked: playControl.value = (playControl.value > 0 ? 0 : 1)
                }
            }

            // SYNC / MASTER BUTTON (Pioneer Blue #2d85cd)
            Rectangle {
                Layout.preferredHeight: 48
                Layout.preferredWidth: 64
                border.color: syncModeControl.value >= 2 ? "#ff9100" : PioneeredTheme.syncBlue
                border.width: 2
                color: syncModeControl.value >= 2 ? "#ff9100" : (syncEnabledControl.value > 0 ? PioneeredTheme.syncBlue : (syncMouse.pressed ? "#163450" : "#0d1722"))
                radius: 6

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: (syncModeControl.value >= 2 || syncEnabledControl.value > 0) ? "#000000" : PioneeredTheme.syncBlue
                        font.bold: true
                        font.pixelSize: 11
                        text: syncModeControl.value >= 2 ? "MASTER" : "SYNC"
                    }
                }
                MouseArea {
                    id: syncMouse

                    anchors.fill: parent
                    preventStealing: true

                    onClicked: syncEnabledControl.value = !syncEnabledControl.value
                    onPressAndHold: syncModeControl.value = (syncModeControl.value >= 2 ? 0 : 2)
                }
            }
        }
    }
}
