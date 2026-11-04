pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Mixxx 1.0 as Mixxx
import ".." as Skin

Rectangle {
    id: root

    readonly property real elapsed: duration.value * Math.max(0, position.value)
    required property string group
    readonly property var player: Mixxx.PlayerManager.getPlayer(group)

    signal loadRequested(string group)

    function time(seconds) {
        const value = Math.max(0, Math.floor(Number.isFinite(seconds) ? seconds : 0));
        return Math.floor(value / 60) + ":" + ("0" + value % 60).slice(-2);
    }

    border.color: "#34383f"
    color: "#080808"

    Mixxx.ControlProxy {
        id: bpm

        group: root.group
        key: "bpm"
    }
    Mixxx.ControlProxy {
        id: duration

        group: root.group
        key: "duration"
    }
    Mixxx.ControlProxy {
        id: position

        group: root.group
        key: "playposition"
        updateInterval: 100
    }
    Rectangle {
        id: title

        anchors.top: parent.top
        color: "#15315a"
        height: 24
        width: parent.width

        Label {
            anchors.fill: parent
            anchors.leftMargin: 5
            color: "#e4eaff"
            elide: Text.ElideRight
            font.pixelSize: 13
            text: root.player.currentTrack ? ((root.player.currentTrack.artist ? root.player.currentTrack.artist + " — " : "") + root.player.currentTrack.title) : qsTranslate("Pioneered", "No track loaded")
            verticalAlignment: Text.AlignVCenter
        }
    }
    Item {
        id: info

        anchors.top: title.bottom
        height: 42
        width: parent.width

        Label {
            color: "#aaa"
            font.pixelSize: 9
            text: root.group === "[Channel1]" ? "DECK 1 · TIME" : "DECK 2 · TIME"
            x: 4
            y: 0
        }
        Label {
            color: "#eee"
            font.pixelSize: root.width < 350 ? 17 : 21
            text: root.time(root.elapsed) + "  −" + root.time(duration.value - root.elapsed)
            x: 4
            y: 12
        }
        Label {
            anchors.right: parent.right
            anchors.rightMargin: 4
            color: "#eee"
            font.pixelSize: 16
            text: bpm.value.toFixed(2) + " BPM"
            y: 1
        }
        Label {
            anchors.right: parent.right
            anchors.rightMargin: 4
            color: "#aaa"
            font.pixelSize: 10
            text: "TOTAL " + root.time(duration.value) + " · KEY " + (root.player.currentTrack?.keyText || "—")
            y: 23
        }
    }
    Skin.WaveformOverview {
        anchors.bottom: transport.top
        anchors.bottomMargin: 2
        anchors.top: info.bottom
        group: root.group
        width: parent.width
    }
    RowLayout {
        id: transport

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 34
        spacing: 2

        Skin.ControlButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            group: root.group
            key: "play"
            text: "▶"
            toggleable: true
        }
        Skin.ControlButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            group: root.group
            key: "cue_default"
            text: "CUE"
        }
        Skin.SyncButton {
            Layout.fillHeight: true
            Layout.fillWidth: true
            group: root.group
        }
        Button {
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: qsTranslate("Pioneered", "LOAD")

            onClicked: root.loadRequested(root.group)
        }
    }
}
