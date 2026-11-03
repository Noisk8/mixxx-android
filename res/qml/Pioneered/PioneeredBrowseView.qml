// Pioneered Browse View Component
// Full library browser with bottom mini decks for mixing while browsing
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

        // ================= TOP: FULL LIBRARY BROWSER =================
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: PioneeredTheme.borderColor
            border.width: 1
            clip: true
            color: PioneeredTheme.backgroundColor
            radius: 4

            Skin.Library {
                id: libraryWidget

                anchors.fill: parent
            }
        }

        // ================= BOTTOM: DUAL DECKS PINNED =================
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
