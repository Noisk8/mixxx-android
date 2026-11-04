import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Mixxx 1.0 as Mixxx
import "." as Setting
import ".." as Skin
import "../Theme"

Category {
    id: root

    label: qsTr("About")
    selectedIndex: 0

    Flickable {
        anchors.fill: parent
        contentHeight: aboutColumn.implicitHeight + 30
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: aboutColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 12

            // ================= HERO CARD: JAVI & IDENTIDAD =================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                radius: 8
                color: "#161b24"
                border.color: "#2a3648"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 14

                    // Avatar with neon glow border
                    Item {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 80
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            id: avatarContainer
                            anchors.fill: parent
                            radius: 40
                            color: "#0d1117"
                            border.color: "#00e5ff"
                            border.width: 2
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: Qt.resolvedUrl("../images/javi_headphones.jpg")
                                fillMode: Image.PreserveAspectCrop
                                antialiasing: true
                            }
                        }
                    }

                    // Bio Header
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 3

                        RowLayout {
                            spacing: 8
                            Text {
                                text: "JaviLabarum"
                                font.bold: true
                                font.pixelSize: 18
                                color: "#ffffff"
                            }
                            Rectangle {
                                color: "#00b0ff22"
                                border.color: "#00b0ff"
                                border.width: 1
                                radius: 4
                                height: 18
                                width: 56
                                Text {
                                    anchors.centerIn: parent
                                    text: qsTr("DJ / CREATOR")
                                    font.pixelSize: 7
                                    font.bold: true
                                    color: "#00e5ff"
                                }
                            }
                        }

                        Text {
                            text: "@javilabarumdj"
                            font.bold: true
                            font.pixelSize: 12
                            color: "#ff9100"
                        }

                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            font.pixelSize: 10
                            color: "#b0bec5"
                            lineHeight: 1.2
                            text: qsTr("DJ, producer and app developer. Bringing a professional mixing experience and real touch control to Android devices.")
                        }
                    }
                }
            }

            // ================= SECTION 1: ¿POR QUÉ ESTA APLICACIÓN? =================
            Rectangle {
                Layout.fillWidth: true
                radius: 8
                color: "#14171f"
                border.color: "#232b38"
                border.width: 1
                implicitHeight: whyCol.implicitHeight + 20

                ColumnLayout {
                    id: whyCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        spacing: 8
                        Text {
                            text: "🎧"
                            font.pixelSize: 15
                        }
                        Text {
                            text: qsTr("WHY THIS APP?")
                            font.bold: true
                            font.pixelSize: 12
                            color: "#00e5ff"
                            font.letterSpacing: 0.5
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#232b38"
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 11
                        lineHeight: 1.3
                        color: "#cfd8dc"
                        text: qsTr("For a long time, DJ software on phones has been held back by expensive subscriptions, unacceptable latency or unprofessional interfaces.\n\n" +
                                   "This edition of Mixxx for Android was born from a personal need as a DJ: to have a complete, free, powerful and ultra-stable DJ booth in your pocket.\n\n" +
                                   "• Professional real-time C++ audio engine without dropouts.\n" +
                                   "• Support for external USB DJ controllers (plug & play via OTG).\n" +
                                   "• Dual touch decks with independent pitch faders, beatloops, hotcues and full EQ.\n" +
                                   "• Built independently with a passion for music, for the DJ community.")
                    }
                }
            }

            // ================= SECTION 2: SÍGUEME EN REDES SOCIALES =================
            Rectangle {
                Layout.fillWidth: true
                radius: 8
                color: "#14171f"
                border.color: "#232b38"
                border.width: 1
                implicitHeight: rrssCol.implicitHeight + 20

                ColumnLayout {
                    id: rrssCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        spacing: 8
                        Text {
                            text: "🚀"
                            font.pixelSize: 15
                        }
                        Text {
                            text: qsTr("FOLLOW ME ON SOCIAL MEDIA")
                            font.bold: true
                            font.pixelSize: 12
                            color: "#ff9100"
                            font.letterSpacing: 0.5
                        }
                    }

                    Text {
                        text: qsTr("Tap any network to open the profile and see sessions, tips, news and updates:")
                        font.pixelSize: 10
                        color: "#90a4ae"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // Instagram
                        SocialButton {
                            Layout.fillWidth: true
                            title: "Instagram"
                            handle: "@javilabarumdj"
                            accentColor: "#e1306c"
                            url: "https://www.instagram.com/javilabarumdj"
                        }

                        // TikTok
                        SocialButton {
                            Layout.fillWidth: true
                            title: "TikTok"
                            handle: "@javilabarumdj"
                            accentColor: "#00f2fe"
                            url: "https://www.tiktok.com/@javilabarumdj"
                        }

                        // YouTube
                        SocialButton {
                            Layout.fillWidth: true
                            title: "YouTube"
                            handle: "@javilabarumdj"
                            accentColor: "#ff0000"
                            url: "https://www.youtube.com/@javilabarumdj"
                        }
                    }
                }
            }

            // ================= THANKS =================
            Rectangle {
                Layout.fillWidth: true
                radius: 8
                color: "#161b24"
                border.color: "#2a3648"
                border.width: 1
                implicitHeight: thanksCol.implicitHeight + 24

                ColumnLayout {
                    id: thanksCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        spacing: 8
                        Text {
                            text: "🙏"
                            font.pixelSize: 15
                        }
                        Text {
                            text: qsTr("THANKS")
                            font.bold: true
                            font.pixelSize: 12
                            color: "#ff9100"
                            font.letterSpacing: 0.5
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        SocialButton {
                            Layout.preferredWidth: 200
                            title: "Angelos Exarchos"
                            handle: "@daedalus.music"
                            accentColor: "#e1306c"
                            url: "https://www.instagram.com/daedalus.music"
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Contributor of this app: switchable skins and the Booth skin, beatgrid editing and corrections, Rekordbox playlists, dates and beatgrids, library and drive backups, controller navigation, the DDJ-FLX4 options and SMART CFX, and fixes for the effects and Rekordbox.")
                            font.pixelSize: 10
                            color: "#90a4ae"
                            wrapMode: Text.WordWrap
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        SocialButton {
                            Layout.preferredWidth: 200
                            title: "Dani Roman"
                            handle: "@danigiavanni"
                            accentColor: "#e1306c"
                            url: "https://www.instagram.com/danigiavanni"
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Live stems in Mixxx: his mixxx-stems project inspired the stem separation of this app.")
                            font.pixelSize: 10
                            color: "#90a4ae"
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            // ================= UPDATES =================
            Rectangle {
                Layout.fillWidth: true
                radius: 8
                color: "#161b24"
                border.color: "#2a3648"
                border.width: 1
                implicitHeight: updatesCol.implicitHeight + 24

                ColumnLayout {
                    id: updatesCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        spacing: 8
                        Text {
                            text: "⬆"
                            font.pixelSize: 15
                            color: "#00e5ff"
                        }
                        Text {
                            text: qsTr("UPDATES")
                            font.bold: true
                            font.pixelSize: 12
                            color: "#00e5ff"
                            font.letterSpacing: 0.5
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Skin.AppUpdateStatusText {
                            Layout.fillWidth: true
                            font.pixelSize: 12
                        }

                        Skin.Button {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            visible: [Mixxx.AppUpdate.Idle, Mixxx.AppUpdate.UpToDate].includes(Mixxx.AppUpdate.state) || (Mixxx.AppUpdate.state === Mixxx.AppUpdate.Failed && Mixxx.AppUpdate.latestVersion === "")
                            text: qsTr("CHECK NOW")
                            onClicked: Mixxx.AppUpdate.check()
                        }
                        Skin.Button {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            visible: Mixxx.AppUpdate.state === Mixxx.AppUpdate.Available || (Mixxx.AppUpdate.state === Mixxx.AppUpdate.Failed && Mixxx.AppUpdate.latestVersion !== "")
                            activeColor: "#00e5ff"
                            backgroundColor: "#0d3640"
                            normalColor: "#80deea"
                            font.bold: true
                            text: qsTr("DOWNLOAD")
                            onClicked: Mixxx.AppUpdate.download()
                        }
                        Skin.Button {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            visible: Mixxx.AppUpdate.state === Mixxx.AppUpdate.Downloading
                            text: qsTr("Cancel")
                            onClicked: Mixxx.AppUpdate.cancelDownload()
                        }
                        Skin.Button {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            visible: Mixxx.AppUpdate.state === Mixxx.AppUpdate.Downloaded
                            activeColor: "#00e5ff"
                            backgroundColor: "#0d3640"
                            normalColor: "#80deea"
                            font.bold: true
                            text: qsTr("INSTALL")
                            onClicked: updateInstallPopup.open()
                        }
                    }

                    // Download progress
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        visible: Mixxx.AppUpdate.state === Mixxx.AppUpdate.Downloading
                        radius: 3
                        color: "#0e1117"
                        border.color: "#283444"
                        border.width: 1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * Mixxx.AppUpdate.progress
                            radius: 3
                            color: "#00e5ff"
                        }
                    }

                    // What's new
                    Text {
                        Layout.fillWidth: true
                        visible: Mixxx.AppUpdate.releaseNotes !== "" && [Mixxx.AppUpdate.Available, Mixxx.AppUpdate.Downloading, Mixxx.AppUpdate.Verifying, Mixxx.AppUpdate.Downloaded].includes(Mixxx.AppUpdate.state)
                        text: Mixxx.AppUpdate.releaseNotes
                        textFormat: Text.MarkdownText
                        font.pixelSize: 11
                        color: "#b0bec5"
                        linkColor: "#80deea"
                        wrapMode: Text.WordWrap
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Switch {
                            id: autoCheckSwitch

                            checked: Mixxx.AppUpdate.autoCheck
                            onToggled: Mixxx.AppUpdate.autoCheck = checked

                            // The Basic style is grey on and off
                            indicator: Rectangle {
                                x: autoCheckSwitch.leftPadding
                                y: (autoCheckSwitch.height - height) / 2
                                implicitWidth: 48
                                implicitHeight: 26
                                radius: 13
                                color: autoCheckSwitch.checked ? "#0d3640" : "#1a202c"
                                border.color: autoCheckSwitch.checked ? "#00e5ff" : "#546e7a"
                                border.width: 1

                                Rectangle {
                                    x: autoCheckSwitch.checked ? parent.width - width - 3 : 3
                                    y: 3
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: autoCheckSwitch.checked ? "#00e5ff" : "#78909c"
                                }
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Look for updates when Mixxx starts (once a day at most). The versions are read from the GitHub releases of Mixxx Android, and nothing is downloaded without asking.")
                            font.pixelSize: 10
                            color: "#90a4ae"
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Skin.AppUpdateInstallPopup {
                    id: updateInstallPopup
                }
            }

            // ================= SECTION 3: APP INFO & VERSION =================
            Rectangle {
                Layout.fillWidth: true
                radius: 8
                color: "#14171f"
                border.color: "#232b38"
                border.width: 1
                implicitHeight: infoCol.implicitHeight + 16

                ColumnLayout {
                    id: infoCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Mixxx Android DJ Edition"
                            font.bold: true
                            font.pixelSize: 11
                            color: "#ffffff"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: `v${Mixxx.MobileApp.packageVersion} (Mixxx ${Mixxx.Application.version})`
                            font.pixelSize: 10
                            color: "#78909c"
                        }
                    }

                    Text {
                        text: qsTr("Based on the open source Mixxx project. Mobile adaptation by JaviLabarum.")
                        font.pixelSize: 9
                        color: "#546e7a"
                    }
                }
            }
        }
    }

    component SocialButton: Rectangle {
        id: sBtn
        property string title
        property string handle
        property color accentColor
        property string url

        height: 50
        radius: 6
        color: sMouse.pressed ? "#232b38" : "#1a202c"
        border.color: sMouse.containsMouse ? accentColor : "#2d3748"
        border.width: 1.5

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: sBtn.title
                font.bold: true
                font.pixelSize: 11
                color: sBtn.accentColor
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: sBtn.handle
                font.pixelSize: 9
                color: "#e2e8f0"
            }
        }

        MouseArea {
            id: sMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                Qt.openUrlExternally(sBtn.url);
            }
        }
    }
}
