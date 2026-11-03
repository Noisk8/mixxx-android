// Pioneered Skin Root Component
// Main container for the Pioneered touch skin in Mixxx Android
// Copyright (C) 2017 Sven Boekelder (timewasternl)
// Copyright (C) 2026 Mixxx Development Team
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Mixxx 1.0 as Mixxx
import "."

Item {
    id: root

    property int activeTab: 0 // 0: Overview, 1: Browse, 2: Samplers

    signal requestLegacyPreferences
    signal requestLoadDeck(string group)
    signal requestSettings

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Pioneer Topbar
        PioneeredTopbar {
            Layout.fillWidth: true
            activeTab: root.activeTab

            onRequestLegacyPreferences: root.requestLegacyPreferences()
            onRequestLoadDeck: group => root.requestLoadDeck(group)
            onRequestSettings: root.requestSettings()
            onTabSelected: index => {
                root.activeTab = index;
            }
        }

        // Active Tab Screen
        StackLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            currentIndex: root.activeTab

            PioneeredOverviewView {
                id: overviewScreen

            }
            PioneeredBrowseView {
                id: browseScreen

            }
            PioneeredSamplersView {
                id: samplersScreen

            }
        }
    }
}
