pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Mixxx 1.0 as Mixxx
import ".." as Skin
import "../Effects" as Effects

Item {
    id: root

    readonly property int deckHeight: Math.min(172, Math.round(height * 0.46))

    signal loadRequested(string group)

    Item {
        id: waves

        anchors.bottom: decks.top
        anchors.bottomMargin: 4
        anchors.left: parent.left
        anchors.right: effects.left
        anchors.rightMargin: 4
        anchors.top: parent.top

        Repeater {
            model: 2

            Item {
                id: lane

                readonly property string group: "[Channel" + (index + 1) + "]"
                required property int index

                height: parent.height / 2 - 2
                width: parent.width
                x: 0
                y: index * parent.height / 2

                ColumnLayout {
                    id: controls

                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 2
                    width: 66

                    Label {
                        color: "#ddd"
                        font.bold: true
                        font.pixelSize: 12
                        text: "DECK " + (lane.index + 1)
                    }
                    Skin.ControlButton {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        group: lane.group
                        key: "keylock"
                        text: "♬"
                        toggleable: true
                    }
                    Skin.ControlButton {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        group: lane.group
                        key: "pfl"
                        text: "CUE"
                        toggleable: true
                    }
                }
                Skin.WaveformDisplay {
                    anchors.bottom: parent.bottom
                    anchors.left: controls.right
                    anchors.leftMargin: 3
                    anchors.right: parent.right
                    anchors.top: parent.top
                    group: lane.group
                    isTouchMode: true
                    showHud: false
                }
            }
        }
    }
    Rectangle {
        id: effects

        anchors.bottom: decks.top
        anchors.bottomMargin: 4
        anchors.right: parent.right
        anchors.top: parent.top
        border.color: "#45484c"
        color: "#14171b"
        width: root.width < 700 ? 116 : 150

        Label {
            id: fxTitle

            color: "#ddd"
            font.bold: true
            height: 20
            text: "BEAT FX"
            x: 4
            y: 2
        }
        Repeater {
            model: 3

            Item {
                id: fx

                required property int index
                readonly property var slot: Mixxx.EffectsManager.getEffectSlot(1, index + 1)

                height: Math.max(0, (effects.height - 24) / 3)
                width: effects.width - 6
                x: 3
                y: 24 + index * height

                Effects.EffectSelector {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.height * 0.55
                    slot: fx.slot
                }
                Skin.ControlButton {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    group: fx.slot.group
                    height: parent.height * 0.45 - 1
                    key: "enabled"
                    text: "ON / OFF"
                    toggleable: true
                }
            }
        }
    }
    Item {
        id: decks

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.deckHeight

        Repeater {
            model: 2

            Deck {
                required property int index

                group: "[Channel" + (index + 1) + "]"
                height: parent.height
                width: (parent.width - 4) / 2
                x: index * (parent.width + 4) / 2

                onLoadRequested: group => root.loadRequested(group)
            }
        }
    }
}
