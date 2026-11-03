// Pioneered Topbar Component
// Authentic Pioneer XDJ style top bar with tabs and mobile controls
// Copyright (C) 2017 Sven Boekelder (timewasternl)
// Copyright (C) 2026 Mixxx Development Team
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Mixxx 1.0 as Mixxx
import "."

Rectangle {
    id: root

    property int activeTab: 0 // 0: Overview, 1: Browse, 2: Samplers

    signal requestLegacyPreferences
    signal requestLoadDeck(string group)
    signal requestSettings
    signal tabSelected(int index)

    border.color: PioneeredTheme.borderColor
    border.width: 1
    color: PioneeredTheme.backgroundColor
    height: 42

    Mixxx.ControlProxy {
        id: headSplitControl

        group: "[Master]"
        key: "headSplit"
    }
    Mixxx.ControlProxy {
        id: recordingStatusControl

        group: "[Recording]"
        key: "status"

        onValueChanged: {
            if (value > 0) {
                recTimer.recSeconds = 0;
                recTimer.start();
            } else {
                recTimer.stop();
            }
        }
    }
    Mixxx.ControlProxy {
        id: recordingToggleControl

        group: "[Recording]"
        key: "toggle_recording"
    }
    Timer {
        id: recTimer

        property bool blink: false
        property int recSeconds: 0
        property string recTimeStr: "00:00"

        interval: 500
        repeat: true

        onTriggered: {
            blink = !blink;
            if (blink) {
                recSeconds++;
                var m = Math.floor(recSeconds / 60);
                var s = recSeconds % 60;
                recTimeStr = (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
            }
        }
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        // Logo
        Text {
            Layout.alignment: Qt.AlignVCenter
            color: PioneeredTheme.tabActive
            font.bold: true
            font.letterSpacing: 2
            font.pixelSize: 13
            text: "PIONEERED"
        }
        Item {
            Layout.preferredWidth: 4
        }

        // Center: Pioneer Tabs (Overview, Browse, Sampler)
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            // Tab 1: OVERVIEW
            Rectangle {
                Layout.preferredHeight: 34
                Layout.preferredWidth: Math.max(88, root.width > 700 ? 120 : 88)
                border.color: root.activeTab === 0 ? PioneeredTheme.tabActive : PioneeredTheme.tabBorderInactive
                border.width: root.activeTab === 0 ? 2 : 1
                color: root.activeTab === 0 ? PioneeredTheme.backgroundColor : "#101218"
                radius: 3

                Text {
                    anchors.centerIn: parent
                    color: root.activeTab === 0 ? PioneeredTheme.tabActive : PioneeredTheme.tabInactive
                    font.bold: true
                    font.letterSpacing: 1
                    font.pixelSize: 11
                    text: qsTr("OVERVIEW")
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.tabSelected(0)
                }
            }

            // Tab 2: BROWSE
            Rectangle {
                Layout.preferredHeight: 34
                Layout.preferredWidth: Math.max(88, root.width > 700 ? 120 : 88)
                border.color: root.activeTab === 1 ? PioneeredTheme.tabActive : PioneeredTheme.tabBorderInactive
                border.width: root.activeTab === 1 ? 2 : 1
                color: root.activeTab === 1 ? PioneeredTheme.backgroundColor : "#101218"
                radius: 3

                Text {
                    anchors.centerIn: parent
                    color: root.activeTab === 1 ? PioneeredTheme.tabActive : PioneeredTheme.tabInactive
                    font.bold: true
                    font.letterSpacing: 1
                    font.pixelSize: 11
                    text: qsTr("BROWSE")
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.tabSelected(1)
                }
            }

            // Tab 3: SAMPLES
            Rectangle {
                Layout.preferredHeight: 34
                Layout.preferredWidth: Math.max(88, root.width > 700 ? 120 : 88)
                border.color: root.activeTab === 2 ? PioneeredTheme.tabActive : PioneeredTheme.tabBorderInactive
                border.width: root.activeTab === 2 ? 2 : 1
                color: root.activeTab === 2 ? PioneeredTheme.backgroundColor : "#101218"
                radius: 3

                Text {
                    anchors.centerIn: parent
                    color: root.activeTab === 2 ? PioneeredTheme.tabActive : PioneeredTheme.tabInactive
                    font.bold: true
                    font.letterSpacing: 1
                    font.pixelSize: 11
                    text: qsTr("SAMPLES")
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.tabSelected(2)
                }
            }
        }
        Item {
            Layout.fillWidth: true
        }

        // Right side: Quick hardware & status controls
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 5

            // Quick LOAD Deck 1
            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 56
                border.color: PioneeredTheme.deck1Accent
                border.width: 1
                color: load1Mouse.pressed ? PioneeredTheme.deck1Accent : "#122036"
                radius: 3

                Text {
                    anchors.centerIn: parent
                    color: load1Mouse.pressed ? "#000000" : "#ffffff"
                    font.bold: true
                    font.pixelSize: 10
                    text: "LOAD 1"
                }
                MouseArea {
                    id: load1Mouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.requestLoadDeck("[Channel1]")
                }
            }

            // Quick LOAD Deck 2
            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 56
                border.color: PioneeredTheme.deck2Accent
                border.width: 1
                color: load2Mouse.pressed ? PioneeredTheme.deck2Accent : "#331a0a"
                radius: 3

                Text {
                    anchors.centerIn: parent
                    color: load2Mouse.pressed ? "#000000" : "#ffffff"
                    font.bold: true
                    font.pixelSize: 10
                    text: "LOAD 2"
                }
                MouseArea {
                    id: load2Mouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.requestLoadDeck("[Channel2]")
                }
            }

            // SPLIT Cue Toggle
            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 52
                border.color: headSplitControl.value > 0 ? "#ffb74d" : PioneeredTheme.borderColor
                border.width: 1
                color: headSplitControl.value > 0 ? "#b87000" : "#1a1c24"
                radius: 3

                Text {
                    anchors.centerIn: parent
                    color: headSplitControl.value > 0 ? "#ffffff" : PioneeredTheme.textSecondary
                    font.bold: true
                    font.pixelSize: 10
                    text: "SPLIT"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: headSplitControl.value = (headSplitControl.value > 0 ? 0 : 1)
                }
            }

            // REC Button
            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: recordingStatusControl.value > 0 ? 68 : 46
                border.color: recordingStatusControl.value > 0 ? "#ff5252" : PioneeredTheme.borderColor
                border.width: 1
                color: recordingStatusControl.value > 0 ? (recTimer.blink ? "#7f0000" : "#d73535") : "#1a1c24"
                radius: 3

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        Layout.preferredHeight: 7
                        Layout.preferredWidth: 7
                        color: recordingStatusControl.value > 0 ? "#ffffff" : "#d73535"
                        radius: 3.5
                    }
                    Text {
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 10
                        text: recordingStatusControl.value > 0 ? recTimer.recTimeStr : "REC"
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: recordingToggleControl.value = 1
                }
            }

            // Settings Button (Gear)
            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 36
                border.color: PioneeredTheme.borderColor
                border.width: 1
                color: settingsMouse.pressed ? "#32323c" : "#1a1c24"
                radius: 3

                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    height: 16
                    source: "qrc:/res/qml/images/gear.svg"
                    width: 16
                }
                MouseArea {
                    id: settingsMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.requestSettings()
                    onPressAndHold: root.requestLegacyPreferences()
                }
            }
        }
    }
}
