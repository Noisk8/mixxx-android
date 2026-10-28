import "." as Skin
import Mixxx 1.0 as Mixxx
import Qt.labs.qmlmodels
import QtQml
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.6
import "Theme"
import "Library" as LibraryComponent
import "Library/Streaming" as StreamingComponent

Item {
    id: root

    property var sidebar: librarySources.sidebar()
    property int librarySourceMode: 0 // 0: Local, 1: Streaming Hub
    property bool showSidebar: false

    function applySearch() {
        if (root.sidebar && root.sidebar.tracklist && root.librarySourceMode === 0) {
            root.sidebar.tracklist.search(searchField.text);
        }
    }
    function focusSearch() {
        if (root.librarySourceMode === 0) {
            root.applySearch();
            searchField.forceActiveFocus(Qt.ShortcutFocusReason);
            searchField.selectAll();
        }
    }

    LibraryComponent.SourceTree {
        id: librarySources
    }

    // ================= SOURCE SELECTOR TAB BAR =================
    Rectangle {
        id: sourceSelectorBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 38
        color: "#181b22"
        border.color: "#282d3b"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 3
            spacing: 6

            Skin.Button {
                Layout.fillHeight: true
                Layout.preferredWidth: 120
                activeColor: "#00e5ff"
                backgroundColor: root.librarySourceMode === 0 ? "#1e3a47" : "#222733"
                normalColor: root.librarySourceMode === 0 ? "#00e5ff" : "#90a4ae"
                font.bold: true
                font.pixelSize: 11
                text: "MÚSICA LOCAL"
                onClicked: root.librarySourceMode = 0
            }

            Skin.Button {
                Layout.fillHeight: true
                Layout.preferredWidth: 140
                activeColor: "#00ffff"
                backgroundColor: root.librarySourceMode === 1 ? "#004d40" : "#222733"
                normalColor: root.librarySourceMode === 1 ? "#00ffff" : "#80deea"
                font.bold: true
                font.pixelSize: 11
                text: "STREAMING HUB"
                onClicked: root.librarySourceMode = 1
            }

            Skin.Button {
                visible: root.librarySourceMode === 0
                Layout.fillHeight: true
                Layout.preferredWidth: 92
                activeColor: Theme.accentColor
                checkable: true
                checked: root.showSidebar
                font.bold: true
                font.pixelSize: 10
                text: root.showSidebar ? "OCULTAR" : "CARPETAS"
                onClicked: root.showSidebar = !root.showSidebar
            }

            Item { Layout.fillWidth: true }
        }
    }

    // ================= CONTENT CONTAINER =================
    Item {
        id: sourceContentContainer
        anchors.top: sourceSelectorBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        // 1. LOCAL LIBRARY
        Item {
            id: localLibraryArea
            anchors.fill: parent
            visible: root.librarySourceMode === 0

            TextField {
                id: searchField
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                placeholderText: qsTranslate("WSearchLineEdit", "Buscar en tu colección local...")
                onTextChanged: root.applySearch()
            }

            SplitView {
                id: librarySplitView
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: searchField.bottom
                orientation: Qt.Horizontal

                handle: Rectangle {
                    id: handleDelegate
                    property color handleColor: SplitHandle.pressed || SplitHandle.hovered ? Theme.panelSplitterHandleActive : Theme.panelSplitterHandle
                    property int handleSize: SplitHandle.pressed || SplitHandle.hovered ? 6 : 5
                    clip: true
                    color: Theme.panelSplitterBackground
                    implicitHeight: 8
                    implicitWidth: 8

                    containmentMask: Item {
                        height: librarySplitView.height
                        width: 8
                        x: (handleDelegate.width - width) / 2
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        Repeater {
                            model: 3
                            Rectangle {
                                color: handleColor
                                height: handleSize
                                radius: handleSize
                                width: handleSize
                            }
                        }
                    }
                }

                SplitView {
                    id: sideBarSplitView
                    visible: root.showSidebar
                    SplitView.maximumWidth: 400
                    SplitView.minimumWidth: root.showSidebar ? 140 : 0
                    SplitView.preferredWidth: root.showSidebar ? Math.min(220, root.width * 0.25) : 0
                    orientation: Qt.Vertical

                    handle: Rectangle {
                        id: handleDelegateVertical
                        property color handleColor: SplitHandle.pressed || SplitHandle.hovered ? Theme.panelSplitterHandleActive : Theme.panelSplitterHandle
                        property int handleSize: SplitHandle.pressed || SplitHandle.hovered ? 6 : 5
                        clip: true
                        color: Theme.panelSplitterBackground
                        implicitHeight: 8
                        implicitWidth: 8

                        containmentMask: Item {
                            height: 8
                            width: sideBarSplitView.width
                            x: (handleDelegateVertical.width - width) / 2
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            Repeater {
                                model: 3
                                Rectangle {
                                    color: handleColor
                                    height: handleSize
                                    radius: handleSize
                                    width: handleSize
                                }
                            }
                        }
                    }

                    LibraryComponent.Browser {
                        SplitView.fillHeight: true
                        SplitView.minimumHeight: 200
                        SplitView.preferredHeight: 500
                        model: root.sidebar
                    }
                    Skin.PreviewDeck {
                        SplitView.maximumHeight: 200
                        SplitView.minimumHeight: 100
                        SplitView.preferredHeight: 100
                    }
                }

                LibraryComponent.TrackList {
                    SplitView.fillHeight: true
                    clip: true
                    model: root.sidebar ? root.sidebar.tracklist : null
                }
            }
        }

        // 2. MULTI-SERVICE STREAMING HUB (TIDAL, SOUNDCLOUD, BEATPORT, NAVIDROME, AUDIUS, URL)
        StreamingComponent.StreamingHub {
            id: streamingHubArea
            anchors.fill: parent
            visible: root.librarySourceMode === 1
        }
    }
}
