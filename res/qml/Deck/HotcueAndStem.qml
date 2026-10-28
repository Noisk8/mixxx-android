import ".." as Skin
import Mixxx 1.0 as Mixxx
import Qt5Compat.GraphicalEffects
import QtQuick 2.12
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls 2.12
import "../Theme"

Item {
    id: root

    required property var currentTrack
    required property string group

    Mixxx.ControlProxy {
        id: stemCountControl

        group: root.group
        key: "stem_count"
    }
    Mixxx.ControlProxy {
        id: trackLoadedControl

        group: root.group
        key: "track_loaded"
    }
    property int activePadMode: 0 // 0: Hotcue, 1: Loop, 2: Stem

    Rectangle {
        color: '#0E0E0E'

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: tabs.left
            rightMargin: 6
            top: parent.top
        }
        Item {
            id: hotcueTab

            anchors.fill: parent
            visible: trackLoadedControl.value > 0 && root.activePadMode === 0

            Skin.FadeBehavior on visible {
                fadeTarget: hotcueTab
            }

            GridLayout {
                anchors.bottomMargin: 8
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 8
                columnSpacing: 6
                rowSpacing: 6

                Repeater {
                    model: 8

                    Item {
                        required property int index

                        Layout.column: index % 4
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: parseInt(index / 4)

                        Skin.Hotcue {
                            id: hotcue

                            readonly property var label: isSet ? root.currentTrack.hotcuesModel.get(index).label : null

                            activate: activator.pressedButtons == Qt.LeftButton
                            // onIsSetChanged: {
                            //     if (!isSet)
                            //         popup.close();
                            // }
                            group: root.group
                            hotcueNumber: index + 1
                        }
                        Rectangle {
                            id: backgroundImage

                            anchors.fill: parent
                            color: hotcue.isSet ? hotcue.color : '#2B2B2B'

                            MouseArea {
                                id: activator

                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                anchors.fill: parent
                            }
                        }
                        DropShadow {
                            id: effect1

                            anchors.fill: backgroundImage
                            color: "#80000000"
                            horizontalOffset: 0
                            radius: 1.0
                            source: backgroundImage
                            verticalOffset: 0
                        }
                        InnerShadow {
                            id: effect2

                            anchors.fill: parent
                            color: "#353535"
                            horizontalOffset: 1
                            radius: 12
                            samples: 24
                            source: effect1
                            spread: 0.2
                            verticalOffset: 1
                        }
                        InnerShadow {
                            anchors.fill: parent
                            color: "#353535"
                            horizontalOffset: -1
                            radius: 12
                            samples: 24
                            source: effect2
                            spread: 0.2
                            verticalOffset: -1
                        }
                        ColumnLayout {
                            anchors.centerIn: backgroundImage
                            spacing: 0

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                color: "#626262"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                text: `${index + 1}`
                            }
                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                color: "#626262"
                                font.pixelSize: 12
                                text: hotcue.label ?? ""
                                visible: hotcue.label
                            }
                        }
                    }
                }
            }
        }
        Item {
            id: loopTab

            anchors.fill: parent
            visible: trackLoadedControl.value > 0 && root.activePadMode === 1

            Skin.FadeBehavior on visible {
                fadeTarget: loopTab
            }

            GridLayout {
                anchors.bottomMargin: 8
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 8
                columnSpacing: 6
                rowSpacing: 6

                Repeater {
                    model: [
                        { label: "1/4", size: "0.25" },
                        { label: "1/2", size: "0.5" },
                        { label: "1", size: "1" },
                        { label: "2", size: "2" },
                        { label: "4", size: "4" },
                        { label: "8", size: "8" },
                        { label: "16", size: "16" },
                        { label: "32", size: "32" }
                    ]

                    Item {
                        id: loopPadItem
                        required property int index
                        required property var modelData

                        Layout.column: index % 4
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: parseInt(index / 4)

                        Mixxx.ControlProxy {
                            id: loopToggleProxy
                            group: root.group
                            key: "beatloop_" + loopPadItem.modelData.size + "_toggle"
                        }

                        Mixxx.ControlProxy {
                            id: loopEnabledProxy
                            group: root.group
                            key: "beatloop_" + loopPadItem.modelData.size + "_enabled"
                        }

                        Rectangle {
                            id: loopPadBg
                            anchors.fill: parent
                            radius: 4
                            color: (loopEnabledProxy.value > 0)
                                ? "#00e5ff"
                                : (loopPadMouse.pressed ? "#374151" : "#1a222e")
                            border.color: (loopEnabledProxy.value > 0) ? "#ffffff" : "#2c3b4d"
                            border.width: (loopEnabledProxy.value > 0) ? 2 : 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 1

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    font.bold: true
                                    font.pixelSize: 15
                                    color: (loopEnabledProxy.value > 0) ? "#001018" : "#00e5ff"
                                    text: loopPadItem.modelData.label
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    font.bold: true
                                    font.pixelSize: 8
                                    color: (loopEnabledProxy.value > 0) ? "#00364a" : "#78909c"
                                    text: "BEATS"
                                }
                            }

                            MouseArea {
                                id: loopPadMouse
                                anchors.fill: parent
                                onClicked: {
                                    loopToggleProxy.trigger();
                                }
                            }
                        }
                    }
                }
            }
        }
        Item {
            id: stemTab

            anchors.fill: parent
            visible: trackLoadedControl.value > 0 && root.activePadMode === 2

            Skin.FadeBehavior on visible {
                fadeTarget: stemTab
            }

            RowLayout {
                anchors.bottomMargin: 6
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                anchors.topMargin: 6
                spacing: 9

                Repeater {
                    model: root.currentTrack.stemsModel

                    Item {
                        id: stem

                        required property color color
                        readonly property string fxGroup: `[QuickEffectRack1_${group}]`
                        readonly property string group: `${root.group.substr(0, root.group.length - 1)}_Stem${index + 1}]`
                        required property int index
                        required property string label

                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Item {
                            id: content

                            anchors.fill: parent
                            visible: false

                            Rectangle {
                                id: backgroundColor

                                anchors.fill: parent
                                color: stem.color
                                opacity: 0.75
                                radius: 1
                            }
                        }
                        InnerShadow {
                            anchors.fill: parent
                            color: "#4b000000"
                            horizontalOffset: 0
                            radius: 4.0
                            samples: 24
                            smooth: true
                            source: content
                            spread: 0
                            verticalOffset: 4
                        }
                        Item {
                            id: stemButton

                            height: parent.height / 3 * 2
                            width: parent.width / 3 * 2

                            anchors {
                                bottom: stemFxSelector.top
                                left: parent.left
                                top: parent.top
                            }
                            Item {
                                id: contentStemButton

                                anchors.fill: parent
                                visible: false

                                Rectangle {
                                    anchors.fill: parent
                                    color: stem.color
                                    opacity: stemMute.value ? 0.6 : 1.0
                                }
                            }
                            DropShadow {
                                id: effect1

                                anchors.fill: parent
                                color: "#80000000"
                                horizontalOffset: 0
                                radius: 2.0
                                source: contentStemButton
                                spread: 0.5
                                verticalOffset: 0
                            }
                            InnerShadow {
                                id: effect2

                                anchors.fill: parent
                                color: "#353535"
                                horizontalOffset: 2
                                radius: 4.0
                                samples: 24
                                smooth: true
                                source: effect1
                                spread: 0.4
                                verticalOffset: 2
                            }
                            InnerShadow {
                                anchors.fill: parent
                                color: "#353535"
                                horizontalOffset: -2
                                radius: 4.0
                                samples: 24
                                smooth: true
                                source: effect2
                                spread: 0.4
                                verticalOffset: -2
                            }
                            Item {
                                anchors.fill: parent
                                anchors.margins: 6
                                clip: true

                                Label {
                                    id: stemLabel

                                    readonly property bool rotated: fontMetrics.advanceWidth > parent.width && parent.height >= parent.width

                                    anchors.centerIn: parent
                                    color: Theme.white
                                    elide: Text.ElideRight
                                    font.weight: Font.Bold
                                    height: font.pixelSize
                                    horizontalAlignment: rotated ? Text.AlignLeft : Text.AlignHCenter
                                    text: stem.label
                                    width: rotated ? parent.height : parent.width

                                    transform: Rotation {
                                        angle: stemLabel.rotated ? 90 : 0
                                        origin.x: stemLabel.width / 2
                                        origin.y: stemLabel.height / 2
                                    }

                                    TextMetrics {
                                        id: fontMetrics

                                        font: stemLabel.font
                                        text: stem.label
                                    }
                                }
                            }
                            Mixxx.ControlProxy {
                                id: stemMute

                                group: stem.group
                                key: "mute"
                            }
                            TapHandler {
                                onTapped: stemMute.value = !stemMute.value
                            }
                        }
                        Skin.ComboBox {
                            id: stemFxSelector

                            clip: true
                            currentIndex: fxSelect.value == -1 ? 0 : fxSelect.value
                            font.pixelSize: 10
                            height: Math.min(parent.width, parent.height) / 3
                            indicator.width: 0
                            model: Mixxx.EffectsManager.quickChainPresetModel
                            popupMaxItem: 8
                            popupWidth: 150
                            spacing: 2
                            textRole: "display"
                            width: parent.width / 3 * 2

                            onActivated: index => {
                                fxSelect.value = index;
                            }

                            anchors {
                                bottom: parent.bottom
                                left: parent.left
                            }
                            Mixxx.ControlProxy {
                                id: fxSelect

                                group: stem.fxGroup
                                key: "loaded_chain_preset"
                            }
                        }
                        Item {
                            id: stemVolume

                            width: parent.width / 3

                            anchors {
                                bottom: stemFxKnob.top
                                bottomMargin: 3
                                left: stemButton.right
                                right: parent.right
                                top: parent.top
                            }

                            // Skin.VuMeter {
                            //     x: 15
                            //     y: (parent.height - height) / 2
                            //     width: 4
                            //     height: parent.height - 40
                            //     group: root.group
                            //     key: "vu_meter_left"
                            // }

                            // Skin.VuMeter {
                            //     x: parent.width - width - 15
                            //     y: (parent.height - height) / 2
                            //     width: 4
                            //     height: parent.height - 40
                            //     group: root.group
                            //     key: "vu_meter_right"
                            // }

                            Skin.ControlFader {
                                id: volumeSlider

                                anchors.fill: parent
                                bar.color: Theme.volumeSliderBarColor
                                bg: Theme.imgVolumeSliderBackground
                                group: stem.group
                                implicitWidth: 10
                                key: "volume"

                                handleImage {
                                    width: parent.width - 4
                                }
                            }
                        }
                        Item {
                            id: stemFxKnob

                            height: stemFxSelector.height
                            width: parent.width / 3

                            anchors {
                                bottom: parent.bottom
                                right: parent.right
                            }
                            Skin.QuickFxKnob {
                                anchors.centerIn: parent
                                group: stem.fxGroup
                                height: width
                                knob.arcStyle: ShapePath.DashLine
                                knob.arcStylePattern: [2, 2]
                                knob.color: Theme.eqFxColor
                                width: Math.min(parent.width, parent.height)

                                knob {
                                    height: width * 0.8
                                    width: width * 0.8
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    ColumnLayout {
        id: tabs

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: parent.top
        spacing: 6
        width: 44

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 4
            color: root.activePadMode === 0 ? Theme.deckActiveColor : (cueTabMouse.pressed ? "#333333" : "#1e222b")
            border.color: root.activePadMode === 0 ? "#ffffff" : "#323947"
            border.width: root.activePadMode === 0 ? 1 : 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "⚑"
                    font.pixelSize: 12
                    color: root.activePadMode === 0 ? "#ffffff" : "#90a4ae"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "CUE"
                    font.bold: true
                    font.pixelSize: 9
                    color: root.activePadMode === 0 ? "#ffffff" : "#90a4ae"
                }
            }

            MouseArea {
                id: cueTabMouse
                anchors.fill: parent
                onClicked: {
                    root.activePadMode = 0;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 4
            color: root.activePadMode === 1 ? "#00b0ff" : (loopTabMouse.pressed ? "#333333" : "#1e222b")
            border.color: root.activePadMode === 1 ? "#ffffff" : "#323947"
            border.width: root.activePadMode === 1 ? 1 : 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "⟲"
                    font.pixelSize: 13
                    font.bold: true
                    color: root.activePadMode === 1 ? "#001018" : "#90a4ae"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "LOOP"
                    font.bold: true
                    font.pixelSize: 9
                    color: root.activePadMode === 1 ? "#001018" : "#90a4ae"
                }
            }

            MouseArea {
                id: loopTabMouse
                anchors.fill: parent
                onClicked: {
                    root.activePadMode = 1;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 4
            visible: stemCountControl.value > 0
            color: root.activePadMode === 2 ? "#ab47bc" : (stemTabMouse.pressed ? "#333333" : "#1e222b")
            border.color: root.activePadMode === 2 ? "#ffffff" : "#323947"
            border.width: root.activePadMode === 2 ? 1 : 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🎚"
                    font.pixelSize: 12
                    color: root.activePadMode === 2 ? "#ffffff" : "#90a4ae"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "STEM"
                    font.bold: true
                    font.pixelSize: 9
                    color: root.activePadMode === 2 ? "#ffffff" : "#90a4ae"
                }
            }

            MouseArea {
                id: stemTabMouse
                anchors.fill: parent
                onClicked: {
                    root.activePadMode = 2;
                }
            }
        }
    }
}
