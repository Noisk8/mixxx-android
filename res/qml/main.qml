import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Window 2.12
import "Theme"

ApplicationWindow {
    id: root

    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
    readonly property int designWidth: 1792
    readonly property int designHeight: 1008

    color: Theme.backgroundColor
    height: isMobile ? Screen.height : designHeight
    menuBar: content.item ? content.item.menuBar : null
    minimumHeight: isMobile ? 0 : 300
    minimumWidth: isMobile ? 0 : 680
    visible: true
    width: isMobile ? Screen.width : designWidth

    function updateVisibility() {
        if (!Mixxx.Core.ready) {
            return;
        }
        root.visibility = Mixxx.Config.configStartInFullscreenKey || isMobile
                ? Window.FullScreen
                : Window.Windowed;
    }

    function openQuickLoad(group) {
        if (content.item && typeof content.item.openQuickLoad === "function") {
            content.item.openQuickLoad(group);
        }
    }

    Connections {
        target: Mixxx.Core
        function onReadyChanged() {
            root.updateVisibility();
        }
    }

    Component.onCompleted: root.updateVisibility()

    Loader {
        id: content

        anchors.fill: parent

        active: Mixxx.Core.ready
        asynchronous: true
        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("Failed to load the Mixxx main window")
                Qt.quit()
            }
        }
        sourceComponent: Component {
            MainWindow {
                applicationWindow: root
            }
        }
    }
    Rectangle {
        id: splash
        visible: opacity > 0
        color: Theme.backgroundColor
        anchors.fill: parent

        property bool ready: false

        Component.onCompleted: {
            ready = true
        }

        Column {
            id: splashContent
            anchors.centerIn: parent
            spacing: 14
            opacity: 0

            Image {
                id: logo
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/images/mixxx-icon-logo-symbolic.svg"
                fillMode: Image.PreserveAspectFit
                height: 72
                width: 72
            }

            Text {
                id: titleText
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.white
                font.pixelSize: 28
                font.bold: true
                font.letterSpacing: 2
                text: "MIXXX"
            }

            Text {
                id: subtitleText
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.accentColor
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: "by JaviLabarum on Android"
            }

            Behavior on opacity {
                NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
            }
        }

        states: [
            State {
                when: splash.ready && content.status != Loader.Ready

                PropertyChanges {
                    splashContent.opacity: 1
                }
            },
            State {
                when: content.status == Loader.Ready && content.active

                PropertyChanges {
                    splash.opacity: 0
                }
            }
        ]

        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
    }
}
