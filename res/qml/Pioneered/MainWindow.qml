pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Mixxx 1.0 as Mixxx
import ".." as Skin
import "../Skins/Booth" as Booth

Rectangle {
    id: root

    required property ApplicationWindow applicationWindow
    property var controllerManager: Mixxx.ControllerManager
    property int currentTab: 0
    property string loadTarget: ""
    property var menuBar: null

    function openQuickLoad(group) {
        root.loadTarget = group;
        root.currentTab = 1;
    }

    color: "#080808"

    ControllerAccess {
        surface: root
    }
    Mixxx.ControlProxy {
        id: decks

        group: "[App]"
        key: "num_decks"

        onInitializedChanged: {
            if (decks.initialized)
                decks.value = 4;
        }
    }
    Mixxx.ControlProxy {
        id: samplers

        group: "[App]"
        key: "num_samplers"

        onInitializedChanged: {
            if (samplers.initialized)
                samplers.value = 16;
        }
    }
    Mixxx.ControlProxy {
        id: previews

        group: "[App]"
        key: "num_preview_decks"

        onInitializedChanged: {
            if (previews.initialized)
                previews.value = 1;
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            Label {
                color: "#d5e825"
                font.bold: true
                font.pixelSize: root.width < 700 ? 13 : 18
                text: "PIONEERED"
            }
            Repeater {
                model: [qsTranslate("Pioneered", "Overview"), qsTranslate("Pioneered", "Browse"), qsTranslate("Pioneered", "Samples"), "BeatFX", "DJ"]

                Button {
                    id: tab

                    required property int index
                    required property string modelData

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: 32
                    Layout.preferredWidth: 90
                    padding: 2

                    background: Rectangle {
                        border.color: root.currentTab === tab.index ? "#d5e825" : "#606060"
                        color: tab.down ? "#303030" : "#0b0b0b"
                    }
                    contentItem: Text {
                        color: root.currentTab === tab.index ? "#d5e825" : "#aaa"
                        elide: Text.ElideRight
                        font.bold: true
                        font.pixelSize: root.width < 700 ? 10 : 12
                        horizontalAlignment: Text.AlignHCenter
                        text: tab.modelData
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: root.currentTab = index
                }
            }
            Skin.MobileRecordButton {
                Layout.fillHeight: true
                Layout.preferredWidth: 48
            }
            Button {
                Layout.fillHeight: true
                Layout.preferredWidth: 44
                text: "⚙"

                onClicked: settings.open()
            }
        }
        StackLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            currentIndex: root.currentTab

            Overview {
                onLoadRequested: group => root.openQuickLoad(group)
            }
            Booth.BoothBrowse {
                acceptsController: root.currentTab === 1 && !settings.opened
                compact: root.height < 520
                loadTarget: root.loadTarget
            }
            ScrollView {
                id: samples

                clip: true
                contentWidth: availableWidth

                GridLayout {
                    columns: Math.max(1, Math.floor(width / 300))
                    width: samples.availableWidth

                    Repeater {
                        model: 16

                        Sampler {
                            required property int index

                            Layout.fillWidth: true
                            samplerNumber: index + 1

                            onLoadRequested: group => root.openQuickLoad(group)
                        }
                    }
                }
            }
            ScrollView {
                id: fx

                clip: true
                contentWidth: availableWidth

                ColumnLayout {
                    width: fx.availableWidth

                    Repeater {
                        model: 3

                        EffectUnit {
                            required property int index

                            Layout.fillWidth: true
                            unitNumber: index + 1
                        }
                    }
                }
            }
            Booth.BoothDjView {
                compact: root.height < 520
            }
        }
    }
    Skin.StemsOverlay {
        id: stemsOverlay

        anchors.fill: parent
        z: 95
    }
    Skin.Settings {
        id: settings

        height: root.height
        modal: true
        parent: Overlay.overlay
        width: root.width
    }
    Skin.LibraryScanSummaryDialog {
    }
}
