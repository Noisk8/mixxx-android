// Pioneered Samplers View Component
// 16 Touch Sampler Pads with dual deck monitoring
// Copyright (C) 2017 Sven Boekelder (timewasternl)
// Copyright (C) 2026 Mixxx Development Team
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Mixxx 1.0 as Mixxx
import "."

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // ================= TOP: 16 SAMPLER PADS =================
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: PioneeredTheme.borderColor
            border.width: 1
            clip: true
            color: PioneeredTheme.backgroundColor
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 8

                // Samplers Deck 1 Side (Samplers 1-8)
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: PioneeredTheme.deck1Accent
                        font.bold: true
                        font.pixelSize: 10
                        text: qsTr("SAMPLERS 1 - 8 (DECK 1)")
                    }
                    GridLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        columnSpacing: 4
                        columns: 4
                        rowSpacing: 4
                        rows: 2

                        Repeater {
                            model: 8

                            SamplerPad {
                                required property int index

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                samplerNumber: index + 1
                            }
                        }
                    }
                }

                // Divider line
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    color: PioneeredTheme.borderColor
                }

                // Samplers Deck 2 Side (Samplers 9-16)
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: PioneeredTheme.deck2Accent
                        font.bold: true
                        font.pixelSize: 10
                        text: qsTr("SAMPLERS 9 - 16 (DECK 2)")
                    }
                    GridLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        columnSpacing: 4
                        columns: 4
                        rowSpacing: 4
                        rows: 2

                        Repeater {
                            model: 8

                            SamplerPad {
                                required property int index

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                samplerNumber: index + 9
                            }
                        }
                    }
                }
            }
        }

        // ================= BOTTOM: DUAL DECKS =================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 185
            spacing: 4

            PioneeredDeck {
                Layout.fillHeight: true
                Layout.fillWidth: true
                channelNumber: 1
                group: "[Channel1]"
            }
            PioneeredDeck {
                Layout.fillHeight: true
                Layout.fillWidth: true
                channelNumber: 2
                group: "[Channel2]"
            }
        }
    }

    // ================= REUSABLE TOUCH SAMPLER PAD COMPONENT =================
    component SamplerPad: Rectangle {
        id: pad

        readonly property var currentTrack: pad.player?.currentTrack
        readonly property bool isLoaded: !!pad.player?.isLoaded
        readonly property var player: Mixxx.PlayerManager.getPlayer(pad.samplerGroup)
        readonly property string samplerGroup: "[Sampler" + samplerNumber + "]"
        required property int samplerNumber

        border.color: playControl.value > 0 ? "#ff5252" : (padMouse.pressed ? "#ff8a80" : PioneeredTheme.activeRed)
        border.width: 1.5
        color: playControl.value > 0 ? PioneeredTheme.activeRed : (padMouse.pressed ? PioneeredTheme.activeRedPressed : "#141722")
        radius: 4

        Mixxx.ControlProxy {
            id: cueGotoAndPlayControl

            group: pad.samplerGroup
            key: "cue_gotoandplay"
        }
        Mixxx.ControlProxy {
            id: cueDefaultControl

            group: pad.samplerGroup
            key: "cue_default"
        }
        Mixxx.ControlProxy {
            id: playControl

            group: pad.samplerGroup
            key: "play"
        }
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2
            width: parent.width - 6

            Text {
                Layout.alignment: Qt.AlignHCenter
                color: playControl.value > 0 ? "#ffffff" : PioneeredTheme.tabActive
                font.bold: true
                font.pixelSize: 13
                text: "S" + pad.samplerNumber
            }
            Text {
                Layout.fillWidth: true
                color: playControl.value > 0 ? "#ffffff" : PioneeredTheme.textSecondary
                elide: Text.ElideRight
                font.pixelSize: 9
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (!pad.isLoaded)
                        return qsTr("Empty");
                    return pad.currentTrack?.title || qsTr("Sample");
                }
            }
        }
        MouseArea {
            id: padMouse

            anchors.fill: parent
            preventStealing: true

            onPressAndHold: cueDefaultControl.value = 1
            onPressed: cueGotoAndPlayControl.value = 1
            onReleased: cueGotoAndPlayControl.value = 0
        }
    }
}
