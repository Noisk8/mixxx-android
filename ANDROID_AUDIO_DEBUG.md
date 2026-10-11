> Este documento fue generado autónomamente por un agente de IA.

# Depuración del volumen con DDJ-400

El usuario confirmó que subir el volumen multimedia del celular corrige el nivel
bajo. Al asignar auriculares a los canales 3–4 de la DDJ-400, el usuario escucha
la misma señal que sale por RCA, en lugar de una preescucha independiente.
En una prueba posterior confirmó que MIXING hacia MASTER permite escuchar el
master, pero hacia CUE no escucha la pista que prepara. Esto confirma que los
auriculares pueden reproducir el master; no confirma el transporte de la señal
USB 3–4, pues MASTER CUE puede mezclar la salida principal en hardware.
La captura del 11 de octubre de 2026 confirmó `pfl=1`, reproducción activa,
fader en cero y señal de entrada en el canal preparado. La pantalla también
mostró Main en 1–2 y Headphones en 3–4 del mismo dispositivo DDJ-400.
La salida pasa por las ganancias de Mixxx,
PortAudio/Oboe, el volumen multimedia de Android y el control físico de la DDJ-400.

Se corrigió la inicialización del foco de audio: antes se creaba únicamente en
la interfaz QML, por lo que la interfaz clásica no lo solicitaba. Ahora se crea
en los servicios comunes y se destruye antes de los reproductores. Android recibe
la indicación de pausar ante una petición temporal de atenuación; Mixxx pausa los
decks y requiere que el DJ reanude manualmente. También pausa si Android rechaza
la solicitud de foco. Los botones de volumen del móvil controlan STREAM_MUSIC.

En modo `--developer`, cada cinco segundos mientras un deck reproduce se registran:

- Ganancia principal, medidor principal, clipping, ganancia y mezcla de auriculares,
  balance, procesamiento de auriculares habilitado (`headEnabled`), mezcla separada
  por oído (`headSplit`), ganancia previa, fader, reproducción y CUE/PFL de los decks
  que reproducen o tienen PFL activado.
- Volumen multimedia, mute, dispositivos de salida disponibles, canales y frecuencias.
- Curva de volumen USB en dB; es la curva de Android para el tipo de dispositivo,
  no una medida de la señal analógica ni prueba de la ruta activa.

Los APK anteriores consultaban las ganancias, mezcla y habilitación en `[Main]`,
pero esta versión crea esos controles en `[Master]`. Por eso los ceros de
`mainGain`, `headGain`, `headMix` y `headEnabled` de la primera captura no son
medidas válidas. El medidor principal sí tenía un alias en `[Main]` y los
valores de los decks eran válidos. Se corrigió la consulta a `[Master]` y un
control ausente ahora se registra como `missing`.

Al abrir un stream, `MixxxAudioRoutes` registra el dispositivo, número de canales
solicitados, frecuencia efectiva y asignaciones de Main/Headphones. Un stream
solicitado con cuatro canales no demuestra que Android esté entregando cuatro
canales físicos independientes: esa parte se contrasta con `media.audio_flinger`
y `media.audio_policy` durante la conexión USB.

Las mediciones se hacen en el hilo principal, fuera del callback de audio. No se
modifican automáticamente las ganancias ni el volumen multimedia. El seguimiento
de foco conserva el alcance previo: los decks existentes al iniciar; la reproducción
exclusiva de samplers o preescucha de biblioteca aún requiere ampliar ese seguimiento.

## Prueba física

El APK de esta iteración se guarda como `Mixxx-Android-arm64-audio-debug.apk`.
Se instala con `adb install -r Mixxx-Android-arm64-audio-debug.apk` cuando el
teléfono esté autorizado y accesible por ADB. Conserva la versión Android 0.7-beta.

La iteración con registros de preescucha y rutas se guarda aparte como
`Mixxx-Android-arm64-cue-debug.apk`, también con versión Android 0.7-beta.

La corrección de apertura multicanal, con consulta de ganancias corregida,
se guarda como `Mixxx-Android-arm64-cue-multichannel.apk`. Instalar con
`adb install --no-incremental -r Mixxx-Android-arm64-cue-multichannel.apk`
evita la instalación incremental que falló en este teléfono. Conserva 0.7-beta.

1. Conecta la DDJ-400 antes de abrir Mixxx. Configura Android Oboe, Main en 1–2
   y Headphones en 3–4 del mismo dispositivo.
2. Usa una pista conocida, EQ y filtro centrados, fader del canal arriba y
   crossfader centrado. Comprueba la ganancia principal en pantalla: el MASTER
   físico de la DDJ-400 no la modifica.
3. Empieza con MASTER físico bajo. Sube gradualmente el volumen multimedia del
   teléfono y el MASTER físico, observando si desaparece la caída de nivel.
   Compara RCA y auriculares e indica dónde ocurre el problema.
4. Reproduce unos 20 segundos en el momento del fallo. Si tienes ADB por Wi-Fi,
   captura con la DDJ-400 conectada; esa captura conserva la ruta USB activa.
