# Modificaciones de la variante RX3

## 0.13.0 — estados de reproducción y correcciones visuales

- MASTER exclusivo, con traspaso al deck que continúa sonando, sin modificar transporte ni sincronización. Contador BARS y recuadro BPM siguen el mismo estado.
- Insignia MASTER negra sobre naranja junto a BPM, en un espacio reservado; no tapa BPM ni desplaza el valor.
- QUANTIZE y 1 aparecen y desaparecen juntos mediante color, manteniendo todas las alturas del carril de metadatos.
- Overview: porción reproducida oscurecida y línea de posición blanca opaca.
- Loop conectado a beatloop_size y visible solo con loop_enabled; lectura de fracciones 1/2 a 1/128.
- ZOOM/GRID y STATUS/BEAT FX recolocados con separación y alturas que evitan recortar los botones.

## 0.12.0 — revisión visual a 1280 × 800

- Lienzo fijo 16:10 con escalado nativo proporcional de widgets, fuentes y tramo visible de waveform, también al maximizar.
- Geometría de BEAT FX/STATUS recalibrada: tarjetas inferiores de 210 px, franja de 80 px, laterales de waveform de 180 px y panel de efectos de 184 px.
- HOT CUE usa celdas grises de 18 px y un pequeño distintivo central; conserva las acciones nativas en toda la celda.
- Tiempo con tres decimales pequeños, decimal de BPM reducido, REMAIN superior hh:mm:ss, compases desde la grilla y milisegundos de un beat.
- Se conservan las conexiones del controlador y los ocho PAD MODE. No se cambian mappings ni presets de efectos.
- Nueva extensión nativa optativa: `ReferenceSize`, `Rx3Format` y `Rx3Badge`. Fuentes, parche 0004 e instrucciones de reconstrucción conservados.

## Historial anterior

