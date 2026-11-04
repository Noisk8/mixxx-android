pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Mixxx 1.0 as Mixxx
import ".." as Skin

Rectangle {
    id: root

    readonly property string group: "[Sampler" + samplerNumber + "]"
    readonly property var player: Mixxx.PlayerManager.getPlayer(group)
    required property int samplerNumber

    signal loadRequested(string group)

    border.color: "#434343"
    color: "#181818"
    implicitHeight: content.implicitHeight + 12

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: 6

        Label {
            Layout.fillWidth: true
            color: "white"
            elide: Text.ElideRight
            text: root.samplerNumber + " · " + (root.player.currentTrack?.title || "—")
        }
        RowLayout {
            Layout.fillWidth: true

            Skin.ControlButton {
                Layout.fillWidth: true
                Layout.minimumHeight: 48
                group: root.group
                key: "play"
                text: "PLAY"
                toggleable: true
            }
            Skin.ControlButton {
                Layout.fillWidth: true
                Layout.minimumHeight: 48
                group: root.group
                key: "cue_default"
                text: "CUE"
            }
            Button {
                Layout.minimumHeight: 48
                text: qsTranslate("Pioneered", "LOAD")

                onClicked: root.loadRequested(root.group)
            }
        }
        Fader {
            Layout.fillWidth: true
            Layout.minimumHeight: 48
            group: root.group
            key: "volume"
            orientation: Qt.Horizontal
        }
    }
}
