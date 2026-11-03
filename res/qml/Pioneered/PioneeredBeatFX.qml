// Pioneered BeatFX Component
// Beat FX section with master meter and 3 effect units
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

    border.color: PioneeredTheme.borderColor
    border.width: 1
    clip: true
    color: PioneeredTheme.cardBackground
    implicitWidth: 155
    radius: 4

    // Master Unit Controls
    Mixxx.ControlProxy {
        id: masterMixControl

        group: "[EffectRack1_EffectUnit1]"
        key: "mix"
    }
    Mixxx.ControlProxy {
        id: assignDeck1Control

        group: "[EffectRack1_EffectUnit1]"
        key: "group_[Channel1]_enable"
    }
    Mixxx.ControlProxy {
        id: assignDeck2Control

        group: "[EffectRack1_EffectUnit1]"
        key: "group_[Channel2]_enable"
    }
    Mixxx.ControlProxy {
        id: assignMasterControl

        group: "[EffectRack1_EffectUnit1]"
        key: "group_[Master]_enable"
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 3

        // ================= HEADER: BEAT FX TITLE + VU METER =================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: PioneeredTheme.headerBackground
            radius: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 3
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    color: PioneeredTheme.tabActive
                    font.bold: true
                    font.letterSpacing: 1.5
                    font.pixelSize: 11
                    text: qsTr("BEAT FX")
                }

                // Master FX Level Meter
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    border.color: "#252834"
                    border.width: 1
                    clip: true
                    color: "#05070a"
                    radius: 1

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.top: parent.top
                        color: PioneeredTheme.tabActive
                        width: parent.width * Math.max(0, Math.min(1, masterMixControl.value || 0.5))
                    }
                }
            }
        }

        // Channel Assignment Pills (1, 2, MST)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            spacing: 2

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                border.color: PioneeredTheme.deck1Accent
                border.width: 1
                color: assignDeck1Control.value > 0 ? PioneeredTheme.deck1Accent : "#121520"
                radius: 2

                Text {
                    anchors.centerIn: parent
                    color: assignDeck1Control.value > 0 ? "#000000" : PioneeredTheme.deck1Accent
                    font.bold: true
                    font.pixelSize: 9
                    text: "1"
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: assignDeck1Control.value = (assignDeck1Control.value > 0 ? 0 : 1)
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                border.color: PioneeredTheme.deck2Accent
                border.width: 1
                color: assignDeck2Control.value > 0 ? PioneeredTheme.deck2Accent : "#121520"
                radius: 2

                Text {
                    anchors.centerIn: parent
                    color: assignDeck2Control.value > 0 ? "#000000" : PioneeredTheme.deck2Accent
                    font.bold: true
                    font.pixelSize: 9
                    text: "2"
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: assignDeck2Control.value = (assignDeck2Control.value > 0 ? 0 : 1)
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                border.color: PioneeredTheme.tabActive
                border.width: 1
                color: assignMasterControl.value > 0 ? PioneeredTheme.tabActive : "#121520"
                radius: 2

                Text {
                    anchors.centerIn: parent
                    color: assignMasterControl.value > 0 ? "#000000" : PioneeredTheme.tabActive
                    font.bold: true
                    font.pixelSize: 9
                    text: "MST"
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: assignMasterControl.value = (assignMasterControl.value > 0 ? 0 : 1)
                }
            }
        }

        // ================= 3 EFFECT UNITS =================
        Repeater {
            model: 3

            Rectangle {
                id: effectUnitBox

                readonly property string effectGroup: "[EffectRack1_EffectUnit1_Effect" + fxNum + "]"
                readonly property int fxNum: index + 1
                required property int index

                Layout.fillHeight: true
                Layout.fillWidth: true
                border.color: fxEnabledControl.value > 0 ? PioneeredTheme.activeRed : PioneeredTheme.borderColor
                border.width: 1
                color: "#0a0c10"
                radius: 3

                Mixxx.ControlProxy {
                    id: fxEnabledControl

                    group: effectUnitBox.effectGroup
                    key: "enabled"
                }
                Mixxx.ControlProxy {
                    id: fxMetaControl

                    group: effectUnitBox.effectGroup
                    key: "meta"
                }
                Mixxx.ControlProxy {
                    id: fxNextControl

                    group: effectUnitBox.effectGroup
                    key: "next_effect"
                }
                Mixxx.ControlProxy {
                    id: fxPrevControl

                    group: effectUnitBox.effectGroup
                    key: "prev_effect"
                }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 2

                    // Unit Label & Next Effect selector
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18
                        spacing: 2

                        Text {
                            color: fxEnabledControl.value > 0 ? PioneeredTheme.activeRed : PioneeredTheme.textSecondary
                            font.bold: true
                            font.pixelSize: 9
                            text: "FX " + effectUnitBox.fxNum
                        }
                        Item {
                            Layout.fillWidth: true
                        }

                        // Mini Cycle Buttons
                        Rectangle {
                            Layout.preferredHeight: 16
                            Layout.preferredWidth: 18
                            color: "#181b24"
                            radius: 2

                            Text {
                                anchors.centerIn: parent
                                color: "#ffffff"
                                font.pixelSize: 8
                                text: "◀"
                            }
                            MouseArea {
                                anchors.fill: parent

                                onClicked: fxPrevControl.value = 1
                            }
                        }
                        Rectangle {
                            Layout.preferredHeight: 16
                            Layout.preferredWidth: 18
                            color: "#181b24"
                            radius: 2

                            Text {
                                anchors.centerIn: parent
                                color: "#ffffff"
                                font.pixelSize: 8
                                text: "▶"
                            }
                            MouseArea {
                                anchors.fill: parent

                                onClicked: fxNextControl.value = 1
                            }
                        }
                    }

                    // Meta Intensity Slider / Meter
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 12
                        border.color: "#252834"
                        border.width: 1
                        clip: true
                        color: "#05070a"
                        radius: 2

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.top: parent.top
                            color: fxEnabledControl.value > 0 ? PioneeredTheme.activeRed : PioneeredTheme.accentBlue
                            width: parent.width * Math.max(0, Math.min(1, fxMetaControl.value || 0))
                        }
                        MouseArea {
                            anchors.fill: parent
                            preventStealing: true

                            onPositionChanged: mouse => {
                                var val = Math.max(0, Math.min(1, mouse.x / parent.width));
                                fxMetaControl.value = val;
                            }
                            onPressed: mouse => {
                                var val = Math.max(0, Math.min(1, mouse.x / parent.width));
                                fxMetaControl.value = val;
                            }
                        }
                    }

                    // Active / Off Toggle Button (Touch size >= 40dp)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        border.color: fxEnabledControl.value > 0 ? "#ff5252" : PioneeredTheme.borderColor
                        border.width: 1.5
                        color: fxEnabledControl.value > 0 ? PioneeredTheme.activeRed : (toggleMouse.pressed ? "#252a38" : "#141722")
                        radius: 3

                        Text {
                            anchors.centerIn: parent
                            color: fxEnabledControl.value > 0 ? "#ffffff" : PioneeredTheme.textSecondary
                            font.bold: true
                            font.pixelSize: 11
                            text: fxEnabledControl.value > 0 ? qsTr("ACTIVE") : qsTr("OFF")
                        }
                        MouseArea {
                            id: toggleMouse

                            anchors.fill: parent
                            preventStealing: true

                            onClicked: fxEnabledControl.value = (fxEnabledControl.value > 0 ? 0 : 1)
                        }
                    }
                }
            }
        }
    }
}