5. Ejecuta `bash tools/android_audio_diagnostics.sh`. También puedes indicar
   `ADB=/usr/lib/android-sdk/platform-tools/adb` y `ANDROID_SERIAL` si hace falta.
   Si debes reconectar el teléfono al PC, captura enseguida: logcat puede conservar
   los registros de la prueba, pero dumpsys ya refleja la ruta posterior a desconectar.

Un medidor principal normal con volumen USB muy atenuado orienta hacia Android
o el hardware. Un medidor principal bajo orienta hacia ganancias, faders,
efectos o la pista en Mixxx. Si el nivel es correcto pero hay cortes, revisa
latencia y underruns en los registros. Las capturas por sí solas no verifican
el nivel analógico de las salidas RCA.

## Aislar el fallo de CUE en canales 3–4

1. Conserva Main en 1–2 y Headphones en 3–4 del mismo dispositivo DDJ-400.
   Usa 44100 Hz y aplica la configuración para registrar el nuevo stream.
2. Carga pistas distintas en A y B. Reproduce B con su fader abajo y activa
   el botón CUE de auriculares de B, situado en la sección del mezclador;
   el CUE de transporte junto a PLAY tiene otra función.
3. Prueba activar PFL desde Mixxx además del botón físico. Pioneered no expone
   esos controles en sus XML; para esta comparación puedes usar temporalmente
   una skin con controles de auriculares, como Deere.
4. Pon el Headphone Mix de Mixxx hacia CUE/PFL, desactiva Head Split y sube
   gradualmente la ganancia de auriculares. Con PFL puro, B debe oírse en los
   auriculares aunque su fader esté abajo y no debe salir por RCA.
5. Comprueba `headEnabled=1`, `headSplit=0`, `headMix=-1`, `headGain>0` y `pfl=1`
   en B. Reproduce al menos diez segundos y captura los registros.

El colector también guarda `dumpsys midi` y el tag `MixxxMidi` para comprobar
si el puerto MIDI de entrada al software está abierto. Si se captura después
de reconectar al PC, ese dumpsys ya no describe la conexión DDJ-400 de la prueba;
los registros conservados en logcat son los que permiten revisar esa conexión.

Si PFL funciona en pantalla y no desde la DDJ-400, investiga MIDI/mapeo.
Si PFL está activo, las ganancias y mezcla son correctas, pero 3–4 permanecen
sin sonido, investiga la ruta USB/Android. Si se oye B por RCA con su fader abajo,
hay que comprobar que Android no esté mezclando las cuatro salidas en estéreo.

La perilla HEADPHONES MIXING emite MIDI 0xB6, CC 0x0C/0x2C según Pioneer.
El [mapeo oficial 2.5](https://raw.githubusercontent.com/mixxxdj/mixxx/2.5/res/controllers/Pioneer-DDJ-400.midi.xml)
lo conecta a `headMix`; la rama actual y el snapshot local omiten esa conexión
bajo la suposición de mezcla en hardware. Esta diferencia requiere contrastar
la prueba física; no se ha cambiado el mapeo basándose únicamente en ella.

## Corrección preparada para Oboe multicanal

La DDJ-400 anuncia canales `[2, 4]` y únicamente 44100 Hz. El historial de
AudioFlinger sitúa la sesión Mixxx 17953, solicitada con cuatro canales a
48000 Hz, en el mezclador AudioOut_1D, que tiene dos canales. Android cambió
su destino a USB durante la conexión. Los mezcladores USB de cuatro canales
del historial no muestran pistas de Mixxx ni escrituras. Esto apunta a una
reducción a estéreo en la ruta de Android; aún requiere confirmar el resultado
con otra prueba física y las ganancias corregidas.

Se mantiene PortAudio/Oboe y se cambia solo la apertura de salidas de más de
dos canales a `PerformanceMode::None` y `SharingMode::Shared`, para evitar la
selección de la ruta rápida estéreo. Para una única tarjeta Oboe configurada
con salidas que alcanzan canales superiores a 2, si la configuración pide
48000 Hz pero el dispositivo declara 44100 Hz como frecuencia predeterminada,
SoundManager selecciona 44100 Hz antes de abrir los streams. Así el motor y
el dispositivo comparten frecuencia. Los dispositivos que declaran 48000 Hz,
las salidas estéreo y configuraciones de varias tarjetas conservan su selección.

Esta apertura puede aumentar la latencia. La prueba debe comprobar separación
de RCA/CUE, funcionamiento de MIXING, cortes y respuesta de controles. No se
ha modificado el mapeo de MIXING ni se ha validado físicamente la corrección.

Hay [antecedentes de fallos multicanal en Oboe](https://github.com/google/oboe/issues/943)
en otros teléfonos; la decisión aquí se apoya en la captura de este teléfono.

Referencias: [DDJ-400 en Mixxx](https://manual.mixxx.org/2.5/en/hardware/controllers/pioneer_ddj_400.html),
[volumen en Android](https://developer.android.com/media/platform/output),
[foco de audio en Android](https://developer.android.com/media/optimize/audio-focus).

[Tabla MIDI de Pioneer DDJ-400](https://www.pioneerdj.com/-/media/pioneerdj/software-info/controller/ddj-400/ddj-400_midi_message_list_e1.pdf).

> Fin del documento generado autónomamente por un agente de IA.
