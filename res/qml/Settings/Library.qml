import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.15
import Mixxx 1.0 as Mixxx
import "." as SettingComponents
import ".." as Skin
import "../Theme"

Category {
    id: root

    property bool dirty: false
    property var sourcesList: []
    property bool showFolderBrowser: false
    property string currentBrowserPath: "/storage/emulated/0/Music"
    property var subDirectoriesList: []
    readonly property bool isScanning: Mixxx.Library ? (Mixxx.Library.libraryScanActive || (Mixxx.Library.scanner && Mixxx.Library.scanner.running)) : false

    function refreshSources() {
        if (Mixxx.Library && Mixxx.Library.getSourcesList) {
            root.sourcesList = Mixxx.Library.getSourcesList();
        }
    }

    function updateSubDirs() {
        if (Mixxx.Library && Mixxx.Library.getSubDirectories) {
            root.subDirectoriesList = Mixxx.Library.getSubDirectories(root.currentBrowserPath);
        }
    }

    function goUpDir() {
        var p = root.currentBrowserPath;
        var lastSlash = p.lastIndexOf("/");
        if (lastSlash > 0) {
            root.currentBrowserPath = p.substring(0, lastSlash);
        } else {
            root.currentBrowserPath = "/storage/emulated/0";
        }
        root.updateSubDirs();
    }

    function selectSubDir(dirName) {
        var base = root.currentBrowserPath;
        if (!base.endsWith("/")) {
            base += "/";
        }
        root.currentBrowserPath = base + dirName;
        root.updateSubDirs();
    }

    function addQuickFolder(path) {
        if (Mixxx.Library && Mixxx.Library.addSourcePath) {
            Mixxx.Library.addSourcePath(path);
            Mixxx.Library.rescanLibrary();
            root.refreshSources();
        }
    }

    function removeFolder(path) {
        if (Mixxx.Library && Mixxx.Library.removeSourcePath) {
            Mixxx.Library.removeSourcePath(path);
            Mixxx.Library.rescanLibrary();
            root.refreshSources();
        }
    }

    function isFolderAdded(path) {
        if (!root.sourcesList) return false;
        for (var i = 0; i < root.sourcesList.length; i++) {
            if (root.sourcesList[i].path === path) return true;
        }
        return false;
    }

    function load() {
        root.refreshSources();
        if (Mixxx.Library && Mixxx.Library.defaultMusicDirectory) {
            root.currentBrowserPath = Mixxx.Library.defaultMusicDirectory();
        }
        if (Mixxx.StreamingManager) {
            Mixxx.StreamingManager.refreshCacheSize();
        }
    }

    function save() {
        root.dirty = false;
    }

    label: qsTr("Librería Musical")

    Component.onCompleted: {
        root.load();
    }

    Connections {
        target: Mixxx.Library

        function onSourcesChanged() {
            root.refreshSources();
        }

        function onLibraryScanActiveChanged() {
            root.refreshSources();
        }
    }

    ScrollView {
        id: scrollView
        anchors.bottom: libraryAction.top
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: scrollView.availableWidth
            spacing: 14

            // ================= 1. CARPETAS DE MÚSICA LOCAL =================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: localCol.implicitHeight + 24
                color: Theme.darkGray3
                radius: 8
                border.color: "#303440"
                border.width: 1

                ColumnLayout {
                    id: localCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Header row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "📁 Carpetas de Música Local"
                            font.bold: true
                            font.pixelSize: 15
                            color: Theme.white
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: scannerStatusText.implicitWidth + 16
                            radius: 12
                            color: root.isScanning ? "#ff910022" : "#00e67622"
                            border.color: root.isScanning ? "#ff9100" : "#00e676"
                            border.width: 1

                            Text {
                                id: scannerStatusText
                                anchors.centerIn: parent
                                font.pixelSize: 11
                                font.bold: true
                                color: root.isScanning ? "#ff9100" : "#00e676"
                                text: root.isScanning ? "⟳ Escaneando..." : "✔ Colección lista"
                            }
                        }
                    }

                    Text {
                        text: "Elige las carpetas de tu móvil donde guardas tu música. Mixxx monitorizará e indexará automáticamente las pistas encontradas."
                        font.pixelSize: 11
                        color: "#90a4ae"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // --- LISTA DE CARPETAS MONITORIZADAS ---
                    Text {
                        text: "Carpetas añadidas actualmente:"
                        font.bold: true
                        font.pixelSize: 12
                        color: "#b0bec5"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: root.sourcesList

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                color: "#161b24"
                                radius: 6
                                border.color: "#283344"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 8

                                    Text {
                                        text: "📁"
                                        font.pixelSize: 16
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: modelData.path
                                            font.bold: true
                                            font.pixelSize: 12
                                            color: "#ffffff"
                                            elide: Text.ElideMiddle
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: (modelData.trackCount || 0) + " canciones indexadas" +
                                                  (modelData.totalSecond > 0 ? " • " + Math.round(modelData.totalSecond / 60) + " min" : "")
                                            font.pixelSize: 10
                                            color: "#00e5ff"
                                        }
                                    }

                                    Skin.Button {
                                        Layout.preferredHeight: 30
                                        Layout.preferredWidth: 80
                                        activeColor: "#ff5252"
                                        backgroundColor: "#421e24"
                                        normalColor: "#ff8a80"
                                        font.bold: true
                                        font.pixelSize: 10
                                        text: "🗑 Quitar"
                                        onClicked: {
                                            root.removeFolder(modelData.path);
                                        }
                                    }
                                }
                            }
                        }

                        // Empty State if no folder configured
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            color: "#1c212c"
                            radius: 6
                            visible: !root.sourcesList || root.sourcesList.length === 0

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text {
                                    text: "⚠️ No hay carpetas añadidas aún. Pulsa en los botones de abajo para añadir."
                                    font.pixelSize: 11
                                    color: "#ffb74d"
                                }
                            }
                        }
                    }

                    // --- ACCESOS RÁPIDOS ANDROID ---
                    Text {
                        text: "Accesos rápidos (Ubicaciones estándar en Android):"
                        font.bold: true
                        font.pixelSize: 12
                        color: "#b0bec5"
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Skin.Button {
                            height: 32
                            width: 170
                            activeColor: "#00e5ff"
                            backgroundColor: root.isFolderAdded("/storage/emulated/0/Music") ? "#004d40" : "#1a2533"
                            normalColor: root.isFolderAdded("/storage/emulated/0/Music") ? "#00e676" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                            text: (root.isFolderAdded("/storage/emulated/0/Music") ? "✔ " : "➕ ") + "🎵 Música (/sdcard)"
                            onClicked: {
                                root.addQuickFolder("/storage/emulated/0/Music");
                            }
                        }

                        Skin.Button {
                            height: 32
                            width: 180
                            activeColor: "#00e5ff"
                            backgroundColor: root.isFolderAdded("/storage/emulated/0/Download") ? "#004d40" : "#1a2533"
                            normalColor: root.isFolderAdded("/storage/emulated/0/Download") ? "#00e676" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                            text: (root.isFolderAdded("/storage/emulated/0/Download") ? "✔ " : "➕ ") + "📥 Descargas (/Download)"
                            onClicked: {
                                root.addQuickFolder("/storage/emulated/0/Download");
                            }
                        }

                        Skin.Button {
                            height: 32
                            width: 160
                            activeColor: "#00e5ff"
                            backgroundColor: root.isFolderAdded("/storage/emulated/0/Mixxx") ? "#004d40" : "#1a2533"
                            normalColor: root.isFolderAdded("/storage/emulated/0/Mixxx") ? "#00e676" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                            text: (root.isFolderAdded("/storage/emulated/0/Mixxx") ? "✔ " : "➕ ") + "💽 Mixxx DJ (/Mixxx)"
                            onClicked: {
                                root.addQuickFolder("/storage/emulated/0/Mixxx");
                            }
                        }
                    }

                    // --- BOTÓN EXPLORAR / AÑADIR OTRA CARPETA ---
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Skin.Button {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 220
                            activeColor: "#00ffff"
                            backgroundColor: root.showFolderBrowser ? "#00363a" : "#263238"
                            normalColor: "#00e5ff"
                            font.bold: true
                            font.pixelSize: 11
                            text: root.showFolderBrowser ? "▲ Ocultar Explorador" : "📂 Explorar / Otra Carpeta..."
                            onClicked: {
                                root.showFolderBrowser = !root.showFolderBrowser;
                                if (root.showFolderBrowser) {
                                    root.updateSubDirs();
                                }
                            }
                        }

                        Skin.Button {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 190
                            activeColor: "#00e5ff"
                            backgroundColor: "#1565c0"
                            normalColor: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                            text: "⟳ Re-escanear Música"
                            enabled: !root.isScanning
                            onClicked: {
                                if (Mixxx.Library && Mixxx.Library.rescanLibrary) {
                                    Mixxx.Library.rescanLibrary();
                                }
                            }
                        }
                    }

                    // --- PANEL EXPANDIBLE DE EXPLORADOR DE CARPETAS ---
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: browserCol.implicitHeight + 20
                        color: "#111620"
                        radius: 6
                        border.color: "#00e5ff44"
                        border.width: 1
                        visible: root.showFolderBrowser

                        ColumnLayout {
                            id: browserCol
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Text {
                                text: "🔍 Explorador de carpetas en el dispositivo:"
                                font.bold: true
                                font.pixelSize: 12
                                color: "#00e5ff"
                            }

                            // Current path display with Back/Up button
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Skin.Button {
                                    Layout.preferredHeight: 32
                                    Layout.preferredWidth: 80
                                    activeColor: "#00ffff"
                                    backgroundColor: "#1c2a38"
                                    normalColor: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 11
                                    text: "⬆ Subir"
                                    onClicked: {
                                        root.goUpDir();
                                    }
                                }

                                TextField {
                                    id: pathInputField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    text: root.currentBrowserPath
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    background: Rectangle {
                                        color: "#18222d"
                                        radius: 4
                                        border.color: pathInputField.activeFocus ? "#00ffff" : "#37474f"
                                        border.width: 1
                                    }
                                    onAccepted: {
                                        root.currentBrowserPath = text.trim();
                                        root.updateSubDirs();
                                    }
                                }
                            }

                            // Subdirectories flow
                            Text {
                                text: "Subcarpetas encontradas en esta ubicación (toca para entrar):"
                                font.pixelSize: 10
                                color: "#90a4ae"
                            }

                            Flow {
                                Layout.fillWidth: true
                                spacing: 6

                                Repeater {
                                    model: root.subDirectoriesList

                                    Rectangle {
                                        height: 28
                                        width: dirLabel.implicitWidth + 20
                                        radius: 4
                                        color: "#1e293b"
                                        border.color: "#334155"
                                        border.width: 1

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            Text { text: "📁"; font.pixelSize: 11 }
                                            Text {
                                                id: dirLabel
                                                text: modelData
                                                color: "#e2e8f0"
                                                font.pixelSize: 11
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                root.selectSubDir(modelData);
                                            }
                                        }
                                    }
                                }

                                Text {
                                    visible: !root.subDirectoriesList || root.subDirectoriesList.length === 0
                                    text: "(No hay más subcarpetas)"
                                    font.pixelSize: 10
                                    color: "#64748b"
                                }
                            }

                            // Confirm Add Button
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Skin.Button {
                                    Layout.preferredHeight: 34
                                    Layout.fillWidth: true
                                    activeColor: "#00e676"
                                    backgroundColor: "#004d40"
                                    normalColor: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 11
                                    text: "✔ Añadir '" + root.currentBrowserPath + "' a la Librería"
                                    onClicked: {
                                        root.addQuickFolder(root.currentBrowserPath);
                                        root.showFolderBrowser = false;
                                    }
                                }

                                Skin.Button {
                                    Layout.preferredHeight: 34
                                    Layout.preferredWidth: 90
                                    activeColor: "#ff5252"
                                    backgroundColor: "#2c3440"
                                    normalColor: "#b0bec5"
                                    font.pixelSize: 11
                                    text: "Cerrar"
                                    onClicked: {
                                        root.showFolderBrowser = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ================= 2. CACHÉ DE STREAMING (NAVIDROME / AUDIUS / TIDAL) =================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: streamingCol.implicitHeight + 24
                color: Theme.darkGray3
                radius: 8
                border.color: "#303440"
                border.width: 1

                ColumnLayout {
                    id: streamingCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "☁️ Almacenamiento & Caché de Streaming"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#00e5ff"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Las pistas reproducidas desde plataformas de streaming (Navidrome, Audius, SoundCloud, Tidal) se almacenan localmente para garantizar una reproducción sin cortes de audio aunque se pierda la conexión a internet."
                        font.pixelSize: 11
                        color: "#90a4ae"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true
                            color: "#181b24"
                            radius: 6
                            border.color: "#292f3d"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8

                                Text {
                                    text: "💾 Espacio en uso:"
                                    font.pixelSize: 12
                                    color: "#b0bec5"
                                }

                                Text {
                                    text: {
                                        var bytes = Mixxx.StreamingManager ? Mixxx.StreamingManager.cacheSizeBytes : 0;
                                        if (bytes <= 0) return "0 MB (Caché vacía)";
                                        var mb = bytes / (1024 * 1024);
                                        if (mb > 1024) return (mb / 1024).toFixed(2) + " GB";
                                        return mb.toFixed(1) + " MB";
                                    }
                                    font.bold: true
                                    font.pixelSize: 13
                                    color: "#00e676"
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: "Ruta: " + (Mixxx.StreamingManager ? Mixxx.StreamingManager.cacheDirectory : "")
                                    font.pixelSize: 10
                                    color: "#607d8b"
                                    elide: Text.ElideMiddle
                                    Layout.maximumWidth: 260
                                }
                            }
                        }

                        Skin.Button {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            activeColor: "#ff5252"
                            backgroundColor: "#421e24"
                            normalColor: "#ff8a80"
                            font.bold: true
                            text: "🗑️ Vaciar Caché"
                            onClicked: {
                                if (Mixxx.StreamingManager) {
                                    Mixxx.StreamingManager.clearCache();
                                }
                            }
                        }
                    }
                }
            }

            // ================= 3. OPCIONES DE BÚSQUEDA Y METADATOS =================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: searchCol.implicitHeight + 24
                color: Theme.darkGray3
                radius: 8
                border.color: "#303440"
                border.width: 1

                ColumnLayout {
                    id: searchCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "🔍 Búsqueda y Organización"
                        font.bold: true
                        font.pixelSize: 14
                        color: Theme.white
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Autocompletar búsquedas al escribir"
                            font.pixelSize: 12
                            color: Theme.white
                            Layout.fillWidth: true
                        }

                        Switch {
                            checked: Mixxx.Config.librarySearchCompletionsEnable
                            onToggled: {
                                Mixxx.Config.librarySearchCompletionsEnable = checked;
                                root.dirty = true;
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#282c37"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Sincronizar metadatos y etiquetas ID3 al editar"
                            font.pixelSize: 12
                            color: Theme.white
                            Layout.fillWidth: true
                        }

                        Switch {
                            checked: Mixxx.Config.librarySyncTrackMetadataExport
                            onToggled: {
                                Mixxx.Config.librarySyncTrackMetadataExport = checked;
                                root.dirty = true;
                            }
                        }
                    }
                }
            }

            // ================= 4. PRE-ANÁLISIS DE TONALIDAD & BPM =================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: analysisCol.implicitHeight + 24
                color: Theme.darkGray3
                radius: 8
                border.color: "#303440"
                border.width: 1

                ColumnLayout {
                    id: analysisCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "⚡ Pre-análisis de Colección (BPM & Tonalidad Camelot)"
                        font.bold: true
                        font.pixelSize: 14
                        color: "#00e5ff"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Calcula el BPM, rejilla de compases y tono armónico de tus pistas en segundo plano. Al tener todas las pistas pre-analizadas, cargarán al instante sin retardo y el asistente armónico resaltará canciones compatibles."
                        font.pixelSize: 11
                        color: "#90a4ae"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Skin.Button {
                            Layout.preferredHeight: 38
                            Layout.fillWidth: true
                            activeColor: "#00e676"
                            backgroundColor: "#004d40"
                            normalColor: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                            text: "⚡ Analizar Pistas sin BPM/Key"
                            onClicked: {
                                if (Mixxx.Library && Mixxx.Library.analyzeUnanalyzedTracks) {
                                    Mixxx.Library.analyzeUnanalyzedTracks();
                                }
                            }
                        }

                        Skin.Button {
                            Layout.preferredHeight: 38
                            Layout.preferredWidth: 180
                            activeColor: "#ff9100"
                            backgroundColor: "#263238"
                            normalColor: "#ffe082"
                            font.bold: true
                            font.pixelSize: 11
                            text: "⟳ Re-analizar Toda la Colección"
                            onClicked: {
                                if (Mixxx.Library && Mixxx.Library.analyzeAllTracks) {
                                    Mixxx.Library.analyzeAllTracks();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ================= BARRA INFERIOR FIJA: ACCIONES Y ESTADO =================
    Rectangle {
        id: libraryAction
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 58
        color: "#181b24"
        border.color: "#282d3c"
        border.width: 1
        radius: 8

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // Status indicator pill
            Rectangle {
                Layout.preferredHeight: 34
                Layout.preferredWidth: statusRow.implicitWidth + 24
                radius: 17
                color: root.isScanning ? "#332200" : (root.dirty ? "#332200" : "#0d2b1a")
                border.color: root.isScanning ? "#ffb300" : (root.dirty ? "#ffb300" : "#00c853")
                border.width: 1

                RowLayout {
                    id: statusRow
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: root.isScanning ? "⏳" : (root.dirty ? "●" : "✓")
                        font.bold: true
                        font.pixelSize: 13
                        color: (root.isScanning || root.dirty) ? "#ffb300" : "#00e676"
                    }
                    Text {
                        text: root.isScanning ? qsTr("Escaneando...") : (root.dirty ? qsTr("Cambios pendientes") : qsTr("Colección lista"))
                        font.bold: true
                        font.pixelSize: 12
                        color: (root.isScanning || root.dirty) ? "#ffe082" : "#b9f6ca"
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Botón Re-escanear Pistas
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 160
                radius: 6
                color: rescanMouse.pressed ? "#1565c0" : (rescanMouse.containsMouse ? "#1e88e5" : "#0d47a1")
                border.color: "#64b5f6"
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "🔄"; font.pixelSize: 12 }
                    Text {
                        text: root.isScanning ? qsTr("Escaneando...") : qsTr("Escanear Pistas")
                        font.bold: true
                        font.pixelSize: 12
                        color: "#ffffff"
                    }
                }

                MouseArea {
                    id: rescanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.isScanning
                    onClicked: {
                        if (Mixxx.Library && Mixxx.Library.rescanLibrary) {
                            Mixxx.Library.rescanLibrary();
                        }
                    }
                }
            }

            // Botón Descartar (visible si hay cambios)
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 110
                radius: 6
                visible: root.dirty
                color: discardMouse.pressed ? "#424242" : (discardMouse.containsMouse ? "#333333" : "#262626")
                border.color: "#555555"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Descartar")
                    font.bold: true
                    font.pixelSize: 13
                    color: "#e0e0e0"
                }

                MouseArea {
                    id: discardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.load();
                        root.dirty = false;
                    }
                }
            }

            // Botón Guardar Preferencias
            Rectangle {
                Layout.preferredHeight: 40
                Layout.preferredWidth: 220
                radius: 6
                color: root.dirty
                       ? (saveMouse.pressed ? "#009624" : (saveMouse.containsMouse ? "#00e676" : "#00c853"))
                       : (saveMouse.pressed ? "#0d47a1" : (saveMouse.containsMouse ? "#1e88e5" : "#1976d2"))
                border.color: root.dirty ? "#69f0ae" : "#64b5f6"
                border.width: 1.5

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: root.dirty ? "💾" : "✓"
                        font.pixelSize: 14
                        color: "#ffffff"
                    }

                    Text {
                        text: root.dirty ? qsTr("Guardar Librería") : qsTr("Guardado")
                        font.bold: true
                        font.pixelSize: 13
                        color: "#ffffff"
                    }
                }

                MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.save();
                    }
                }
            }
        }
    }
}
