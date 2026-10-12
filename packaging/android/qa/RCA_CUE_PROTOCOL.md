> Documento generado autónomamente por un agente de IA. Requiere revisión humana antes de uso.

# Protocolo de prueba física: separación RCA / CUE (DDJ-400)

Objetivo: comprobar que, con la DDJ-400 conectada por USB, la salida principal
llega sólo a RCA (canales 1–2) y la preescucha llega sólo a auriculares
(canales 3–4), sin mezcla entre ambas rutas.

Esta prueba la realiza una persona con el teléfono y la controladora reales.
Los resultados se anotan en un JSON derivado de `qa-template.json`, que
`tools/android_release.py gate` valida antes de cualquier release.

## Material

- Teléfono con la APK a probar (versión y `versionCode` anotados).
- DDJ-400 y cable USB-OTG; altavoces o amplificador en RCA 1–2 y auriculares en 3–4.
- Dos pistas distintas e identificables. Recomendado: generar en el PC dos tonos
  distintos, por ejemplo `A_1kHz.wav` (1 kHz) y `B_400Hz.wav` (400 Hz), y
  cargarlos en Mixxx como pista A y pista B. Así se distingue por oído qué deck suena.
- Opcional, para medición objetiva: interfaz de audio o osciloscopio conectado
  a RCA y a la salida de auriculares, o dos oídos por separado con volumen moderado.
- ADB autorizado, para `tools/android_rca_cue_capture.sh`.

## Configuración previa

1. Conecta la DDJ-400 **antes** de abrir Mixxx.
2. En preferencias de sonido: API Android Oboe, dispositivo DDJ-400,
   Main en canales 1–2 y Headphones en canales 3–4 del **mismo** dispositivo.
3. Frecuencia 44100 Hz (la que anuncia la DDJ-400). Anota la frecuencia que muestra el log.
4. Volumen multimedia del teléfono al máximo, MASTER físico de la DDJ-400 a la mitad,
   EQ y filtro centrados, crossfader centrado.
5. Anota en la hoja de resultados la versión de la APK y el número de serie del teléfono.

## Escenarios

Para cada escenario, pulsa la acción, espera 10 segundos y anota lo que oyes en
cada salida. Captura el log con `tools/android_rca_cue_capture.sh` **antes de
desconectar** el teléfono.

| ID | Estado de Mixxx / DDJ-400 | Esperado en RCA 1–2 | Esperado en auriculares 3–4 |
|---|---|---|---|
| S1 | Deck A en Play, fader A arriba, deck B parado | Sólo tono A | Mezcla master (A) |
| S2 | Deck B en Play, fader B **abajo**, CUE de B activado (PFL), HEADPHONES MIXING hacia CUE | **Nada de B** (puede sonar A si su fader está arriba) | **Sólo tono B** |
| S3 | Igual que S2 pero PFL activado desde la pantalla de Mixxx, sin pulsar el botón físico | Nada de B | Sólo tono B |
| S4 | A y B en Play, fader A arriba, fader B abajo, CUE de B activado | Sólo tono A | Sólo tono B |
| S5 | A en Play, HEADPHONES MIXING hacia MASTER, CUE de A y B desactivados | Tono A | Tono A (mezcla master) |
| S6 | Pulsar MASTER CUE en la DDJ-400 con A en Play | Documentar: ¿cambia la salida RCA? | Documentar: ¿se oye la mezcla? |

S6 no es aprobatorio por sí solo: sirve para entender el comportamiento de la
controladora. Anota lo que ocurre sin suponerlo.

## Criterio de aprobación

- S2, S3 y S4: el tono de B **no** aparece en RCA y el tono de A **no** aparece
  en auriculares cuando su PFL está apagado. Si cualquiera de estos fallos aparece,
  el caso queda en `fail`.
- S1 y S5: la salida esperada aparece en su canal y la otra no suena de forma
  apreciable.
- La frecuencia registrada en el log es 44100 Hz y el stream tiene `channels=4`.
- Un fallo en S2 con `pfl=1` en Mixxx y señal en RCA apunta a la ruta de Android.
  Un fallo sin `pfl=1` apunta a MIDI o mapeo. Ver `ANDROID_AUDIO_DEBUG.md`.

## Interpretación de la captura

El script guarda `MixxxAudioRoutes` y `MixxxAudioLevels`. Revisa:

- `Mixxx output route`: dispositivo, canales solicitados y asignaciones
  Main/Headphones. Confirma que se pidieron cuatro canales.
- `Android audio deck`: `play` y `pfl` por deck en el momento del fallo.
- `headMix`, `headSplit`, `headEnabled`, `headGain`: confirma el estado de la mezcla de auriculares.
- `media.audio_flinger` y `media.audio_policy` en `dumpsys`: confirma que Android
  asignó el stream USB con cuatro canales y no lo redujo a estéreo.

Un stream con cuatro canales solicitados no demuestra cuatro salidas físicas
independientes. Sólo la prueba auditiva o la medición eléctrica lo demuestra.

## Registro

Copia `packaging/android/qa-template.json` a una ruta nueva en `packaging/android/qa/`
y completa:

- `apk_sha256`, `version_code`, `tester`, `device`, `controller`, `tested_at`, `evidence`
  (ruta a la carpeta de captura).
- `cases.rca_cue`: `pass` sólo si S1–S5 cumplen el criterio. Si no, `fail`.
  Nunca dejes `pending` en una prueba que ya se realizó.
- `duration_seconds` y `usb_reconnect_cycles` se rellenan en otras pruebas del plan.

Una prueba fallida se registra igualmente: anota el escenario, lo que se oyó y la
captura. No se cambia el mapeo ni el enrutado sin esa evidencia.

> Fin del documento generado autónomamente por un agente de IA.
