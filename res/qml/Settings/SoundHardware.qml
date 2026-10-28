import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Mixxx 1.0 as Mixxx
import ".." as Skin
import "../Theme"

Category {
    id: root

    property bool committing: false
    property bool hasChanges: router.hasChanges
    property string activePreset: ""
    property bool showAdvancedRouter: false

    function getSpeakerDevice(devices) {
        if (!devices || devices.length === 0) return null;
        for (let d of devices) {
            let n = (d.displayName || "").toLowerCase();
            if (n.includes("speaker") || n.includes("altavoz")) return d;
        }
        for (let d of devices) {
            let n = (d.displayName || "").toLowerCase();
            if (n.includes("usb") || n.includes("headphone") || n.includes("headset")) return d;
        }
        for (let d of devices) {
            let n = (d.displayName || "").toLowerCase();
            if (!n.includes("earpiece")) return d;
        }
        return devices[0];
    }

    function getMultiChannelDevice(devices) {
        if (!devices || devices.length === 0) return null;
        for (let d of devices) {
            let n = (d.displayName || "").toLowerCase();
            if (n.includes("earpiece")) continue;
            if (d.channelCount >= 4) return d;
        }
        for (let d of devices) {
            let n = (d.displayName || "").toLowerCase();
            if ((n.includes("usb") || n.includes("external")) && !n.includes("earpiece")) return d;
        }
        return getSpeakerDevice(devices);
    }

    function applyPreset(presetType) {
        root.activePreset = presetType;
        const manager = Mixxx.SoundManager;
        if (presetType === "single") {
            mainMixEnabled.selected = "on";
            mainOutputMode.selected = "stereo";
            monoMix.value = 0;
            mainEnabled.value = 1;
            headEnabled.value = 0;
            let devices = manager.availableOutputDevices(soundApi.selected);
            let dev = getSpeakerDevice(devices);
            if (dev) {
                manager.clearOutputs();
                manager.addOutput(dev, 0, 0, 0); // Main: Channels 1-2
            }
        } else if (presetType === "splitter") {
            mainMixEnabled.selected = "on";
            mainOutputMode.selected = "mono";
            monoMix.value = 1;
            mainEnabled.value = 1;
            headEnabled.value = 1;
            let devices = manager.availableOutputDevices(soundApi.selected);
            let dev = getSpeakerDevice(devices);
            if (dev) {
                manager.clearOutputs();
                manager.addOutput(dev, 0, 0, 0); // Main (Left)
                manager.addOutput(dev, 1, 0, 0); // Headphone CUE (Right)
            }
        } else if (presetType === "controller") {
            mainMixEnabled.selected = "on";
            mainOutputMode.selected = "stereo";
            monoMix.value = 0;
            mainEnabled.value = 1;
            headEnabled.value = 1;
            let devices = manager.availableOutputDevices(soundApi.selected);
            let targetDev = getMultiChannelDevice(devices);
            if (targetDev) {
                manager.clearOutputs();
                manager.addOutput(targetDev, 0, 0, 0); // Main: Channels 1-2
                if (targetDev.channelCount >= 4) {
                    manager.addOutput(targetDev, 1, 2, 0); // Headphone CUE: Channels 3-4
                } else {
                    manager.addOutput(targetDev, 1, 0, 0);
                }
            }
        }
        root.hasChanges = true;
    }

    function load() {
        const manager = Mixxx.SoundManager;
        mainMixEnabled.selected = mainMixEnabled.options[mainEnabled.value ? 0 : 1];
        mainOutputMode.selected = mainOutputMode.options[monoMix.value ? 0 : 1];
        soundClock.selected = soundClock.options[manager.getForceNetworkClock() ? 1 : 0];
        sampleRate.update(manager.getAPI());
        sampleRate.selected = qsTr("%1 Hz").arg(manager.getSampleRate());
        audioBuffer.currentIndex = manager.getAudioBufferSizeIndex() - 1;
        microphoneMonitorMode.enabled = manager.hasMicInputs();
        microphoneMonitorMode.currentIndex = micMonitorMode.value;
        soundApi.options = manager.getHostAPIList();
        let curApi = manager.getAPI();
        if ((!curApi || curApi === "ALSA") && soundApi.options.indexOf("Android Oboe") !== -1) {
            curApi = "Android Oboe";
            manager.setAPI(curApi);
        }
        soundApi.selected = curApi;
        keylock.update();
        keylock.selected = keylock.options[manager.getKeylockEngine()];

        // Detect current preset
        if (monoMix.value === 1) {
            root.activePreset = "splitter";
        } else if (headEnabled.value === 1) {
            root.activePreset = "controller";
        } else {
            root.activePreset = "single";
        }

        // Router
        router.multiSoundcard.selected = router.multiSoundcard.options[manager.getSyncBuffers()];
        router.update(manager.getAPI());

        // Delays
        mainDelayLabel.enabled = mainEnabled.value;
        mainDelaySlider.enabled = mainEnabled.value;
        mainDelaySlider.value = mainDelay.value;
        boothDelayLabel.enabled = boothEnabled.value;
        boothDelaySlider.enabled = boothEnabled.value;
        boothDelaySlider.value = boothDelay.value;
        headphoneDelayLabel.enabled = headEnabled.value;
        headphoneDelaySlider.enabled = headEnabled.value;
        headphoneDelaySlider.value = headDelay.value;

        root.hasChanges = Qt.binding(function () {
            return router.hasChanges;
        });
    }

    function save() {
        const manager = Mixxx.SoundManager;
        mainEnabled.value = mainMixEnabled.options.indexOf(mainMixEnabled.selected);
        monoMix.value = !mainOutputMode.options.indexOf(mainOutputMode.selected);
        manager.setForceNetworkClock(soundClock.options[1] == soundClock.selected);
        manager.setSampleRate(parseInt(sampleRate.selected));
        manager.setAudioBufferSizeIndex(audioBuffer.currentIndex + 1);
        micMonitorMode.value = microphoneMonitorMode.currentIndex;
        manager.setAPI(soundApi.selected);
        manager.setKeylockEngine(keylock.options.indexOf(keylock.selected));

        // Router
        manager.setSyncBuffers(router.multiSoundcard.options.indexOf(router.multiSoundcard.selected));

        let connectionsHandler = (connections, device) => {
            for (let channel of Object.keys(connections)) {
                let connection = connections[channel];
                let type;
                let index = 0;
                let isOutput = true;
                if (connection.source.entity.name == "Mixer") {
                    switch (connection.source.address) {
                    case "Main":
                        type = 0;
                        break;
                    case "PFL":
                        type = 1;
                        break;
                    case "Booth":
                        type = 2;
                        break;
                    case "Left Bus":
                    case "Center Bus":
                    case "Right Bus":
                        index = connection.source.address.startsWith("Left") ? 0 : connection.source.address.startsWith("Right") ? 2 : 1;
                        type = 3;
                        break;
                    default:
                        console.error(`unsupported address: ${connection.source.address}`);
                        continue;
                    }
                } else if (connection.sink.entity.name == "Mixer") {
                    isOutput = false;
                    type = connection.sink.address == "Auxiliary" ? 7 : 6;
                    index = connection.sink.instance;
                } else if (connection.source.entity.name.startsWith("Deck ") && connection.source.address == "Output") {
                    type = 4;
                    index = parseInt(connection.source.entity.name.split(' ')[1]) - 1;
                } else if (connection.sink.entity.name.startsWith("Deck ")) {
                    isOutput = false;
                    type = connection.source.address == "Output" ? 4 : 5;
                    index = parseInt(connection.sink.entity.name.split(' ')[1]) - 1;
                } else if (connection.sink.entity.name == "Microphone") {
                    isOutput = false;
                    type = 6;
                    index = connection.sink.instance;
                } else if (connection.sink.entity.name == "Auxiliary") {
                    isOutput = false;
                    type = 7;
                    index = connection.sink.instance;
                } else if (connection.sink.entity.name == "RecordBroadcast") {
                    isOutput = false;
                    type = 8;
                    index = connection.sink.instance;
                } else {
                    console.error(`unsupported entity: ${connection.source.entity.name} ${connection.sink.entity.name}`);
                    continue;
                }
                console.log(isOutput ? "addOutput" : "addInput", device, type, channel * 2, index);
                if (isOutput) {
                    manager.addOutput(device, type, channel * 2, index);
                } else {
                    manager.addInput(device, type, channel * 2, index);
                }
            }
        };

        if (root.activePreset === "single") {
            manager.clearOutputs();
            let devices = manager.availableOutputDevices(soundApi.selected);
            let dev = getSpeakerDevice(devices);
            if (dev) {
                manager.addOutput(dev, 0, 0, 0);
            }
        } else if (root.activePreset === "splitter") {
            manager.clearOutputs();
            let devices = manager.availableOutputDevices(soundApi.selected);
            let dev = getSpeakerDevice(devices);
            if (dev) {
                manager.addOutput(dev, 0, 0, 0); // Main
                manager.addOutput(dev, 1, 0, 0); // Headphones CUE
            }
        } else if (root.activePreset === "controller") {
            manager.clearOutputs();
            let devices = manager.availableOutputDevices(soundApi.selected);
            let targetDev = getMultiChannelDevice(devices);
            if (targetDev) {
                manager.addOutput(targetDev, 0, 0, 0); // Main (1-2)
                manager.addOutput(targetDev, 1, targetDev.channelCount >= 4 ? 2 : 0, 0); // Headphones (3-4 or 1-2)
            }
        } else {
            manager.clearOutputs();
            for (let device of Object.keys(router.outputs)) {
                for (let address of Object.keys(router.outputs[device].gateways)) {
                    let gateway = router.outputs[device].gateways[address];
                    let connections = gateway.node && gateway.node.assignedEdges ? gateway.node.assignedEdges() : {};
                    connectionsHandler(connections, gateway.device);
                }
            }
        }

        manager.clearInputs();
        for (let device of Object.keys(router.inputs)) {
            for (let address of Object.keys(router.inputs[device].gateways)) {
                let gateway = router.inputs[device].gateways[address];
                let connections = gateway.node && gateway.node.assignedEdges ? gateway.node.assignedEdges() : {};
                connectionsHandler(connections, gateway.device);
            }
        }

        mainDelay.value = mainDelaySlider.value;
        boothDelay.value = boothDelaySlider.value;
        headDelay.value = headphoneDelaySlider.value;

        root.committing = true;
        manager.commit();
    }

    label: "Audio & Salidas"
    tabs: ["Configuración & Salidas", "Retardos (Delays)"]

    Component.onCompleted: {
        load();
    }

    Mixxx.ControlProxy {
        id: mainEnabled
        group: "[Master]"
        key: "enabled"
    }
    Mixxx.ControlProxy {
        id: headEnabled
        group: "[Master]"
        key: "headEnabled"
    }
    Mixxx.ControlProxy {
        id: boothEnabled
        group: "[Master]"
        key: "booth_enabled"
    }
    Mixxx.ControlProxy {
        id: mainDelay
        group: "[Master]"
        key: "delay"
    }
    Mixxx.ControlProxy {
        id: headDelay
        group: "[Master]"
        key: "headDelay"
    }
    Mixxx.ControlProxy {
        id: boothDelay
        group: "[Master]"
        key: "boothDelay"
    }
    Mixxx.ControlProxy {
        id: monoMix
        group: "[Master]"
        key: "mono_mixdown"
    }
    Mixxx.ControlProxy {
        id: micMonitorMode
        group: "[Master]"
        key: "talkover_mix"
    }

    ScrollView {
        id: scrollView
        anchors.bottom: soundAction.top
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            spacing: 16
            width: scrollView.availableWidth

            // ================= PESTAÑA 1: CONFIGURACIÓN & SALIDAS =================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                visible: root.selectedIndex === 0

                // CARD 1: PERFILES DE SALIDA RÁPIDOS (1-TOUCH PRESETS)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: presetsCol.implicitHeight + 28
                    color: "#181f2a"
                    radius: 12
                    border.color: "#283b54"
                    border.width: 1

                    ColumnLayout {
                        id: presetsCol
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "⚡ Perfiles Rápidos de Salida de Audio"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#64b5f6"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: qsTr("Pulsa para configurar automáticamente")
                                font.pixelSize: 11
                                color: "#90a4ae"
                            }
                        }

                        // 3 Interactive Preset Cards
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            // Preset 1: Móvil / Bluetooth (Salida simple)
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105
                                radius: 10
                                color: root.activePreset === "single" ? "#1e3a5f" : (p1Mouse.containsMouse ? "#212b38" : "#1a222c")
                                border.color: root.activePreset === "single" ? "#42a5f5" : "#324050"
                                border.width: root.activePreset === "single" ? 2 : 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    RowLayout {
                                        Text { text: "📱"; font.pixelSize: 16 }
                                        Text {
                                            text: qsTr("Móvil / Bluetooth")
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: root.activePreset === "single" ? "#ffffff" : "#cfd8dc"
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: root.activePreset === "single" ? "✓ ACTIVO" : ""
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: "#64b5f6"
                                        }
                                    }
                                    Text {
                                        text: qsTr("Salida única estéreo. Todo el sonido va a los altavoces del teléfono o a un altavoz/auricular Bluetooth.")
                                        font.pixelSize: 11
                                        color: "#90a4ae"
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }

                                MouseArea {
                                    id: p1Mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.applyPreset("single")
                                }
                            }

                            // Preset 2: Cable Splitter DJ
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105
                                radius: 10
                                color: root.activePreset === "splitter" ? "#3e2723" : (p2Mouse.containsMouse ? "#2d221f" : "#1e1a19")
                                border.color: root.activePreset === "splitter" ? "#ff7043" : "#4e342e"
                                border.width: root.activePreset === "splitter" ? 2 : 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    RowLayout {
                                        Text { text: "🎧"; font.pixelSize: 16 }
                                        Text {
                                            text: qsTr("Cable Splitter DJ")
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: root.activePreset === "splitter" ? "#ffffff" : "#cfd8dc"
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: root.activePreset === "splitter" ? "✓ ACTIVO" : ""
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: "#ffab91"
                                        }
                                    }
                                    Text {
                                        text: qsTr("Separa el jack en dos: Canal Izq a los altavoces de la fiesta y Canal Der a tus auriculares para hacer CUE.")
                                        font.pixelSize: 11
                                        color: "#b0bec5"
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }

                                MouseArea {
                                    id: p2Mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.applyPreset("splitter")
                                }
                            }

                            // Preset 3: Controladora DJ / 4 Canales
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 105
                                radius: 10
                                color: root.activePreset === "controller" ? "#1b3a24" : (p3Mouse.containsMouse ? "#1c2b1e" : "#172218")
                                border.color: root.activePreset === "controller" ? "#66bb6a" : "#2e4c34"
                                border.width: root.activePreset === "controller" ? 2 : 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    RowLayout {
                                        Text { text: "🎛️"; font.pixelSize: 16 }
                                        Text {
                                            text: qsTr("Controladora DJ")
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: root.activePreset === "controller" ? "#ffffff" : "#cfd8dc"
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: root.activePreset === "controller" ? "✓ ACTIVO" : ""
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: "#81c784"
                                        }
                                    }
                                    Text {
                                        text: qsTr("Audio Pro multicanal: Canales 1-2 al Master (altavoces) y Canales 3-4 independientes a los auriculares de la mesa.")
                                        font.pixelSize: 11
                                        color: "#a5d6a7"
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }

                                MouseArea {
                                    id: p3Mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.applyPreset("controller")
                                }
                            }
                        }
                    }
                }

                // CARD 2: MOTOR DE AUDIO & LATENCIA
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: engineSettingsCol.implicitHeight + 28
                    color: "#181818"
                    radius: 12
                    border.color: "#2c2c2c"
                    border.width: 1

                    ColumnLayout {
                        id: engineSettingsCol
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Text {
                            text: qsTr("⚙️ Motor de Audio, Latencia & Calidad")
                            font.pixelSize: 15
                            font.bold: true
                            color: "#ffffff"
                        }

                        // Grid with settings
                        GridLayout {
                            Layout.fillWidth: true
                            columns: root.width > 750 ? 2 : 1
                            columnSpacing: 24
                            rowSpacing: 12

                            // Sound API
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: qsTr("API de Audio")
                                }
                                RatioChoice {
                                    id: soundApi
                                    maxWidth: 240
                                    options: []
                                    onSelectedChanged: {
                                        root.hasChanges = true;
                                        router.update(soundApi.selected);
                                        sampleRate.update(soundApi.selected);
                                    }
                                }
                            }

                            // Sample Rate
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: qsTr("Frecuencia de Muestreo")
                                }
                                RatioChoice {
                                    id: sampleRate
                                    function update(api) {
                                        let data = [];
                                        for (let sr of Mixxx.SoundManager.getSampleRates(api)) {
                                            data.push(qsTr("%1 Hz").arg(sr));
                                        }
                                        sampleRate.options = data;
                                    }
                                    maxWidth: 240
                                    options: []
                                    onSelectedChanged: {
                                        root.hasChanges = true;
                                    }
                                }
                                Connections {
                                    target: sampleRate
                                    function onSelectedChanged() {
                                        let sampleRateValue = parseInt(sampleRate.selected);
                                        audioBuffer.update(sampleRateValue);
                                    }
                                }
                            }

                            // Audio Buffer (Latency)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        Layout.fillWidth: true
                                        color: Theme.white
                                        font.pixelSize: 13
                                        text: qsTr("Latencia / Buffer de Audio")
                                    }
                                    Skin.ComboBox {
                                        id: audioBuffer
                                        function update(sr) {
                                            let data = [];
                                            let framesPerBuffer = 1;
                                            for (; framesPerBuffer / sr * 1000 < 1.0; framesPerBuffer *= 2) {}
                                            for (let i = 0; i < 7; i++) {
                                                const latency = framesPerBuffer / sr * 1000;
                                                data.push(qsTr("%1 ms").arg(latency.toFixed(1)));
                                                framesPerBuffer *= 2;
                                            }
                                            let cur = audioBuffer.currentIndex;
                                            audioBuffer.model = data;
                                            audioBuffer.currentIndex = cur;
                                        }
                                        clip: true
                                        font.pixelSize: 12
                                        spacing: 2
                                        onCurrentIndexChanged: {
                                            root.hasChanges = true;
                                        }
                                    }
                                }

                                // Latency explanation text
                                Text {
                                    text: {
                                        const idx = audioBuffer.currentIndex;
                                        if (idx <= 1) return qsTr("⚡ Latencia Ultra-Baja: Respuesta instantánea para scratch y mezclas rápidas.");
                                        if (idx <= 3) return qsTr("⚖️ Latencia Equilibrada: Recomendada para la mayoría de teléfonos Android (estable y sin cortes).");
                                        return qsTr("🛡️ Modo Seguro: Máxima estabilidad si notas chasquidos o si el móvil va lento.");
                                    }
                                    font.pixelSize: 11
                                    color: audioBuffer.currentIndex <= 1 ? "#64b5f6" : (audioBuffer.currentIndex <= 3 ? "#81c784" : "#ffb74d")
                                }
                            }

                            // Main Output Mode (Mono / Stereo)
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: qsTr("Modo de Mezcla Principal")
                                }
                                RatioChoice {
                                    id: mainOutputMode
                                    maxWidth: 200
                                    options: ["mono", "stereo"]
                                    selected: options[monoMix.value ? 0 : 1]
                                    onSelectedChanged: {
                                        root.hasChanges = true;
                                    }
                                }
                            }

                            // Keylock engine
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: qsTr("Calidad Keylock (Bloqueo de Tono)")
                                }
                                RatioChoice {
                                    id: keylock
                                    function update() {
                                        let opts = [];
                                        let tips = [];
                                        for (let eng of Mixxx.SoundManager.getKeylockEngines()) {
                                            switch (eng) {
                                            case 0:
                                                opts.push(qsTr("Soundtouch"));
                                                tips.push(qsTr("Rápido"));
                                                break;
                                            case 1:
                                                opts.push(qsTr("Rubberband"));
                                                tips.push(qsTr("Alta Calidad"));
                                                break;
                                            case 2:
                                                opts.push(qsTr("Rubberband R3"));
                                                tips.push(qsTr("Máxima Calidad Hi-Fi"));
                                                break;
                                            }
                                        }
                                        keylock.options = opts;
                                        keylock.tooltips = tips;
                                    }
                                    maxWidth: 240
                                    normalizedWidth: false
                                    options: []
                                    tooltips: []
                                    onSelectedChanged: {
                                        root.hasChanges = true;
                                    }
                                }
                            }

                            // Main Mix Enabled
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: qsTr("Mezcla Principal (Main Mix)")
                                }
                                RatioChoice {
                                    id: mainMixEnabled
                                    options: ["on", "off"]
                                    selected: options[mainEnabled.value ? 0 : 1]
                                    onSelectedChanged: {
                                        root.hasChanges = true;
                                    }
                                }
                            }
                        }

                        // Network Clock (oculto / avanzado)
                        RowLayout {
                            Layout.fillWidth: true
                            visible: false
                            RatioChoice {
                                id: soundClock
                                options: ["soundcard", "network"]
                            }
                            Skin.ComboBox {
                                id: microphoneMonitorMode
                                model: ["Main output only", "Main and booth outputs", "Direct monitor"]
                            }
                        }
                    }
                }

                // CARD 3: ROUTER AVANZADO (CABLES VIRTUALES)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.showAdvancedRouter ? 460 : 54
                    color: "#181818"
                    radius: 12
                    border.color: "#2c2c2c"
                    border.width: 1
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // Header with toggle
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "🔧 Matriz de Ruteo Avanzada (Cables Virtuales)"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#b0bec5"
                            }
                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: 150
                                height: 28
                                radius: 6
                                color: toggleRouterMouse.containsMouse ? "#2e3b4e" : "#222c3a"
                                border.color: "#3f51b5"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: root.showAdvancedRouter ? qsTr("Ocultar Matriz") : qsTr("Mostrar Matriz Completa")
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#90caf9"
                                }

                                MouseArea {
                                    id: toggleRouterMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.showAdvancedRouter = !root.showAdvancedRouter;
                                        if (root.showAdvancedRouter) {
                                            root.activePreset = ""; // switched to manual routing
                                        }
                                    }
                                }
                            }
                        }

                        // The full AudioRouter canvas
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: root.showAdvancedRouter

                            AudioRouter {
                                id: router
                                anchors.fill: parent
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: Qt.alpha('grey', 0.3)
                                visible: root.committing

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    preventStealing: true
                                    onWheel: mouse => { mouse.accepted = true; }
                                }
                            }
                        }
                    }
                }
            }

            // ================= PESTAÑA 2: RETARDOS (DELAYS) =================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                visible: root.selectedIndex === 1

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: delaysCol.implicitHeight + 28
                    color: "#181818"
                    radius: 12
                    border.color: "#2c2c2c"
                    border.width: 1

                    ColumnLayout {
                        id: delaysCol
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 14

                        Text {
                            text: qsTr("Ajuste de Retardos de Salida (Compensación de Latencia Acústica)")
                            font.pixelSize: 15
                            font.bold: true
                            color: "#ffffff"
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 10

                            Text {
                                id: mainDelayLabel
                                Layout.fillWidth: true
                                color: Theme.white
                                font.pixelSize: 14
                                opacity: enabled ? 1 : 0.5
                                text: qsTr("Retardo Salida Principal (Master)")
                            }
                            Skin.Slider {
                                id: mainDelaySlider
                                Layout.fillWidth: true
                                markers: ["0ms", "100ms", "1s", "10s", null]
                                slider.to: 1000
                                suffix: "ms"
                                onValueChanged: { root.hasChanges = true; }
                            }

                            Text {
                                id: boothDelayLabel
                                Layout.fillWidth: true
                                color: Theme.white
                                enabled: boothEnabled.value
                                font.pixelSize: 14
                                opacity: enabled ? 1 : 0.5
                                text: qsTr("Retardo Salida Cabina (Booth)")
                            }
                            Skin.Slider {
                                id: boothDelaySlider
                                Layout.fillWidth: true
                                enabled: boothEnabled.value
                                markers: ["0ms", "100ms", "1s", "10s", null]
                                slider.to: 1000
                                suffix: "ms"
                                value: boothDelay.value
                                onValueChanged: { root.hasChanges = true; }
                            }

                            Text {
                                id: headphoneDelayLabel
                                Layout.fillWidth: true
                                color: Theme.white
                                enabled: headEnabled.value
                                font.pixelSize: 14
                                opacity: enabled ? 1 : 0.5
                                text: qsTr("Retardo Salida Auriculares (CUE)")
                            }
                            Skin.Slider {
                                id: headphoneDelaySlider
                                Layout.fillWidth: true
                                enabled: headEnabled.value
                                markers: ["0ms", "100ms", "1s", "10s", null]
                                slider.to: 1000
                                suffix: "ms"
                                value: headDelay.value
                                onValueChanged: { root.hasChanges = true; }
                            }
                        }
                    }
                }
            }

        }
    }

    // ================= PINNED BOTTOM ACTION BAR =================
    Rectangle {
        id: soundAction
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 58
        color: "#161b24"
        border.color: "#283548"
        border.width: 1
        radius: 8

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            // Status Indicator Pill
            Rectangle {
                Layout.preferredHeight: 30
                Layout.preferredWidth: statusText.implicitWidth + 20
                radius: 15
                color: root.hasChanges ? "#3e2723" : "#1b5e20"
                border.color: root.hasChanges ? "#ff9800" : "#4caf50"
                border.width: 1

                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: root.hasChanges ? "● Cambios pendientes" : "✓ Audio configurado"
                    font.bold: true
                    font.pixelSize: 11
                    color: root.hasChanges ? "#ffb74d" : "#81c784"
                }
            }

            Text {
                id: errorMessage
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: 12
                color: "#ff5252"
                text: ""
            }

            Skin.Button {
                visible: root.hasChanges
                Layout.preferredHeight: 38
                Layout.preferredWidth: 130
                activeColor: "#ff5252"
                backgroundColor: "#2a1b1b"
                normalColor: "#ff8a80"
                font.bold: true
                font.pixelSize: 12
                text: qsTr("Descartar")
                onClicked: {
                    errorMessage.text = "";
                    root.load();
                }
            }

            Rectangle {
                id: applyButtonRect
                Layout.preferredHeight: 40
                Layout.preferredWidth: 230
                radius: 8
                color: root.committing ? "#1565c0" : (root.hasChanges ? "#00c853" : (applyMouse.containsMouse ? "#2979ff" : "#1976d2"))
                border.color: root.hasChanges ? "#b9f6ca" : "#64b5f6"
                border.width: 1.5

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: root.committing ? "⏳" : (root.hasChanges ? "💾" : "✓")
                        font.pixelSize: 14
                        color: "#ffffff"
                    }

                    Text {
                        text: root.committing ? qsTr("Aplicando...") : qsTr("Aplicar y Guardar Salidas")
                        font.bold: true
                        font.pixelSize: 13
                        color: "#ffffff"
                    }
                }

                MouseArea {
                    id: applyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.committing
                    onClicked: {
                        errorMessage.text = "";
                        root.save();
                    }
                }
            }
        }
    }

    Connections {
        function onCommitted(error) {
            root.committing = false;
            if (error) {
                errorMessage.text = error;
            }
            root.load();
        }
        target: Mixxx.SoundManager
    }
}
