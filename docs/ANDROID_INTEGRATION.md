<!-- Inicio del texto generado autónomamente por un agente de IA. -->

# Integración Android en newverrsion

Fuente: JaviLabarumDJ/mixxx-android, rama android-stable,
commit 74bb3ac93405dfacb3aa631677f55090ab301195, v1.6.1.
Se importan los módulos de producto C++, Java, QML, CMake, mapeos DDJ-400/FLX4,
lectura USB/Rekordbox/Engine DJ, backups, stems y renderizado de waveform.
La rama main de Javi contiene el README de esas versiones, pero no su código.

Se conservan los scripts de compilación, políticas, firma y release.json de
este fork. La identidad de la APK es org.mixxx, con versión y código locales.
El CMake utiliza release.json para esos metadatos. No se publica una release,
commit, push ni PR como parte de esta integración.

Pioneered se registra en res/qml/Skins/Pioneered y es el valor predeterminado
de MobileApp. Classic, Booth y Lite siguen disponibles. El empaquetado aplica
los overrides +android; los archivos desktop de Javi permanecen independientes.
Los componentes visuales Pioneered están en res/qml/Pioneered.
La copia regenerable de QML se guarda en la caché privada de la app;
no se borra ni sustituye /sdcard/Mixxx/qml de instalaciones anteriores.

Las actualizaciones automáticas quedan desactivadas por defecto y el origen
apunta a Noisk8, para no sustituir este fork por una APK de Javi. La mezcla,
la biblioteca local y las controladoras no requieren red. Streaming, descarga
de modelos de stems y búsqueda de actualizaciones son funciones opcionales.

La compilación requiere patchelf para la compatibilidad Android 10–13 y
descarga ONNX Runtime al configurar stems por primera vez. Los modelos de
separación no se incluyen en la APK; mezclar no depende de instalarlos.

Pruebas físicas pendientes de un DJ: audio sostenido, Main/cue por canales
1–2/3–4, USB hot-plug, Bluetooth MIDI y retorno de llamadas/segundo plano.
No se consideran verificadas solo porque compile o arranque la aplicación.

## Validación del 4 de noviembre de 2026

APK arm64 0.8.2 (Bleeding Gums Murphy), código 18: compilación, firma y
metadatos verificados con tools/android_release.py. Instalada por ADB con
resultado Success en el modelo 25080RABDG, Android 16. Comprobados Pioneered,
la vista de ambos decks, navegación Browse y salida Oboe inicializada a
48 kHz; los renderizadores de ambos decks se inicializan sin error QML.
Esto no confirma reproducción audible ni mezcla Main/cue con una controladora.

El primer inicio requirió reiniciar Mixxx después de conceder los permisos.
Se observó always_finish_activities=1 (No conservar actividades) en el móvil
y bloqueo en QtActivityBase.onDestroy al pasar al permiso de almacenamiento.
No se cambió esa opción global. Tras reiniciar y actualizar el layout, se
comprobó la interfaz en el dispositivo. El retorno de otras actividades con
esa opción de desarrollador sigue pendiente de corregir o validar.

Se corrigió el enlace explícito con mixxx_libccompat para API 29 y se
excluyó androidTest del source set de producción. Los tests antiguos se
conservan, pero no se han actualizado ni ejecutado como tests instrumentados.

<!-- Fin del texto generado autónomamente por un agente de IA. -->
