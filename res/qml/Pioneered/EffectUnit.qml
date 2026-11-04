pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Mixxx 1.0 as Mixxx
import ".." as Skin
import "../Effects" as Effects

Rectangle {
    id: root

    readonly property string group: Mixxx.EffectsManager.getEffectUnit(unitNumber).group
    required property int unitNumber

    border.color: "#434343"
    color: "#181818"
    implicitHeight: content.implicitHeight + 16

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: 8

        RowLayout {
            Layout.fillWidth: true

            Label {
                color: "#ff8b18"
                text: qsTranslate("Pioneered", "FX %1").arg(root.unitNumber)
            }
            Repeater {
                model: ["[Channel1]", "[Channel2]", "[Master]"]

                Skin.ControlButton {
                    required property string modelData

                    Layout.fillWidth: true
                    Layout.minimumHeight: 48
                    group: root.group
                    key: "group_" + modelData + "_enable"
                    text: modelData === "[Master]" ? qsTranslate("Pioneered", "MAIN") : modelData === "[Channel1]" ? "A" : "B"
                    toggleable: true
                }
            }
            Label {
                color: "white"
                text: qsTranslate("Pioneered", "Dry / Wet")
            }
            Fader {
                Layout.minimumHeight: 48
                Layout.preferredWidth: 120
                group: root.group
                key: "mix"
                orientation: Qt.Horizontal
            }
        }
        Repeater {
            model: 3

            RowLayout {
                id: effect

                required property int index
                readonly property var slot: Mixxx.EffectsManager.getEffectSlot(root.unitNumber, index + 1)

                Layout.fillWidth: true

                Skin.ControlButton {
                    Layout.minimumHeight: 48
                    Layout.minimumWidth: 64
                    group: effect.slot.group
                    key: "enabled"
                    text: qsTranslate("Pioneered", "ON")
                    toggleable: true
                }
                Effects.EffectSelector {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 48
                    slot: effect.slot
                }
                Skin.VuMeter {
                    Layout.preferredHeight: 48
                    Layout.preferredWidth: 12
                    group: effect.slot.group
                    key: "meta"
                }
                Skin.ControlKnob {
                    Layout.preferredHeight: 48
                    Layout.preferredWidth: 48
                    color: "#ff8b18"
                    group: effect.slot.group
                    key: "meta"
                }
            }
        }
    }
}
