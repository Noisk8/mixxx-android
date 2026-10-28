import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Mixxx 1.0 as Mixxx
import "." as Setting
import "../Deck" as DeckComponents
import "." as SettingComponents
import ".." as Skin
import "../Theme"

Category {
    id: root

    function load() {
        loadInterface();
        loadDeck();
        errorMessage.text = "";
    }

    function loadDeck() {
        cueModeInput.currentIndex = Mixxx.Config.controlCueDefault;
        setIntroStartToMainCueInput.selected = Mixxx.Config.controlSetIntroStartAtMainCue ? "on" : "off";
        trackTimeDisplayInput.selected = trackTimeDisplayInput.options[Mixxx.Config.controlPositionDisplay] || "elapsed";
        timeMode.currentIndex = Mixxx.Config.controlTimeFormat;
        doublePressLoadToCloneInput.selected = Mixxx.Config.controlCloneDeckOnLoadDoubleTap ? "on" : "off";
        trackLoadPointInput.currentIndex = Mixxx.Config.controlCueRecall;
        loadingTrackWhenPlayingInput.selected = loadingTrackWhenPlayingInput.options[Mixxx.Config.controlLoadWhenDeckPlaying] || "reject";
        resetOnTrackLoadInput.selected = resetOnTrackLoadInput.options[Mixxx.Config.controlSpeedAutoReset] || "none";
        sliderRangeInput.currentIndex = sliderRangeInput.values.indexOf(Mixxx.Config.controlRateRange);
        if (sliderRangeInput.currentIndex === -1) {
            sliderRangeInput.values.push(Mixxx.Config.controlRateRange);
            sliderRangeInput.model.push(`${Mixxx.Config.controlRateRange}%`);
            sliderRangeInput.currentIndex = sliderRangeInput.model.length - 1;
        }
        syncModeInput.selected = syncModeInput.options[Mixxx.Config.bpmSyncLockAlgorithm] || "follow soft leader";
        sliderOrientationInput.selected = Mixxx.Config.controlRateDir === -1 ? "down" : "up";
        keylockModeInput.selected = keylockModeInput.options[Mixxx.Config.controlKeylockMode] || "original key";
        keyunlockModeInput.selected = keyunlockModeInput.options[Mixxx.Config.controlKeyunlockMode] || "reset key";
        pitchBendBehaviourInput.selected = pitchBendBehaviourInput.options[Mixxx.Config.controlPitchBendBehaviour] || "abrupt jump";
        adjustmentButtonsTemporaryCoarseInput.value = Mixxx.Config.controlRateTempCoarse * 100;
        adjustmentButtonsTemporaryFineInput.value = Mixxx.Config.controlRateTempFine * 100;
        adjustmentButtonsPermanentCoarseInput.value = Mixxx.Config.controlRatePermCoarse * 100;
        adjustmentButtonsPermanentFineInput.value = Mixxx.Config.controlRatePermFine * 100;
        rampingSensitivityInput.value = Mixxx.Config.controlRateRampSensitivity;
        decksTab.dirty = false;
    }

    function loadInterface() {
        tooltipsInput.selected = tooltipsInput.options[Mixxx.Config.libraryTooltips] || "off";
        disableScreensaverInput.selected = disableScreensaverInput.options[Mixxx.Config.libraryInhibitScreensaver] || "no";
        startFullscreenInput.selected = Mixxx.Config.configStartInFullscreenKey ? "on" : "off";
        autoHideMenuBarInput.selected = Mixxx.Config.libraryHideMenuBar ? "on" : "off";
        searchCompletionInput.selected = Mixxx.Config.libraryEnableSearchCompletions ? "on" : "off";
        searchHistoryKeyboardInput.selected = Mixxx.Config.libraryEnableSearchHistoryShortcuts ? "on" : "off";
        bpmPrecisionInput.value = Mixxx.Config.libraryBpmColumnPrecision;
        libraryRowHeightInput.value = Mixxx.Config.libraryRowHeight;
        trackPaletteComboBox.currentIndex = Math.max(0, trackPaletteComboBox.model.indexOf(Mixxx.Config.configTrackColorPalette));
        hotcuePaletteComboBox.currentIndex = Math.max(0, hotcuePaletteComboBox.model.indexOf(Mixxx.Config.configHotcueColorPalette));
        keyPaletteInput.selected = Mixxx.Config.configKeyColorsEnabled ? "on" : "off";
        keyPaletteComboBox.currentIndex = Math.max(0, keyPaletteComboBox.model.indexOf(Mixxx.Config.configKeyColorPalette));

        colorPane.hotcuePaletteColorIndex = Mixxx.Config.controlHotcueDefaultColorIndex;
        if (colorPane.hotcuePaletteColorIndex < 0)
            colorPane.hotcuePaletteColorIndex = colorPane.defaultPalette.length - 1;
        hotcuePaletteInput.currentIndex = colorPane.hotcuePaletteColorIndex;

        colorPane.loopPaletteColorIndex = Mixxx.Config.controlLoopDefaultColorIndex;
        if (colorPane.loopPaletteColorIndex < 0)
            colorPane.loopPaletteColorIndex = colorPane.defaultPalette.length - 2;
        loopPaletteInput.currentIndex = colorPane.loopPaletteColorIndex;

        colorPane.jumpPaletteColorIndex = colorPane.defaultPalette.length - 3;
        jumpPaletteInput.currentIndex = colorPane.jumpPaletteColorIndex;

        themeColorTab.dirty = false;
    }

    function resetDeck() {
        loadDeck();
    }

    function resetInterface() {
        loadInterface();
    }

    function saveDeck() {
        Mixxx.Config.controlCueDefault = cueModeInput.currentIndex;
        Mixxx.Config.controlSetIntroStartAtMainCue = setIntroStartToMainCueInput.selected === "on";
        Mixxx.Config.controlPositionDisplay = trackTimeDisplayInput.options.indexOf(trackTimeDisplayInput.selected);
        Mixxx.Config.controlTimeFormat = timeMode.currentIndex;
        Mixxx.Config.controlCloneDeckOnLoadDoubleTap = doublePressLoadToCloneInput.selected === "on";
        Mixxx.Config.controlCueRecall = trackLoadPointInput.currentIndex;
        Mixxx.Config.controlLoadWhenDeckPlaying = loadingTrackWhenPlayingInput.options.indexOf(loadingTrackWhenPlayingInput.selected);
        Mixxx.Config.controlSpeedAutoReset = resetOnTrackLoadInput.options.indexOf(resetOnTrackLoadInput.selected);
        for (let i = 0; i < deckRateRange.count; i++) {
            deckRateRange.objectAt(i).value = sliderRangeInput.values[sliderRangeInput.currentIndex];
        }
        Mixxx.Config.controlRateRange = sliderRangeInput.values[sliderRangeInput.currentIndex];
        Mixxx.Config.bpmSyncLockAlgorithm = syncModeInput.options.indexOf(syncModeInput.selected);
        for (let i = 0; i < deckRateDirection.count; i++) {
            deckRateDirection.objectAt(i).value = sliderOrientationInput.selected === "down" ? -1 : 1;
        }
        Mixxx.Config.controlRateDir = sliderOrientationInput.selected === "down" ? -1 : 1;
        Mixxx.Config.controlKeylockMode = keylockModeInput.options.indexOf(keylockModeInput.selected);
        Mixxx.Config.controlKeyunlockMode = keyunlockModeInput.options.indexOf(keyunlockModeInput.selected);
        Mixxx.Config.controlPitchBendBehaviour = pitchBendBehaviourInput.options.indexOf(pitchBendBehaviourInput.selected);
        Mixxx.Config.controlRateTempCoarse = adjustmentButtonsTemporaryCoarseInput.value / 100;
        Mixxx.Config.controlRateTempFine = adjustmentButtonsTemporaryFineInput.value / 100;
        Mixxx.Config.controlRatePermCoarse = adjustmentButtonsPermanentCoarseInput.value / 100;
        Mixxx.Config.controlRatePermFine = adjustmentButtonsPermanentFineInput.value / 100;
        Mixxx.Config.controlRateRampSensitivity = rampingSensitivityInput.value;
        loadDeck();
    }

    function saveInterface() {
        Mixxx.Config.libraryTooltips = tooltipsInput.options.indexOf(tooltipsInput.selected);
        Mixxx.Config.libraryInhibitScreensaver = disableScreensaverInput.options.indexOf(disableScreensaverInput.selected);
        Mixxx.Config.configStartInFullscreenKey = startFullscreenInput.selected === "on";
        Mixxx.Config.libraryHideMenuBar = autoHideMenuBarInput.selected === "on";
        Mixxx.Config.libraryEnableSearchCompletions = searchCompletionInput.selected === "on";
        Mixxx.Config.libraryEnableSearchHistoryShortcuts = searchHistoryKeyboardInput.selected === "on";
        Mixxx.Config.libraryBpmColumnPrecision = bpmPrecisionInput.value;
        Mixxx.Config.libraryRowHeight = libraryRowHeightInput.value;
        Mixxx.Config.configTrackColorPalette = trackPaletteComboBox.model[trackPaletteComboBox.currentIndex];
        Mixxx.Config.configHotcueColorPalette = hotcuePaletteComboBox.model[hotcuePaletteComboBox.currentIndex];
        Mixxx.Config.configKeyColorsEnabled = keyPaletteInput.selected === "on";
        Mixxx.Config.configKeyColorPalette = keyPaletteComboBox.model[keyPaletteComboBox.currentIndex];
        Mixxx.Config.controlHotcueDefaultColorIndex = hotcuePaletteInput.currentIndex;
        Mixxx.Config.controlLoopDefaultColorIndex = loopPaletteInput.currentIndex;
        loadInterface();
    }

    label: "Interface"
    selectedIndex: 0
    tabs: ["Apariencia & Colores", "Decks & Reproducción"]

    Component.onCompleted: {
        root.load();
    }

    Mixxx.ControlProxy {
        id: numDecks
        group: "[App]"
        key: "num_decks"
    }

    Instantiator {
        id: deckRateRange
        model: numDecks.value
        Mixxx.ControlProxy {
            required property int index
            group: `[Channel${index + 1}]`
            key: "rateRange"
        }
    }

    Instantiator {
        id: deckRateDirection
        model: numDecks.value
        Mixxx.ControlProxy {
            required property int index
            group: `[Channel${index + 1}]`
            key: "rate_dir"
        }
    }

    // MAIN CONTENT CONTAINER
    Item {
        anchors.bottom: buttonActions.top
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        // ================= TAB 0: APARIENCIA & COLORES =================
        Item {
            id: themeColorTab
            property bool dirty: false
            anchors.fill: parent
            visible: root.selectedIndex === 0

            ScrollView {
                id: themeScrollView
                anchors.fill: parent
                clip: true
                contentWidth: availableWidth

                ColumnLayout {
                    width: themeScrollView.availableWidth
                    spacing: 12

                    // CARD 1: APARIENCIA GENERAL
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: card1Col.implicitHeight + 20
                        color: "#181b24"
                        radius: 8
                        border.color: "#282d3b"
                        border.width: 1

                        ColumnLayout {
                            id: card1Col
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: "🎨 APARIENCIA & PANTALLA"
                                font.bold: true
                                font.pixelSize: 13
                                color: "#00e5ff"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Skin / Piel visual"; color: Theme.white; font.pixelSize: 13 }
                                Skin.ComboBox {
                                    id: skinInput
                                    Layout.preferredWidth: 180
                                    model: ["Unnamed"]
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Color del tema"; color: Theme.white; font.pixelSize: 13 }
                                Skin.ComboBox {
                                    id: colorInput
                                    Layout.preferredWidth: 180
                                    model: ["Dark", "Light"]
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Disposición / Layout"; color: Theme.white; font.pixelSize: 13 }
                                Skin.ComboBox {
                                    id: layoutInput
                                    Layout.preferredWidth: 180
                                    model: ["Performance", "Broadcast"]
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Consejos / Tooltips"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: tooltipsInput
                                    options: ["off", "library", "all"]
                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Mantener pantalla encendida (Salvapantallas)"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: disableScreensaverInput
                                    options: ["no", "while running", "while playing"]
                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Iniciar en pantalla completa"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: startFullscreenInput
                                    options: ["on", "off"]
                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Auto-ocultar barra superior"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: autoHideMenuBarInput
                                    options: ["on", "off"]
                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }
                        }
                    }

                    // CARD 2: BIBLIOTECA & COLECCIÓN
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: card2Col.implicitHeight + 20
                        color: "#181b24"
                        radius: 8
                        border.color: "#282d3b"
                        border.width: 1

                        ColumnLayout {
                            id: card2Col
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: "📁 BIBLIOTECA & COLECCIÓN"
                                font.bold: true
                                font.pixelSize: 13
                                color: "#80d8ff"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Autocompletar búsquedas"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: searchCompletionInput
                                    options: ["on", "off"]
                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Historial de búsquedas"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: searchHistoryKeyboardInput
                                    options: ["on", "off"]
                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Decimales en columna BPM"; color: Theme.white; font.pixelSize: 13 }
                                SettingComponents.SpinBox {
                                    id: bpmPrecisionInput
                                    Layout.preferredWidth: 140
                                    editable: false
                                    max: 4
                                    min: 0
                                    precision: 0
                                    realValue: 1
                                    onValueChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Altura de fila en canciones"; color: Theme.white; font.pixelSize: 13 }
                                SettingComponents.Slider {
                                    id: libraryRowHeightInput
                                    Layout.preferredWidth: 200
                                    markers: [24, 30, 38, 50]
                                    max: 60
                                    min: 24
                                    suffix: "px"
                                    value: 38
                                    onValueChanged: themeColorTab.dirty = true
                                }
                            }
                        }
                    }

                    // CARD 3: PALETAS DE COLOR
                    Rectangle {
                        id: colorPane
                        readonly property var defaultPalette: Mixxx.Config.getHotcueColorPalette(hotcuePaletteComboBox.currentText)
                        property int hotcuePaletteColorIndex: 0
                        property int jumpPaletteColorIndex: 0
                        property int loopPaletteColorIndex: 0

                        Layout.fillWidth: true
                        implicitHeight: card3Col.implicitHeight + 20
                        color: "#181b24"
                        radius: 8
                        border.color: "#282d3b"
                        border.width: 1

                        ColumnLayout {
                            id: card3Col
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: "🌈 PALETAS DE COLOR"
                                font.bold: true
                                font.pixelSize: 13
                                color: "#ea80fc"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Paleta de pistas"; color: Theme.white; font.pixelSize: 13 }
                                ColorPaletteComboBox {
                                    id: trackPaletteComboBox
                                    Layout.preferredWidth: 220
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Paleta de Hotcues"; color: Theme.white; font.pixelSize: 13 }
                                ColorPaletteComboBox {
                                    id: hotcuePaletteComboBox
                                    Layout.preferredWidth: 220
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Color predeterminado Hotcue"; color: Theme.white; font.pixelSize: 13 }
                                DefaultColorSelector {
                                    id: hotcuePaletteInput
                                    Layout.preferredWidth: colorPane.defaultPalette.length * 18
                                    currentIndex: colorPane.hotcuePaletteColorIndex
                                    palette: colorPane.defaultPalette
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Color predeterminado Loops"; color: Theme.white; font.pixelSize: 13 }
                                DefaultColorSelector {
                                    id: loopPaletteInput
                                    Layout.preferredWidth: colorPane.defaultPalette.length * 18
                                    currentIndex: colorPane.loopPaletteColorIndex
                                    palette: colorPane.defaultPalette
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Color predeterminado Saltos / Beatjump"; color: Theme.white; font.pixelSize: 13 }
                                DefaultColorSelector {
                                    id: jumpPaletteInput
                                    Layout.preferredWidth: colorPane.defaultPalette.length * 18
                                    currentIndex: colorPane.jumpPaletteColorIndex
                                    palette: colorPane.defaultPalette
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Colores según tonalidad (Key)"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: keyPaletteInput
                                    options: ["on", "off"]
                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                visible: keyPaletteInput.selected === "on"
                                Text { Layout.fillWidth: true; text: "Paleta de tonos (Key Palette)"; color: Theme.white; font.pixelSize: 13 }
                                ColorPaletteComboBox {
                                    id: keyPaletteComboBox
                                    Layout.preferredWidth: 220
                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }
                        }
                    }
                }
            }
        }

        // ================= TAB 1: DECKS & REPRODUCCIÓN =================
        Item {
            id: decksTab
            property bool dirty: false
            anchors.fill: parent
            visible: root.selectedIndex === 1

            ScrollView {
                id: decksScrollView
                anchors.fill: parent
                clip: true
                contentWidth: availableWidth

                ColumnLayout {
                    width: decksScrollView.availableWidth
                    spacing: 12

                    // CARD 1: CUE & COMPORTAMIENTO DE CARGA
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: deckCard1Col.implicitHeight + 20
                        color: "#181b24"
                        radius: 8
                        border.color: "#282d3b"
                        border.width: 1

                        ColumnLayout {
                            id: deckCard1Col
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: "🎛️ MODOS CUE & COMPORTAMIENTO DE CARGA"
                                font.bold: true
                                font.pixelSize: 13
                                color: "#00e5ff"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Modo CUE"; color: Theme.white; font.pixelSize: 13 }
                                Skin.ComboBox {
                                    id: cueModeInput
                                    Layout.preferredWidth: 190
                                    model: ["Mixxx", "Mixxx (sin parpadeo)", "Pioneer", "Denon", "Numark", "CUP"]
                                    onCurrentIndexChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Punto de inicio al cargar pista"; color: Theme.white; font.pixelSize: 13 }
                                Skin.ComboBox {
                                    id: trackLoadPointInput
                                    Layout.preferredWidth: 190
                                    model: ["CUE principal", "Inicio de la pista", "Primer sonido audible", "Inicio de intro", "Primer Hotcue"]
                                    onCurrentIndexChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Asignar inicio de intro al CUE principal"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: setIntroStartToMainCueInput
                                    options: ["on", "off"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Cargar pista en plato reproduciendo"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: loadingTrackWhenPlayingInput
                                    options: ["reject", "allow", "when stopped"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Doble toque en CARGAR para clonar plato"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: doublePressLoadToCloneInput
                                    options: ["on", "off"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                        }
                    }

                    // CARD 2: FORMATO DE TIEMPO
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: deckCard2Col.implicitHeight + 20
                        color: "#181b24"
                        radius: 8
                        border.color: "#282d3b"
                        border.width: 1

                        ColumnLayout {
                            id: deckCard2Col
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: "⏱️ FORMATO DE TIEMPO & VISUALIZACIÓN"
                                font.bold: true
                                font.pixelSize: 13
                                color: "#80d8ff"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Formato de tiempo"; color: Theme.white; font.pixelSize: 13 }
                                Skin.ComboBox {
                                    id: timeMode
                                    Layout.preferredWidth: 200
                                    model: [
                                        DeckComponents.TrackTime.Mode.Traditional,
                                        DeckComponents.TrackTime.Mode.TraditionalCoarse,
                                        DeckComponents.TrackTime.Mode.Seconds,
                                        DeckComponents.TrackTime.Mode.SecondsLong,
                                        DeckComponents.TrackTime.Mode.KiloSeconds,
                                        DeckComponents.TrackTime.Mode.HectoSeconds
                                    ]
                                    contentItem: Content {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 20
                                        mode: timeMode.model[timeMode.currentIndex]
                                    }
                                    onCurrentIndexChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Visualización de tiempo en pantalla"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: trackTimeDisplayInput
                                    options: ["elapsed", "remaining", "both"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                        }
                    }

                    // CARD 3: PITCH, SINCRONIZACIÓN & KEYLOCK
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: deckCard3Col.implicitHeight + 20
                        color: "#181b24"
                        radius: 8
                        border.color: "#282d3b"
                        border.width: 1

                        ColumnLayout {
                            id: deckCard3Col
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: "🎚️ PITCH, VELOCIDAD & SINCRONIZACIÓN"
                                font.bold: true
                                font.pixelSize: 13
                                color: "#ffb74d"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Rango del control de Pitch"; color: Theme.white; font.pixelSize: 13 }
                                Skin.ComboBox {
                                    id: sliderRangeInput
                                    readonly property list<int> values: [4, 6, 8, 10, 16, 24, 50, 90]
                                    Layout.preferredWidth: 200
                                    model: ["4%", "6% (semitono)", "8% (Technics)", "10%", "16%", "24%", "50%", "90%"]
                                    onCurrentIndexChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Orientación del fader de pitch"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: sliderOrientationInput
                                    options: ["down", "up"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Algoritmo de sincronización BPM"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: syncModeInput
                                    options: ["follow soft leader", "use steady"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Restablecer velocidad al cargar pista"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: resetOnTrackLoadInput
                                    options: ["none", "key", "both", "tempo"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Modo Keylock (Tono musical)"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: keylockModeInput
                                    options: ["original key", "current key"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Desactivar Keylock"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: keyunlockModeInput
                                    options: ["reset key", "keep key"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Comportamiento de Pitch Bend"; color: Theme.white; font.pixelSize: 13 }
                                RatioChoice {
                                    id: pitchBendBehaviourInput
                                    options: ["abrupt jump", "smooth ramping"]
                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Sensibilidad de rampa de velocidad"; color: Theme.white; font.pixelSize: 13 }
                                SettingComponents.Slider {
                                    id: rampingSensitivityInput
                                    Layout.preferredWidth: 200
                                    max: 2500
                                    min: 100
                                    value: 250
                                    wheelStep: 50
                                    onValueChanged: decksTab.dirty = true
                                }
                            }
                        }
                    }

                    // CARD 4: BOTONES DE AJUSTE TEMPORAL Y PERMANENTE
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: deckCard4Col.implicitHeight + 20
                        color: "#181b24"
                        radius: 8
                        border.color: "#282d3b"
                        border.width: 1

                        ColumnLayout {
                            id: deckCard4Col
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: "⚡ PASOS DE BOTONES DE VELOCIDAD / PITCH BEND"
                                font.bold: true
                                font.pixelSize: 13
                                color: "#b0bec5"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Temporal Fino (%)"; color: Theme.white; font.pixelSize: 13 }
                                SettingComponents.SpinBox {
                                    id: adjustmentButtonsTemporaryFineInput
                                    Layout.preferredWidth: 140
                                    max: 10
                                    min: 0.01
                                    precision: 2
                                    realValue: 2
                                    suffix: "%"
                                    onValueChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Temporal Grueso (%)"; color: Theme.white; font.pixelSize: 13 }
                                SettingComponents.SpinBox {
                                    id: adjustmentButtonsTemporaryCoarseInput
                                    Layout.preferredWidth: 140
                                    max: 10
                                    min: 0.01
                                    precision: 2
                                    realValue: 4
                                    suffix: "%"
                                    onValueChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Permanente Fino (%)"; color: Theme.white; font.pixelSize: 13 }
                                SettingComponents.SpinBox {
                                    id: adjustmentButtonsPermanentFineInput
                                    Layout.preferredWidth: 140
                                    max: 10
                                    min: 0.01
                                    precision: 2
                                    realValue: 0.05
                                    suffix: "%"
                                    onValueChanged: decksTab.dirty = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { Layout.fillWidth: true; text: "Permanente Grueso (%)"; color: Theme.white; font.pixelSize: 13 }
                                SettingComponents.SpinBox {
                                    id: adjustmentButtonsPermanentCoarseInput
                                    Layout.preferredWidth: 140
                                    max: 10
                                    min: 0.01
                                    precision: 2
                                    realValue: 0.5
                                    suffix: "%"
                                    onValueChanged: decksTab.dirty = true
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
        id: buttonActions
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 58
        color: "#181b24"
        border.color: "#282d3c"
        border.width: 1
        radius: 8

        readonly property bool hasChanges: (root.selectedIndex === 0 && themeColorTab.dirty) || (root.selectedIndex === 1 && decksTab.dirty)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // Status indicator pill
            Rectangle {
                Layout.preferredHeight: 34
                Layout.preferredWidth: statusRow.implicitWidth + 24
                radius: 17
                color: buttonActions.hasChanges ? "#332200" : "#0d2b1a"
                border.color: buttonActions.hasChanges ? "#ffb300" : "#00c853"
                border.width: 1

                RowLayout {
                    id: statusRow
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: buttonActions.hasChanges ? "●" : "✓"
                        font.bold: true
                        font.pixelSize: 13
                        color: buttonActions.hasChanges ? "#ffb300" : "#00e676"
                    }
                    Text {
                        text: buttonActions.hasChanges ? qsTr("Cambios pendientes") : qsTr("Interfaz configurada")
                        font.bold: true
                        font.pixelSize: 12
                        color: buttonActions.hasChanges ? "#ffe082" : "#b9f6ca"
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
                        switch (root.selectedIndex) {
                        case 0:
                            root.resetInterface();
                            break;
                        case 1:
                            root.resetDeck();
                            break;
                        }
                    }
                }
            }

            // Botón Descartar
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 110
                radius: 6
                visible: buttonActions.hasChanges
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
                        errorMessage.text = "";
                        switch (root.selectedIndex) {
                        case 0:
                            root.loadInterface();
                            break;
                        case 1:
                            root.loadDeck();
                            break;
                        }
                    }
                }
            }

            // Botón Guardar Interfaz
            Rectangle {
                Layout.preferredHeight: 40
                Layout.preferredWidth: 220
                radius: 6
                color: buttonActions.hasChanges
                       ? (saveMouse.pressed ? "#009624" : (saveMouse.containsMouse ? "#00e676" : "#00c853"))
                       : (saveMouse.pressed ? "#0d47a1" : (saveMouse.containsMouse ? "#1e88e5" : "#1976d2"))
                border.color: buttonActions.hasChanges ? "#69f0ae" : "#64b5f6"
                border.width: 1.5

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: buttonActions.hasChanges ? "💾" : "✓"
                        font.pixelSize: 14
                        color: "#ffffff"
                    }

                    Text {
                        text: buttonActions.hasChanges ? qsTr("Guardar Interfaz") : qsTr("Guardado")
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
                        switch (root.selectedIndex) {
                        case 0:
                            root.saveInterface();
                            break;
                        case 1:
                            root.saveDeck();
                            break;
                        }
                    }
                }
            }
        }
    }

    component Content: RowLayout {
        required property var mode

        Text {
            Layout.fillWidth: true
            color: Theme.deckTextColor
            elide: Text.ElideRight
            text: {
                switch (parent.mode) {
                case DeckComponents.TrackTime.Mode.TraditionalCoarse:
                    return "Traditional (Coarse)";
                case DeckComponents.TrackTime.Mode.Seconds:
                    return "Seconds";
                case DeckComponents.TrackTime.Mode.SecondsLong:
                    return "Seconds (Long)";
                case DeckComponents.TrackTime.Mode.KiloSeconds:
                    return "Kiloseconds";
                case DeckComponents.TrackTime.Mode.HectoSeconds:
                    return "Hectoseconds";
                default:
                case DeckComponents.TrackTime.Mode.Traditional:
                    return "Traditional";
                }
            }
            verticalAlignment: Text.AlignVCenter
        }
        DeckComponents.TrackTime {
            Layout.rightMargin: 17
            display: trackTimeDisplayInput.selected === "elapsed" ? DeckComponents.TrackTime.Display.Elapsed : trackTimeDisplayInput.selected === "remaining" ? DeckComponents.TrackTime.Display.Remaining : DeckComponents.TrackTime.Display.Both
            elapsed: 83.45
            mode: parent.mode
            remaining: 147.23
        }
    }
}
