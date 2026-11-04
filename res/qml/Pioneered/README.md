<!-- Inicio del texto generado autónomamente por un agente de IA. -->

# Pioneered para Android

Adaptación QML del diseño de Pioneered de timewasternl, GorgiAstro,
BvOBart y bencejuhaasz. Referencia y avisos originales:
`res/skins/Pioneered/README.md` y `res/skins/Pioneered/LICENSE` (GPL-3.0).
Los SVG de keylock y quantize proceden de ese skin. Esta adaptación se
distribuye bajo GPL-3.0. El archivo LICENSE del repositorio declara Mixxx
GPL-2.0 o posterior. Se conservan intactos el skin XML y sus avisos.
El aviso de `res/skins/Pioneered/icons/ReadMe.md` indica que los iconos
proceden principalmente del skin Deere incluido con Mixxx.

## Integración

Android utiliza esta interfaz de forma predeterminada. Ajustes → Interface →
Skin permite alternar Pioneered, Classic, Booth y Lite. La base Android
procede de JaviLabarumDJ, rama android-stable, revisión 74bb3ac934 (v1.6.1).
La preferencia persistente es `[Config],AndroidSkin` mediante MobileApp;
el selector provisional AndroidQmlSkin se ha eliminado. No se cambia
`ResizableSkin`, que continúa seleccionando el skin XML de escritorio.
El Loader sustituye únicamente la vista; PlayerManager conserva los decks.
Se mantienen cuatro decks y dieciséis samplers del perfil QML existente,
aunque la pantalla principal presenta dos decks.

Overview recupera las dos waveforms apiladas del original, BeatFX lateral,
dos tiras inferiores con artista/título, transporte, BPM, tonalidad,
tiempo transcurrido/restante, duración total y vista completa del track.
Overview fija explícitamente la geometría de waveforms, BeatFX y decks,
sin depender de tamaños implícitos de los renderizadores.
Keylock y escucha previa se encuentran junto a cada waveform.
Browse reutiliza BoothBrowse y la biblioteca de Javi; LOAD selecciona el destino.
Samples controla los dieciséis samplers con botones táctiles y LOAD.
BeatFX presenta tres unidades con tres slots cada una, selección,
activación, asignación y mezcla dry/wet.
DJ reutiliza los pads, jogs, loops y controles de stems de Booth.
Se conservan los controles `[Skin],mobile_*` de los mapeos de controladora,
la grabación con confirmación y la cola de stems de la base Android.
Los medidores de slot de la pestaña BeatFX muestran `meta`, igual que el
Pioneered XML; no son medidores de señal de audio.

Los faders reutilizan la base QML con sus pointer handlers, para admitir
gestos independientes. No se añaden temporizadores de repintado ni polling.
Overview se ajusta a la altura disponible sin desplazamiento vertical;
la mezcla táctil completa permanece en DJ. La barra superior conserva
visibles las pestañas y los ajustes. El arranque muestra Pioneered, no la
marca del autor de la base; su atribución se conserva en los créditos.

## Verificación en dispositivo pendiente

- Instalar el APK arm64 con `adb install -r` y arrancar sin controladora.
- Cargar música local en A y B, reproducir y alternar skins desde Interface;
  comprobar posición, tracks y audio sin interrupción, también tras reiniciar.
- Probar play/cue/sync, keylock/quantize, pitch, loops, beatjump, EQ y crossfader.
- Usar dos dedos sobre faders y decks; comprobar que no roba el gesto el scroll.
- Probar los tres FX, asignaciones A/B/Main, meta y mezcla dry/wet.
- Probar Browse, LOAD de cada deck y los dieciséis samplers.
- Revisar traducción española, teléfono/tablet, notch y orientación horizontal.
- Conectar DDJ-400/FLX4 antes del arranque y en caliente, aceptar/rechazar
  permisos, comprobar Main 1–2 y cue 3–4, SPLIT y CUE/MAIN.
- Grabar, apagar pantalla, recibir una llamada, volver del segundo plano y salir.

## Límites

Los controles internos de la biblioteca y de ajustes
conservan sus tamaños y su comportamiento existentes: no se garantiza
48 dp en esos componentes. Falta comprobar el layout de 480×420 físicamente.
No se reproduce cada opción del skin XML; Classic, Booth y Lite se conservan.
La selección de skin de escritorio y la QML Android son independientes.

## Comprobaciones locales

La revisión visual se realiza en el teléfono Android conectado. En una
salida de la aplicación se observó SIGABRT en hwuiTask0 después de
«Mixxx shutdown complete with code 0», con mutex destruido. El ciclo de
segundo plano/cierre no está validado y necesita diagnóstico independiente.

Los componentes nuevos se comprueban con qmlformat y qmllint sobre una copia
con los overrides +android aplicados. La prueba física requiere distinguir
arranque, reproducción y audio Main/cue con controladora; el arranque por sí
solo no valida el audio ni el hot-plug USB.

<!-- Fin del texto generado autónomamente por un agente de IA. -->
