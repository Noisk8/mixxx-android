import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import Qt.labs.qmlmodels
import Qt5Compat.GraphicalEffects
import Mixxx 1.0 as Mixxx
import ".." as Skin
import "../Theme"

Category {
    id: root

    property bool dirty: false
    property var editedControllers: new Set()
    property var manager: Mixxx.ControllerManager
    property bool processing: false
    property var selectedController: null
    property bool isRescanning: false
    property bool showGuide: true

    function load() {
        for (let controller of root.editedControllers) {
            controller.clear();
        }
        root.editedControllers.clear();
        root.dirty = false;
        errorMessage.text = "";
    }
    function save() {
        for (let controller of root.editedControllers) {
            controller.save(Mixxx.Config);
        }
        root.selectedController = null;
        root.load();
    }

    Timer {
        id: rescanFeedbackTimer
        interval: 1000
        repeat: false
        onTriggered: {
            root.isRescanning = false;
        }
    }

    label: "Controladoras"

    Component.onCompleted: {
        load();
    }

    ScrollView {
        id: scrollView

        anchors.bottom: controllerAction.top
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            spacing: 16
            width: scrollView.availableWidth

            // ================= TOP ACTION & STATUS BAR =================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: topBarCol.implicitHeight + 20
                color: "#1c202a"
                radius: 12
                border.color: "#2a364f"
                border.width: 1
                visible: root.selectedController == null

                ColumnLayout {
                    id: topBarCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: 38
                            height: 38
                            radius: 19
                            color: "#0d47a1"
                            border.color: "#1e88e5"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "USB"
                                font.bold: true
                                font.pixelSize: 11
                                font.letterSpacing: 1
                                color: "#64b5f6"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: qsTr("Controladoras DJ & Dispositivos USB / MIDI")
                                font.pixelSize: 16
                                font.bold: true
                                color: "#ffffff"
                            }
                            Text {
                                text: manager.knownDevices.length > 0 
                                      ? qsTr("✓ %1 controladora(s) conectada(s) y activa(s)").arg(manager.knownDevices.length)
                                      : qsTr("No hay ninguna controladora USB detectada actualmente")
                                font.pixelSize: 12
                                color: manager.knownDevices.length > 0 ? "#4caf50" : "#9e9e9e"
                            }
                        }

                        // Rescan Button
                        Rectangle {
                            Layout.preferredWidth: 230
                            Layout.preferredHeight: 38
                            radius: 8
                            color: rescanMouse.pressed ? "#1565c0" : (rescanMouse.containsMouse ? "#1e88e5" : "#0d47a1")
                            border.color: "#64b5f6"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8

                                Item {
                                    width: 16
                                    height: 16
                                    Layout.alignment: Qt.AlignVCenter

                                    Canvas {
                                        id: refreshCanvas
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            ctx.strokeStyle = "#ffffff";
                                            ctx.lineWidth = 2.2;
                                            ctx.lineCap = "round";
                                            ctx.beginPath();
                                            ctx.arc(8, 8, 5.5, -0.2 * Math.PI, 1.4 * Math.PI, false);
                                            ctx.stroke();
                                            // Arrowhead
                                            ctx.fillStyle = "#ffffff";
                                            ctx.beginPath();
                                            ctx.moveTo(11, 2);
                                            ctx.lineTo(15, 5);
                                            ctx.lineTo(11, 8);
                                            ctx.closePath();
                                            ctx.fill();
                                        }
                                        Component.onCompleted: requestPaint()
                                    }

                                    RotationAnimation on rotation {
                                        running: root.isRescanning
                                        from: 0
                                        to: 360
                                        duration: 800
                                        loops: Animation.Infinite
                                    }
                                }

                                Text {
                                    text: root.isRescanning ? qsTr("Buscando...") : qsTr("Buscar Dispositivos USB")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                }
                            }

                            MouseArea {
                                id: rescanMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.isRescanning = true;
                                    root.manager.rescan();
                                    rescanFeedbackTimer.restart();
                                }
                            }
                        }
                    }
                }
            }

            // ================= GUÍA PASO A PASO DE CONEXIÓN =================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: guideContent.implicitHeight + 24
                color: "#181f26"
                radius: 12
                border.color: "#273a4b"
                border.width: 1
                visible: root.selectedController == null

                ColumnLayout {
                    id: guideContent
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    // Header row with toggle
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "💡 ¿Cómo conectar tu controladora DJ a Android y que funcione bien?"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#90caf9"
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: 80
                            height: 24
                            radius: 12
                            color: guideToggleArea.containsMouse ? "#263238" : "#1c252d"
                            border.color: "#37474f"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: root.showGuide ? qsTr("Ocultar") : qsTr("Ver guía")
                                font.pixelSize: 11
                                color: "#b0bec5"
                            }

                            MouseArea {
                                id: guideToggleArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.showGuide = !root.showGuide
                            }
                        }
                    }

                    // Steps container
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        visible: root.showGuide

                        // Step 1: Cable OTG
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: "#0288d1"
                                Text {
                                    anchors.centerIn: parent
                                    text: "1"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: qsTr("Adaptador USB OTG Type-C")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: qsTr("Usa un adaptador o cable USB-C a USB-B/A compatible con OTG directo al móvil.")
                                    font.pixelSize: 11
                                    color: "#b0bec5"
                                }
                            }
                        }

                        // Step 2: Alimentación eléctrica
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: "#f57c00"
                                Text {
                                    anchors.centerIn: parent
                                    text: "2"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: qsTr("⚡ Alimentación Externa (Imprescindible para la mayoría)")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffa726"
                                }
                                Text {
                                    text: qsTr("Los móviles entregan poca energía. Si tu controladora (ej: DDJ-FLX4, Traktor, Inpulse) tiene segundo puerto USB o fuente de corriente, conéctala a la pared o usa un HUB USB con alimentación. De lo contrario, se apagará o fallarán los jogs.")
                                    font.pixelSize: 11
                                    color: "#cfd8dc"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // Step 3: Permiso USB
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: "#388e3c"
                                Text {
                                    anchors.centerIn: parent
                                    text: "3"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: qsTr("Permiso USB en Android")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: qsTr("Al enchufar el cable, Android mostrará una ventana: '¿Permitir a Mixxx acceder al dispositivo USB?'. Marca 'Usar siempre para este dispositivo' y pulsa ACEPTAR.")
                                    font.pixelSize: 11
                                    color: "#b0bec5"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // Step 4: Salida de Audio
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: "#7b1fa2"
                                Text {
                                    anchors.centerIn: parent
                                    text: "4"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: qsTr("Activar Audio en Controladora (Master + Auriculares)")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: qsTr("Ve a la pestaña 'Audio & Salidas'. Selecciona el perfil 'Controladora DJ' para que el sonido de la fiesta y la preescucha CUE salgan directamente por la tarjeta de sonido de tu mesa.")
                                    font.pixelSize: 11
                                    color: "#b0bec5"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // Step 5: Mapeos Personalizados
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: "#00b0ff"
                                Text {
                                    anchors.centerIn: parent
                                    text: "5"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: qsTr("Mapeos Personalizados (.midi.xml / .js)")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#80d8ff"
                                }
                                Text {
                                    text: qsTr("¿Quieres usar un mapeo de la comunidad o propio? Cópialo a: <b>/storage/emulated/0/Mixxx/controllers/</b> con cualquier explorador de archivos o por PC. Pulsa el botón 'Buscar Dispositivos USB' arriba y podrás seleccionarlo directamente.")
                                    font.pixelSize: 11
                                    color: "#b0bec5"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // Chip de modelos soportados
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 6
                            color: "#1e272e"

                            Text {
                                anchors.centerIn: parent
                                text: "✨ Compatible con Pioneer DDJ (FLX4, 400, SB3), Hercules Inpulse, Traktor S2/S4, Numark, Reloop y +100 controladores."
                                font.pixelSize: 11
                                color: "#81c784"
                            }
                        }
                    }
                }
            }

            // ================= EMPTY STATE IF NO DEVICES =================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                color: "#181818"
                radius: 12
                border.color: "#2c2c2c"
                border.width: 1
                visible: root.selectedController == null && manager.knownDevices.length === 0 && manager.unknownDevices.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "🔌"
                        font.pixelSize: 32
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No se ha detectado ninguna controladora DJ conectada")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#9e9e9e"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Conecta tu controladora por USB OTG y pulsa 'Buscar Dispositivos USB'")
                        font.pixelSize: 12
                        color: "#616161"
                    }
                }
            }

            // ================= KNOWN CONTROLLERS =================
            GridLayout {
                Layout.fillWidth: true
                columnSpacing: 24
                columns: parseInt(root.width / 1050) + 1

                Repeater {
                    id: controllers

                    model: {
                        if (root.selectedController) {
                            if (root.selectedController?.mapping?.hasSettings)
                                return [root.selectedController];
                            else if (manager.knownDevices.indexOf(root.selectedController) == -1)
                                return [...manager.knownDevices, root.selectedController];
                        }
                        return manager.knownDevices;
                    }

                    delegate: ControllerCard {
                        id: controller

                        focused: knownDevice && root.selectedController == modelData
                        knownDevice: manager.knownDevices.indexOf(modelData) > -1
                        opacity: root.selectedController && !knownDevice && root.selectedController != modelData ? 0.2 : 1

                        onSelect: {
                            root.selectedController = modelData;
                        }
                        onSettingsChanged: {
                            if (!controller.settings && controller.focused) {
                                root.selectedController = null;
                            }
                        }

                        Connections {
                            function onEditedChanged() {
                                if (controller.modelData.edited) {
                                    root.editedControllers.add(controller.modelData);
                                    root.dirty = true;
                                }
                            }

                            target: controller.modelData
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    visible: root.selectedController == null || !root.selectedController.mapping?.hasSettings
                }
            }

            // ================= UNKNOWN DEVICES =================
            ListView {
                id: unknownDevicesList

                Layout.fillWidth: true
                currentIndex: -1
                implicitHeight: contentHeight
                model: manager.unknownDevices
                visible: root.selectedController == null || !root.selectedController.mapping?.hasSettings

                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    color: index % 2 == 0 ? '#0C0C0C' : '#272727'
                    height: 38
                    width: ListView.view.width

                    MouseArea {
                        id: unknownDeviceRow

                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6

                        Rectangle {
                            Layout.preferredHeight: 22
                            Layout.preferredWidth: 44
                            color: '#393939'
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                color: '#FFFFFF'
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                text: {
                                    switch (modelData.type) {
                                    case Mixxx.ControllerDevice.Type.MIDI:
                                        return "MIDI";
                                    case Mixxx.ControllerDevice.Type.HID:
                                        return "HID";
                                    case Mixxx.ControllerDevice.Type.BULK:
                                        return "BULK";
                                    }
                                    return "UNKN";
                                }
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            color: '#FFFFFF'
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            text: modelData.name
                        }
                        Skin.FormButton {
                            activeColor: "#999999"
                            text: qsTr("Configurar Mapeo")
                            visible: unknownDeviceRow.containsMouse || hovered || unknownDevicesList.currentIndex == index

                            onPressed: {
                                root.selectedController = modelData;
                                root.dirty = true;
                            }
                        }
                        TapHandler {
                            onTapped: {
                                unknownDevicesList.currentIndex = index;
                            }
                        }
                    }
                }
                header: Rectangle {
                    color: "#161616"
                    implicitHeight: 36
                    width: ListView.view.width
                    visible: manager.unknownDevices.length > 0

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.margins: 10
                        anchors.rightMargin: 20
                        color: '#FFFFFF'
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        text: qsTr("Otros dispositivos USB detectados sin mapear")
                    }
                }
            }
        }
    }

    // ================= BARRA INFERIOR FIJA: ACCIONES Y ESTADO =================
    Rectangle {
        id: controllerAction
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
                color: root.dirty ? "#332200" : (manager.knownDevices.length > 0 ? "#0d2b1a" : "#1a2233")
                border.color: root.dirty ? "#ffb300" : (manager.knownDevices.length > 0 ? "#00c853" : "#2196f3")
                border.width: 1

                RowLayout {
                    id: statusRow
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: root.dirty ? "●" : (manager.knownDevices.length > 0 ? "✓" : "🎛️")
                        font.bold: true
                        font.pixelSize: 13
                        color: root.dirty ? "#ffb300" : (manager.knownDevices.length > 0 ? "#00e676" : "#64b5f6")
                    }
                    Text {
                        text: root.dirty 
                              ? qsTr("Cambios pendientes") 
                              : (root.selectedController 
                                 ? qsTr("Editando controladora") 
                                 : (manager.knownDevices.length > 0 ? qsTr("Controladora lista") : qsTr("USB MIDI")))
                        font.bold: true
                        font.pixelSize: 12
                        color: root.dirty ? "#ffe082" : (manager.knownDevices.length > 0 ? "#b9f6ca" : "#bbdefb")
                    }
                }
            }

            // Error message if any
            Text {
                id: errorMessage
                Layout.alignment: Qt.AlignVCenter
                visible: text.length > 0
                color: "#ff5252"
                font.pixelSize: 12
                text: ""
            }

            Item { Layout.fillWidth: true }

            // Botón Restablecer
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 140
                radius: 6
                visible: !!root.selectedController?.mapping?.hasSettings
                color: resetMouse.pressed ? "#5c2b2b" : (resetMouse.containsMouse ? "#4a2222" : "#371e1e")
                border.color: "#772b2b"
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "↺"; color: "#ff8a80"; font.pixelSize: 14 }
                    Text {
                        text: qsTr("Restablecer")
                        font.bold: true
                        font.pixelSize: 12
                        color: "#ffcdd2"
                    }
                }

                MouseArea {
                    id: resetMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedController?.mapping?.resetSettings(root.selectedController);
                        root.load();
                    }
                }
            }

            // Botón Descartar / Volver
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 130
                radius: 6
                visible: root.dirty || root.selectedController !== null
                color: discardMouse.pressed ? "#424242" : (discardMouse.containsMouse ? "#333333" : "#262626")
                border.color: "#555555"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: root.selectedController ? qsTr("Volver / Lista") : qsTr("Descartar")
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
                        root.selectedController = null;
                        root.load();
                        errorMessage.text = "";
                    }
                }
            }

            // Botón Guardar Cambios
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
                        text: root.dirty ? qsTr("Guardar Cambios") : qsTr("Guardado")
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
                        errorMessage.text = "";
                        root.save();
                    }
                }
            }
        }
    }
}