- Manifest renombrado y limitado a dos decks.
- Topbar reconstruida como la pantalla PERFORMANCE de la RX3: REMAIN, rail de progreso, reloj/estado e INFO; la navegación de vistas queda en los botones físicos del controlador.
- Overview reconstruido como dos waveforms apiladas, panel Beat FX, X-PAD y dos tarjetas inferiores.
- Panel lateral reconstruido como lectura permanente de Beat FX, selector del efecto, destino MASTER, BPM, quantize y zoom.
- El selector `STATUS / BEAT FX` conmuta la franja horizontal bajo los waveforms, como en la RX3, sin reemplazar el panel lateral.
- STATUS tiene ocho pads visibles por deck y cambia dinámicamente entre HOT CUE, BEAT LOOP, SLIP LOOP, BEAT JUMP, GATE CUE, BEAT LOOP 2, RELEASE FX y BEAT JUMP 2.
- Tira Beat FX conectada a los tres slots de Effect Unit 1, activación de unidad y X-PAD nativo de 1/16 a 4 beats, incluyendo 3/4.
- Controles de stems específicos del controlador original retirados del waveform.
- `ModeConfigKey` no oficial reemplazado por `NumberPos` y controles globales oficiales.
- Estilos QSS añadidos para reproducir la jerarquía, contraste y paleta de la pantalla XDJ-RX3.
- Script de instalación para la ruta sandbox de Mixxx en macOS.
- Preview reemplazado por la referencia XDJ-RX3 entregada para el proyecto; el preview original puede recuperarse del commit Git `7f73982` como `archive/skin-legacy/XDJ_RX3_Mixxx/skin_preview_upstream.png`.
- Arquitectura contrastada con BiteDJ/DeckShark 1.0, basado en Mixxx 2.5.6.
- `SHIFT + ASSISTANT` alterna STATUS / BEAT FX desde el Hercules Inpulse 500; el mapping publica además el PAD MODE activo de cada deck para sincronizar la pantalla.
- Mapping RX3 de ocho capas de pads con segundo toque: `1↔5`, `2↔6`, `3↔7`, `4↔8`.
- Paletas del controlador corregidas: Hot Cues vacíos blancos, Beat Loop naranja, Slicer azul/blanco, Beat Jump rojo-naranja y FX blanco.
- Indicadores TEMPO del Hercules desacoplados del BPM entre decks: las flechas y el centro blanco siguen únicamente la posición física del pitch.
- Fondo opaco añadido al `TabStack` para evitar superficies sin pintar durante cambios de vista.
- Decks limitados realmente a Channel 1/2; eliminadas las instancias ocultas de Channel 3/4.
- Claves de manifest actualizadas de `[Master]` y grupos heredados a `[App]` y `[Skin]`.
- Propiedad de pista corregida de `track_number` a `trackNumber`; `Elide=scroll` cambiado por `right`.
- Controles `sync_master` migrados a `sync_leader`.
- Marcas de loop duplicadas y propiedades QSS inexistentes eliminadas.
- Capa estática `0:00.00` añadida para decks descargados, evitando datos de tiempo obsoletos tras eject.
- Política adaptable aplicada a las tarjetas de deck y controles de waveform protegidos contra seek accidental.
- Etiquetas `Signal3Band*` exclusivas del fork retiradas; solo se conservan propiedades soportadas por Mixxx oficial.
- BROWSE adaptado a la jerarquía RX3: árbol de fuentes, tabla central, LOAD 1/2 externos y dos decks compactos inferiores. Las columnas de portada/preview siguen dependiendo de la configuración del `WTrackTableView` nativo de Mixxx.
- Geometría PERFORMANCE 0.3.0 recalibrada contra la referencia: rail izquierdo estrecho, waveforms apilados, panel Beat FX de 164 px, strip de 76 px y decks inferiores de 190 px.
- Tarjetas inferiores rehechas con cabecera de ancho completo y fila AUTO CUE / tiempo / tempo / BPM sobre un overview continuo, igual que la XDJ-RX3.
- STATUS / HOT CUE queda seleccionado por defecto; BEAT FX sigue disponible desde el tab lateral y desde `SHIFT + ASSISTANT`.
- `LibraryBreadcrumb` no soportado por el parser legacy de Mixxx 2.5 sustituido por una etiqueta estable para que BROWSE cargue completo.
- Sidebar de BROWSE ampliado de 176 a 300 px, sangría del árbol reducida a 12 px y scrollbar horizontal visible para rutas muy profundas.
- PAD MODE 4 corregido a Beat Jump `±1/±2/±4/±8`; PAD MODE 8 corregido a Beat Jump 2 `±1/2, ±2, ±4, ±16`, incluyendo desplazamiento nativo del loop activo.
- `SHIFT + jog wheel` implementa búsqueda rápida bidireccional de aproximadamente 12 segundos por vuelta sin activar scratch.
- Strip STATUS ampliado a 84 px y separación vertical de 4 px añadida entre ambas filas de pads para evitar el recorte inferior.
- Versión 0.5.0: strip STATUS ampliado finalmente a 96 px, con 8 px de margen inferior exclusivo para HOT CUE y 4 px entre filas.
- Acabado PERFORMANCE aplanado sobre negro puro: retirados bordes de contenedores, tarjetas y paneles; se conservan únicamente separadores y contornos funcionales presentes en el hardware.
- Rótulos y números `DECK 1` / `DECK 2` unificados en blanco; añadidos además a las cajas laterales de metadatos de cada waveform.
- Instalador macOS opcional para una copia reversible **Mixxx RX3 (sin AU)**. En Mixxx 2.5.6 ARM64 evita sólo la construcción del backend Audio Unit durante el arranque, sin modificar la aplicación oficial ni afectar los plugins del sistema.
- Versión 0.6.0: paleta sólida muestreada de la referencia Pioneer. `#202020` pinta título de pista, topbar, USB y panel Beat FX; `#181818` pinta badges DECK y metadatos; `#787C78` identifica selecciones; `#F84418` marca TEMPO/quantize y paréntesis; `#F97220` queda reservado al BPM MASTER.
- El BPM y su contorno reaccionan ahora a `sync_leader`: naranja en MASTER, blanco en el deck restante. Los badges inferiores recuperan los paréntesis naranjas de la pantalla RX3 manteniendo el número blanco.
- Versión 0.7.0: la grilla deja de atravesar la forma de onda. Cada golpe se dibuja con dos ticks cortos `#787C78`, uno arriba y otro abajo, y cada cuarto golpe usa rojo `#ff0000`, anclado al primer downbeat del beatgrid.
- El renderizador RX3 añade las propiedades de skin `DownbeatColor` y `BeatTickLength` tanto al backend AllShader como al backend QPainter; la geometría queda configurable desde `waveform.xml`.
- Versión 0.8.0: BROWSE elimina la columna LOAD lateral y dedica todo el ancho restante a la tabla, como la pantalla RX3.
- Los decks compactos inferiores pasan a una geometría fija tiempo/overview/BPM: el overview recibe el ancho flexible, conserva la paleta azul-naranja-blanco y el BPM queda en una caja funcional al extremo derecho.
- La barra superior usa ahora un medidor real enlazado a `playposition`; el relleno avanza con la pista. En BROWSE el icono y el tiempo REMAIN se trasladan al bloque derecho.
- El botón BROWSER consume completamente el clic que abre la vista, reinicia controles momentáneos de Library y filtra el segundo flanco emitido por algunas revisiones de firmware para no activar el árbol de carpetas.
- La salida de auriculares del Inpulse 500 se valida sobre el segundo par físico (canales 3–4) y una frecuencia común con la interfaz principal.
- Versión 0.9.0: FX1–FX4 del Hercules dejan de cambiar entre Channel 1–4. Ahora seleccionan `REVERB`, `PING PONG`, `NOISE` y `FILTER` sobre los QuickEffect de Channel 1/2; una segunda pulsación apaga el efecto y el LED activo parpadea como en la XDJ-RX3.
- Los knobs FILTER/FX funcionan como COLOR independiente por deck: centro neutro para los cuatro efectos, magnitud simétrica para REVERB/PING PONG/NOISE y barrido LPF/HPF bipolar para FILTER.
- Versión 0.10.0: el campo BUSCAR deja de ocupar permanentemente la cabecera BROWSE. Una lupa compacta lo despliega bajo demanda, transfiere el foco al buscador nativo y vuelve a plegarlo al pulsarla de nuevo.
- AUTOLOOP del Hercules corregido en ambos decks: cada paso del encoder emite un pulso completo para reducir/ampliar `beatloop_size`, ignora el valor neutro MIDI `0x40` y la pulsación usa `beatloop_activate` para crear un loop nuevo en la línea de beatgrid más cercana o desactivarlo. El ajuste momentáneo de quantize conserva el estado elegido por el usuario; `SHIFT + AUTOLOOP` mantiene el loop fijo de 4 beats.
- Ajuste manual Pioneer añadido a LOOP IN/OUT: con el loop activo, cada botón alterna su modo `IN ADJUST`/`OUT ADJUST` y el jog escribe directamente `loop_start_position` o `loop_end_position`, sin snap ni QUANTIZE. Los límites impiden cruzar extremos o superar la pista; repetir el botón sale y el botón opuesto cambia el punto editado.
- Paquete macOS 0.11.0: la firma de **Mixxx RX3** incorpora acceso a volúmenes extraíbles para detectar automáticamente pendrives Rekordbox. El parche de fuentes añade compatibilidad `PIONEER/.PIONEER` y un selector con bookmark persistente como respaldo del sandbox.
- Paquete macOS 0.11.1: corrige el bloqueo TCC que permitía detectar `export.pdb` pero impedía leerlo. Al abrir Rekordbox se autoriza una sola vez la raíz del USB mediante el selector nativo; el bookmark se conserva y una importación fallida vuelve a quedar disponible para reintento.
- Instalador Windows autocontenido añadido: si Mixxx no existe, descarga la versión oficial 2.5.6, comprueba su SHA-256 y firma digital y la instala. Después respalda completa la carpeta de settings fuera de la ruta activa, instala la skin, el mapping Hercules y las cuatro cadenas Sound Color FX, reordena `effects.xml` sin eliminar presets existentes, aplica el perfil portable RX3 actual y activa automáticamente la skin y el controlador en `mixxx.cfg`.

## 0.14.0 — BROWSER, BEAT GRID y VINYL

BROWSER corto actúa al soltar. Mantener tres segundos activa GRID y muestra la pantalla de waveforms. Un toque corto sale de GRID al soltar sin abrir BROWSE. El giro de cada jog desplaza únicamente la grilla del deck asociado, con acumulación de cuatro ticks por paso nativo. GRID tiene prioridad sobre scratch, pitch bend, búsqueda con SHIFT y ajuste de loops. Press+turn cancela la pulsación larga.

ZOOM pasa a gris y el contorno celeste resalta GRID mientras está activo. VINYL guarda y consulta el mismo índice de deck; al apagarlo libera cualquier scratch activo. No requiere recompilar Mixxx.
