// Pioneered Overview View Component
// Main performance screen: Stacked waveforms, BeatFX, and dual touch decks
// Copyright (C) 2017 Sven Boekelder (timewasternl)
// Copyright (C) 2026 Mixxx Development Team
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Mixxx 1.0 as Mixxx
import ".." as Skin
import "."

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // ================= TOP HALF: WAVEFORMS + BEAT FX =================
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            spacing: 4

            // Left: Dual stacked scrolling waveforms
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 2

                // Waveform Channel 1
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: "#182030"
                    border.width: 1
                    clip: true
                    color: "#000000"
                    radius: 3

                    Skin.WaveformDisplay {
                        anchors.fill: parent
                        group: "[Channel1]"
                    }
                }

                // Waveform Channel 2
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: "#301d14"
                    border.width: 1
                    clip: true
                    color: "#000000"
                    radius: 3

                    Skin.WaveformDisplay {
                        anchors.fill: parent
                        group: "[Channel2]"
                    }
                }
            }

            // Right: Beat FX Unit
            PioneeredBeatFX {
                Layout.fillHeight: true
                Layout.preferredWidth: root.width > 640 ? 150 : 125
            }
        }

        // ================= BOTTOM HALF: DUAL PIONEER DECKS =================
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
}
