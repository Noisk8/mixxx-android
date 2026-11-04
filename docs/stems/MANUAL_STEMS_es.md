<!-- START_AI_GENERATED_DISCLAIMER -->
<!-- Este manual lo ha escrito un agente de IA (Claude) a partir del código y de las pruebas en una Lenovo Tab M11. -->

# 🎚 Manual de stems — Mixxx Android

*[English version](STEMS_MANUAL_en.md)*

Los **stems** son las partes de una canción por separado: **batería**, **bajo**, **voz** y **el resto** (sintes, guitarras, pads…). Con ellos puedes quitar la voz para pinchar una instrumental, dejar solo la voz para hacer un acapella en directo, quitar el bajo de un tema mientras entra el del otro, etc.

Mixxx Android separa los stems **en el propio dispositivo**, con inteligencia artificial, sin subir nada a internet. Solo necesitas conexión una vez, para descargar los modelos.

> Inspirado en los stems en directo de **Dani Roman** ([@danigiavanni](https://www.instagram.com/danigiavanni)) y su proyecto [mixxx-stems](https://github.com/dromangdev/mixxx-stems).

---

## Índice

1. [Cómo funciona](#1-cómo-funciona)
2. [Qué necesitas](#2-qué-necesitas)
3. [Primeros pasos: descargar un modelo](#3-primeros-pasos-descargar-un-modelo)
4. [Qué modelo elegir](#4-qué-modelo-elegir)
5. [Separar una pista o una lista](#5-separar-una-pista-o-una-lista)
6. [La cola](#6-la-cola)
7. [Usar los stems en el deck](#7-usar-los-stems-en-el-deck)
8. [Opciones (Ajustes → Stems)](#8-opciones-ajustes--stems)
9. [Dónde se guardan los stems](#9-dónde-se-guardan-los-stems)
10. [Separar mientras pinchas](#10-separar-mientras-pinchas)
11. [Borrar stems y liberar espacio](#11-borrar-stems-y-liberar-espacio)
12. [Problemas y mensajes de error](#12-problemas-y-mensajes-de-error)
13. [Preguntas frecuentes](#13-preguntas-frecuentes)
14. [Créditos y licencias](#14-créditos-y-licencias)

---

## 1. Cómo funciona

1. **Tú eliges** qué pistas separar: una pista o una lista entera (una playlist, un cajón, una playlist de Rekordbox…). Nunca se separa nada por sí solo.
2. La app separa las pistas **de una en una, en segundo plano**, mientras sigues usando Mixxx.
3. El resultado se guarda en un archivo de stems **junto a la pista original**, que no se modifica.
4. Cuando cargas esa pista en un deck, Mixxx usa los stems automáticamente y aparece la pestaña **STEM** en los pads. **Los cues, la rejilla, el BPM y la tonalidad de la pista se conservan.**

Separar es una tarea pesada: lo ideal es **preparar las pistas antes de la sesión**, por ejemplo una playlist entera con la tablet cargando.

---

## 2. Qué necesitas

| | Spleeter + Wiener | HTDemucs |
|---|---|---|
| Descarga (una vez) | 75 MB | 149 MB |
| Memoria RAM libre | ~250 MB | 2–2,5 GB |
| Recomendado | Cualquier móvil o tablet | 6 GB de RAM o más |

- **Android 10 o superior**, ARM 64 bits (como el resto de la app).
- **Espacio** para los archivos de stems: unos **18–36 MB por pista de 5 minutos**, según la opción de tamaño (ver [Opciones](#8-opciones-ajustes--stems)).
- **Conexión a internet** solo para descargar los modelos.

---

## 3. Primeros pasos: descargar un modelo

1. Abre **⚙️ Ajustes → 🎚 Stems**.
2. En **🧠 MODELOS**, pulsa **⬇ 75 MB** en *Spleeter + Wiener* (recomendado para empezar) y/o **⬇ 149 MB** en *HTDemucs*.
3. Espera a que termine. Verás el porcentaje; puedes **CANCELAR** cuando quieras. Si se corta, vuelve a pulsar: continúa con los archivos que falten.
4. Cuando aparece **✓** junto al nombre, el modelo está listo. La app comprueba que los archivos descargados no estén dañados.
5. Pulsa **⏱ MEDIR**: separa 20 segundos de prueba y te dice **cuánto tardará tu dispositivo** en una pista de 5 minutos. Ese tiempo se muestra después al elegir el modelo.

> También puedes descargar un modelo directamente desde la ventana **🎚 STEMS** de la biblioteca, con el botón **⬇ DESCARGAR**.

Para borrar un modelo y recuperar espacio: **BORRAR** junto a él. Los stems ya hechos no se borran.

---

## 4. Qué modelo elegir

| | **Spleeter + Wiener** | **HTDemucs** |
|---|---|---|
| Velocidad (pista de 5 min) | **1–4 min** | **8–30 min** |
| Memoria | ~250 MB | 2–2,5 GB |
| Calidad | Buena. La voz puede sonar algo metálica | **La mejor**: voz y bajo más limpios |
| Bajo | Reforzado con los graves de la pista | Muy bueno |
| Ideal para | Separar sobre la marcha, playlists grandes, móviles | Preparar con calma los temas importantes |

**Tiempos medidos en una Lenovo Tab M11 (6 GB):** Spleeter + Wiener ~58 s (~76 s antes de la v1.6.0) y HTDemucs ~15 min por pista de 5 minutos. Cada dispositivo es distinto: usa **⏱ MEDIR** para saber los del tuyo.

**Consejos:**
- **Techno, house, electrónica:** Spleeter + Wiener suele ser suficiente. Por debajo de ~150 Hz el bajo se queda con todo lo que no es batería, así que el bajo suena continuo y sin cortes.
- **Acapellas y temas con mucha voz o guitarras (rock, pop):** HTDemucs separa mucho mejor la voz de las guitarras.
- **Mucha cantidad de temas:** Spleeter. Una playlist de 30 temas son ~40 min con Spleeter frente a ~7 horas con HTDemucs.

---

## 5. Separar una pista o una lista

1. Ve a la biblioteca (vista **LIB** o la biblioteca bajo los decks).
2. **Una pista:** selecciónala y pulsa **🎚 STEMS** en la barra inferior.
   **Una lista entera:** abre la lista (playlist, cajón, playlist de Rekordbox, historial…) **sin seleccionar ninguna pista** y pulsa **🎚 STEMS**. Si tienes una pista seleccionada, puedes cambiar entre **PISTA SELECCIONADA** y **TODA LA LISTA**.
3. En la ventana:
   - Verás cuántas pistas tiene la lista y cuántas **ya tienen stems** (esas se saltan).
   - Elige el **modelo** tocando su tarjeta (aparece **✓**). Se muestra el tiempo estimado en tu dispositivo.
   - Si hay pistas con stems, puedes elegir **Volver a separar las pistas que ya tienen stems: SÍ / NO**. Útil para rehacerlas con HTDemucs.
   - Si estás pinchando, aparece un **aviso naranja** (ver [Separar mientras pinchas](#10-separar-mientras-pinchas)).
4. Pulsa **🎚 SEPARAR** (o **🎚 SEPARAR N** para una lista). Las pistas pasan a la cola.

El botón de la biblioteca muestra **🎚 STEMS ✓** cuando la pista seleccionada ya tiene stems.

---

## 6. La cola

Mientras haya pistas pendientes, en la **barra superior** aparece un indicador como **🎚 45% · 3** (progreso de la pista actual · pistas pendientes). Tócalo para abrir la cola. También está en **Ajustes → Stems → 📋 COLA**.

En la cola:
- Cada pista muestra su estado: 🕒 en espera, ⏳ separando (con la fase, el % y el **tiempo restante**), ✅ lista, ⚠️ error, ⏹ cancelada.
- **⏸ PAUSAR / ▶ REANUDAR:** detiene la separación sin perder lo hecho de la pista actual. En pausa no consume CPU.
- **CANCELAR TODO:** vacía la cola.
- **×** en una pista: la quita de la cola (si se está separando, se detiene y se borra lo hecho).
- **LIMPIAR TERMINADAS:** quita de la lista las pistas ya hechas o fallidas.

**Más cosas que conviene saber:**
- Al terminar cada pista aparece un aviso abajo: *«Stems listos…»*. **Si esa pista ya estaba cargada en un deck, vuelve a cargarla** para usar los stems.
- **Con la pantalla apagada o cambiando de app** la separación sigue: verás una notificación *«Separando stems — Pista 2 de 5: 40 %»*. La primera vez Android puede pedirte permiso para mostrar notificaciones; acéptalo para ver el progreso.
- **Si cierras la app**, la cola se guarda. Al volver a abrirla aparece **en pausa**: pulsa **▶ REANUDAR** para seguir. Así no arranca sola si Android cerró la app por falta de memoria.

---

## 7. Usar los stems en el deck

Carga una pista con stems en un deck. La forma de onda general se ve con los colores de cada stem.

### Skin Classic

En el panel de pads aparece una tercera pestaña, **STEM**, debajo de **CUE** y **LOOP**. Tócala:

| Acción | Resultado |
|---|---|
| **Toque** en BATERÍA / BAJO / RESTO / VOZ | Silencia ese stem (se ve apagado y tachado). Otro toque lo vuelve a activar |
| **Pulsación larga** en un stem | **Solo**: suena únicamente ese stem. Otra pulsación larga en él vuelve a activar todos |

**Ejemplos:**
- **Instrumental:** toca **VOZ**.
- **Acapella:** mantén pulsada **VOZ**.
- **Cambio de bajos al mezclar:** toca **BAJO** en el tema que entra y, en el momento del cambio, tócalo de nuevo y silencia el bajo del que sale.

### Skin Booth

En la vista **DJ**, toca la barra de modo de los pads (**HOT CUE ⇅**) hasta que ponga **STEMS ⇅** (solo aparece si la pista tiene stems). Los pads pasan a ser cuatro botones, uno por stem, que funcionan como en Classic: **toque** para silenciarlo o volver a activarlo, **pulsación larga** para que suene solo ese (otra pulsación larga vuelve a activar todos).

En **Booth** y **Lite**, el indicador **🎚 %** de la barra superior abre la cola mientras se separan pistas. Lite no tiene controles de stems: la pista suena completa.

### En todas las skins

Todo lo demás funciona igual: keylock, loops, hotcues, scratch, efectos y sincronización. Al cargar otra pista, los stems vuelven a sonar todos (opción estándar de Mixxx).

---

## 8. Opciones (Ajustes → Stems)

| Opción | Botones | Qué hace |
|---|---|---|
| **Modelo** | PREGUNTAR · SPLEETER · HTDEMUCS | El modelo elegido por defecto en la ventana 🎚 STEMS. Con PREGUNTAR se elige el primero que tengas descargado y lo cambias tú |
| **Tamaño de los archivos de stems** | LIGERO ~18 MB · NORMAL ~24 MB · ALTO ~36 MB | Calidad de compresión (AAC a 96, 128 o 192 kbps por stem), por pista de 5 minutos. NORMAL es transparente para pinchar; ALTO, si vas a usar los stems también para producir |
| **Mientras suena un deck** | SEGUIR MÁS LENTO · PAUSAR | Con SEGUIR MÁS LENTO la separación usa la mitad de núcleos mientras suena algún deck. Con PAUSAR, la cola espera a que pares todos los decks |
| **Solo con el cargador** | SÍ · NO | Con SÍ, la cola solo avanza mientras el dispositivo está cargando (útil para HTDemucs) |

---

## 9. Dónde se guardan los stems

**Junto a cada pista**, en una carpeta oculta **`.stems`**:

```
Música/
├── Artista - Tema.mp3
└── .stems/
    └── Artista - Tema.mp3.stem.mp4
```

- El archivo es un **`.stem.mp4`**, el formato de stems de Native Instruments (lo leen también Traktor y otros programas). Lleva la mezcla original y los 4 stems.
- La carpeta es **oculta**, así que **los stems no aparecen duplicados** en tu biblioteca.
- Si **mueves o renombras** la pista, mueve también su archivo de `.stems` (con el mismo nombre más `.stem.mp4`) o vuelve a separarla.
- **Pendrives que Android no monta** (los de Rekordbox formateados sin tabla de particiones, que Mixxx lee por su cuenta en modo solo lectura) y otras carpetas sin permiso de escritura: los stems se guardan **dentro de la app**. Funcionan igual, pero solo en este dispositivo.

---

## 10. Separar mientras pinchas

Separar usa mucha CPU. Mixxx la ejecuta con **prioridad baja** para que el audio y la pantalla vayan primero, pero en dispositivos modestos **puede provocar cortes de audio**. Por eso:

- La ventana 🎚 STEMS te **avisa** si hay algún deck sonando.
- Por defecto, mientras suena un deck se usa **la mitad de la CPU** (más lento).
- Para pinchar sin ningún riesgo, elige **Mientras suena un deck → PAUSAR** en Ajustes → Stems: la cola esperará a que pares.
- Lo más seguro: **prepara tus playlists antes de la sesión**.

---

## 11. Borrar stems y liberar espacio

- **De una pista o una lista:** en la biblioteca, abre **🎚 STEMS** y pulsa **🗑 BORRAR STEMS**. Solo se borran los archivos de stems; las pistas originales no se tocan.
- **Los guardados dentro de la app:** Ajustes → Stems → **💾 ALMACENAMIENTO** muestra cuánto ocupan y los borra con **BORRAR**.
- **Los modelos:** Ajustes → Stems → **BORRAR** junto a cada modelo.

---

## 12. Problemas y mensajes de error

| Mensaje | Qué pasa | Qué hacer |
|---|---|---|
| *Falta el modelo o está dañado* | El modelo no está descargado o un archivo está corrupto | Ajustes → Stems: BORRAR el modelo y descargarlo de nuevo |
| *No hay memoria suficiente* | HTDemucs se detuvo porque Android se quedaba sin memoria | Cierra otras apps, no tengas tantos decks/efectos cargados, o usa Spleeter |
| *No se encuentra el archivo* | La pista se movió o se borró después de añadirla a la cola | Vuelve a añadirla |
| *No se puede leer el audio del archivo* | Formato no soportado, archivo dañado o de menos de 1 segundo | Prueba con otra copia del archivo |
| *Demasiado larga* | Más de 20 minutos (sesiones grabadas, mixes) | Los stems están pensados para temas individuales |
| *No se puede guardar el archivo de stems* | Sin espacio o sin permiso de escritura | Libera espacio; revisa el permiso de acceso a archivos de la app |
| *El motor de IA no se puede cargar* | El dispositivo no es compatible con ONNX Runtime | Coméntalo indicando tu modelo de dispositivo |
| *Falló la descarga* | Sin conexión o la descarga se cortó | Vuelve a pulsar ⬇; continúa donde se quedó |

**Otros casos:**
- **No aparece la pestaña STEM:** la pista no tiene stems, o se cargó antes de terminar. Vuelve a cargarla.
- **La cola no avanza:** mira el motivo en la cola: *En pausa* (pulsa REANUDAR), *Esperando a que paren los decks* o *Esperando al cargador*.
- **Se oyen cortes al separar mientras pinchas:** elige *Mientras suena un deck → PAUSAR*.

---

## 13. Preguntas frecuentes

**¿Se modifica mi archivo original?** No. Los stems van en un archivo aparte.

**¿Necesito internet para separar?** No, solo para descargar los modelos una vez. La separación es 100 % en el dispositivo: tus pistas no se suben a ningún sitio.

**¿Puedo usar los stems en otro programa?** Sí: el `.stem.mp4` es el formato estándar de Native Instruments (Traktor, por ejemplo).

**¿Puedo separar en el móvil?** Sí. Spleeter va bien en casi cualquier móvil. HTDemucs necesita bastante RAM libre (2–2,5 GB).

**¿Por qué no se separa todo automáticamente?** Para no gastar batería, espacio ni CPU en pistas que no vas a usar. Tú eliges qué separar.

**¿Puedo rehacer una pista con el otro modelo?** Sí: 🎚 STEMS → elige el modelo → *Volver a separar las pistas que ya tienen stems: SÍ*.

**¿Y si mezclo pistas con y sin stems?** Sin problema: las pistas sin stems funcionan como siempre.

---

## 14. Créditos y licencias

- **Idea e inspiración:** Dani Roman ([@danigiavanni](https://www.instagram.com/danigiavanni)), [dromangdev/mixxx-stems](https://github.com/dromangdev/mixxx-stems).
- **Spleeter** de Deezer — licencia MIT.
- **HTDemucs** (Demucs v4) de Meta — licencia MIT. Conversión a ONNX de StemSplitio; cuantizado a 8 bits para móviles.
- **ONNX Runtime** de Microsoft — licencia MIT.
- **Mixxx** — licencia GPL v2.

<!-- END_AI_GENERATED_DISCLAIMER -->
