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

        var currentSkin = Mixxx.Config.configSkin || "Classic";
        var skinIdx = skinInput.model.indexOf(currentSkin);
        skinInput.currentIndex = skinIdx >= 0 ? skinIdx : 0;

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
        if (skinInput.currentIndex >= 0 && skinInput.currentIndex < skinInput.model.length) {
            Mixxx.Config.configSkin = skinInput.model[skinInput.currentIndex];
        }
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
                    spacing: 12
                    width: themeScrollView.availableWidth

                    // CARD 1: APARIENCIA GENERAL
                    Rectangle {
                        Layout.fillWidth: true
                        border.color: "#282d3b"
                        border.width: 1
                        color: "#181b24"
                        implicitHeight: card1Col.implicitHeight + 20
                        radius: 8

                        ColumnLayout {
                            id: card1Col

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                color: "#00e5ff"
                                font.bold: true
                                font.pixelSize: 13
                                text: "🎨 APARIENCIA & PANTALLA"
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: qsTr("Skin / Piel visual")
                                }
                                Skin.ComboBox {
                                    id: skinInput

                                    Layout.preferredWidth: 180
                                    model: ["Classic", "Booth", "Pioneered"]

                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Color del tema"
                                }
                                Skin.ComboBox {
                                    id: colorInput

                                    Layout.preferredWidth: 180
                                    model: ["Dark", "Light"]

                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Disposición / Layout"
                                }
                                Skin.ComboBox {
                                    id: layoutInput

                                    Layout.preferredWidth: 180
                                    model: ["Performance", "Broadcast"]

                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Consejos / Tooltips"
                                }
                                RatioChoice {
                                    id: tooltipsInput

                                    options: ["off", "library", "all"]

                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Mantener pantalla encendida (Salvapantallas)"
                                }
                                RatioChoice {
                                    id: disableScreensaverInput

                                    options: ["no", "while running", "while playing"]

                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Iniciar en pantalla completa"
                                }
                                RatioChoice {
                                    id: startFullscreenInput

                                    options: ["on", "off"]

                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Auto-ocultar barra superior"
                                }
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
                        border.color: "#282d3b"
                        border.width: 1
                        color: "#181b24"
                        implicitHeight: card2Col.implicitHeight + 20
                        radius: 8

                        ColumnLayout {
                            id: card2Col

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                color: "#80d8ff"
                                font.bold: true
                                font.pixelSize: 13
                                text: "📁 BIBLIOTECA & COLECCIÓN"
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Autocompletar búsquedas"
                                }
                                RatioChoice {
                                    id: searchCompletionInput

                                    options: ["on", "off"]

                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Historial de búsquedas"
                                }
                                RatioChoice {
                                    id: searchHistoryKeyboardInput

                                    options: ["on", "off"]

                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Decimales en columna BPM"
                                }
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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Altura de fila en canciones"
                                }
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
                        border.color: "#282d3b"
                        border.width: 1
                        color: "#181b24"
                        implicitHeight: card3Col.implicitHeight + 20
                        radius: 8

                        ColumnLayout {
                            id: card3Col

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                color: "#ea80fc"
                                font.bold: true
                                font.pixelSize: 13
                                text: "🌈 PALETAS DE COLOR"
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Paleta de pistas"
                                }
                                ColorPaletteComboBox {
                                    id: trackPaletteComboBox

                                    Layout.preferredWidth: 220

                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Paleta de Hotcues"
                                }
                                ColorPaletteComboBox {
                                    id: hotcuePaletteComboBox

                                    Layout.preferredWidth: 220

                                    onCurrentIndexChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Color predeterminado Hotcue"
                                }
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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Color predeterminado Loops"
                                }
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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Color predeterminado Saltos / Beatjump"
                                }
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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Colores según tonalidad (Key)"
                                }
                                RatioChoice {
                                    id: keyPaletteInput

                                    options: ["on", "off"]

                                    onSelectedChanged: themeColorTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                visible: keyPaletteInput.selected === "on"

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Paleta de tonos (Key Palette)"
                                }
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
                    spacing: 12
                    width: decksScrollView.availableWidth

                    // CARD 1: CUE & COMPORTAMIENTO DE CARGA
                    Rectangle {
                        Layout.fillWidth: true
                        border.color: "#282d3b"
                        border.width: 1
                        color: "#181b24"
                        implicitHeight: deckCard1Col.implicitHeight + 20
                        radius: 8

                        ColumnLayout {
                            id: deckCard1Col

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                color: "#00e5ff"
                                font.bold: true
                                font.pixelSize: 13
                                text: "🎛️ MODOS CUE & COMPORTAMIENTO DE CARGA"
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Modo CUE"
                                }
                                Skin.ComboBox {
                                    id: cueModeInput

                                    Layout.preferredWidth: 190
                                    model: ["Mixxx", "Mixxx (sin parpadeo)", "Pioneer", "Denon", "Numark", "CUP"]

                                    onCurrentIndexChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Punto de inicio al cargar pista"
                                }
                                Skin.ComboBox {
                                    id: trackLoadPointInput

                                    Layout.preferredWidth: 190
                                    model: ["CUE principal", "Inicio de la pista", "Primer sonido audible", "Inicio de intro", "Primer Hotcue"]

                                    onCurrentIndexChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Asignar inicio de intro al CUE principal"
                                }
                                RatioChoice {
                                    id: setIntroStartToMainCueInput

                                    options: ["on", "off"]

                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Cargar pista en plato reproduciendo"
                                }
                                RatioChoice {
                                    id: loadingTrackWhenPlayingInput

                                    options: ["reject", "allow", "when stopped"]

                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Doble toque en CARGAR para clonar plato"
                                }
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
                        border.color: "#282d3b"
                        border.width: 1
                        color: "#181b24"
                        implicitHeight: deckCard2Col.implicitHeight + 20
                        radius: 8

                        ColumnLayout {
                            id: deckCard2Col

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                color: "#80d8ff"
                                font.bold: true
                                font.pixelSize: 13
                                text: "⏱️ FORMATO DE TIEMPO & VISUALIZACIÓN"
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Formato de tiempo"
                                }
                                Skin.ComboBox {
                                    id: timeMode

                                    Layout.preferredWidth: 200
                                    model: [DeckComponents.TrackTime.Mode.Traditional, DeckComponents.TrackTime.Mode.TraditionalCoarse, DeckComponents.TrackTime.Mode.Seconds, DeckComponents.TrackTime.Mode.SecondsLong, DeckComponents.TrackTime.Mode.KiloSeconds, DeckComponents.TrackTime.Mode.HectoSeconds]

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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Visualización de tiempo en pantalla"
                                }
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
                        border.color: "#282d3b"
                        border.width: 1
                        color: "#181b24"
                        implicitHeight: deckCard3Col.implicitHeight + 20
                        radius: 8

                        ColumnLayout {
                            id: deckCard3Col

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                color: "#ffb74d"
                                font.bold: true
                                font.pixelSize: 13
                                text: "🎚️ PITCH, VELOCIDAD & SINCRONIZACIÓN"
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Rango del control de Pitch"
                                }
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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Orientación del fader de pitch"
                                }
                                RatioChoice {
                                    id: sliderOrientationInput

                                    options: ["down", "up"]

                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Algoritmo de sincronización BPM"
                                }
                                RatioChoice {
                                    id: syncModeInput

                                    options: ["follow soft leader", "use steady"]

                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Restablecer velocidad al cargar pista"
                                }
                                RatioChoice {
                                    id: resetOnTrackLoadInput

                                    options: ["none", "key", "both", "tempo"]

                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Modo Keylock (Tono musical)"
                                }
                                RatioChoice {
                                    id: keylockModeInput

                                    options: ["original key", "current key"]

                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Desactivar Keylock"
                                }
                                RatioChoice {
                                    id: keyunlockModeInput

                                    options: ["reset key", "keep key"]

                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Comportamiento de Pitch Bend"
                                }
                                RatioChoice {
                                    id: pitchBendBehaviourInput

                                    options: ["abrupt jump", "smooth ramping"]

                                    onSelectedChanged: decksTab.dirty = true
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Sensibilidad de rampa de velocidad"
                                }
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
                        border.color: "#282d3b"
                        border.width: 1
                        color: "#181b24"
                        implicitHeight: deckCard4Col.implicitHeight + 20
                        radius: 8

                        ColumnLayout {
                            id: deckCard4Col

                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                color: "#b0bec5"
                                font.bold: true
                                font.pixelSize: 13
                                text: "⚡ PASOS DE BOTONES DE VELOCIDAD / PITCH BEND"
                            }
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Temporal Fino (%)"
                                }
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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Temporal Grueso (%)"
                                }
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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Permanente Fino (%)"
                                }
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

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.white
                                    font.pixelSize: 13
                                    text: "Permanente Grueso (%)"
                                }
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

        readonly property bool hasChanges: (root.selectedIndex === 0 && themeColorTab.dirty) || (root.selectedIndex === 1 && decksTab.dirty)

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        border.color: "#282d3c"
        border.width: 1
        color: "#181b24"
        height: 58
        radius: 8

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // Status indicator pill
            Rectangle {
                Layout.preferredHeight: 34
                Layout.preferredWidth: statusRow.implicitWidth + 24
                border.color: buttonActions.hasChanges ? "#ffb300" : "#00c853"
                border.width: 1
                color: buttonActions.hasChanges ? "#332200" : "#0d2b1a"
                radius: 17

                RowLayout {
                    id: statusRow

                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        color: buttonActions.hasChanges ? "#ffb300" : "#00e676"
                        font.bold: true
                        font.pixelSize: 13
                        text: buttonActions.hasChanges ? "●" : "✓"
                    }
                    Text {
                        color: buttonActions.hasChanges ? "#ffe082" : "#b9f6ca"
                        font.bold: true
                        font.pixelSize: 12
                        text: buttonActions.hasChanges ? qsTr("Cambios pendientes") : qsTr("Interfaz configurada")
                    }
                }
            }

            // Error message if any
            Text {
                id: errorMessage

                Layout.alignment: Qt.AlignVCenter
                color: "#ff5252"
                font.pixelSize: 12
                text: ""
                visible: text.length > 0
            }
            Item {
                Layout.fillWidth: true
            }

            // Botón Restablecer
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: 140
                border.color: "#772b2b"
                border.width: 1
                color: resetMouse.pressed ? "#5c2b2b" : (resetMouse.containsMouse ? "#4a2222" : "#371e1e")
                radius: 6

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        color: "#ff8a80"
                        font.pixelSize: 14
                        text: "↺"
                    }
                    Text {
                        color: "#ffcdd2"
                        font.bold: true
                        font.pixelSize: 12
                        text: qsTr("Restablecer")
                    }
                }
                MouseArea {
                    id: resetMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

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
                border.color: "#555555"
                border.width: 1
                color: discardMouse.pressed ? "#424242" : (discardMouse.containsMouse ? "#333333" : "#262626")
                radius: 6
                visible: buttonActions.hasChanges

                Text {
                    anchors.centerIn: parent
                    color: "#e0e0e0"
                    font.bold: true
                    font.pixelSize: 13
                    text: qsTr("Descartar")
                }
                MouseArea {
                    id: discardMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

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
                border.color: buttonActions.hasChanges ? "#69f0ae" : "#64b5f6"
                border.width: 1.5
                color: buttonActions.hasChanges ? (saveMouse.pressed ? "#009624" : (saveMouse.containsMouse ? "#00e676" : "#00c853")) : (saveMouse.pressed ? "#0d47a1" : (saveMouse.containsMouse ? "#1e88e5" : "#1976d2"))
                radius: 6

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        color: "#ffffff"
                        font.pixelSize: 14
                        text: buttonActions.hasChanges ? "💾" : "✓"
                    }
                    Text {
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                        text: buttonActions.hasChanges ? qsTr("Guardar Interfaz") : qsTr("Guardado")
                    }
                }
                MouseArea {
                    id: saveMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

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
