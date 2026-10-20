
# Justificación técnica de MANAGE_EXTERNAL_STORAGE y Plan de Almacenamiento

## 1. Justificación de MANAGE_EXTERNAL_STORAGE en Mixxx para Android

Mixxx es una estación de trabajo de audio digital (DAW) y software para DJs profesionales que opera en modo **completamente standalone y sin conexión de red**. El uso del permiso `MANAGE_EXTERNAL_STORAGE` (`All files access`) es estrictamente indispensable por las siguientes razones técnicas de ingeniería de audio de bajo nivel:

### A. Acceso POSIX directo para decodificadores C++ de baja latencia
El motor de audio de Mixxx (`EngineWorkerScheduler`, `SoundSourceProvider`, `AudioSource`) delega la lectura y decodificación de audio a bibliotecas nativas C/C++ de alto rendimiento:
- `libavformat` / `libavcodec` (FFmpeg)
- `libflac`
- `libvorbis` / `libogg`
- `libsndfile`
- `libmad`

Estos motores dependen de llamadas directas al sistema POSIX (`open()`, `mmap()`, `lseek()`, `pread()`) para realizar lecturas no bloqueantes y búsquedas con precisión de muestra de audio (*sample-accurate seeking*) en tiempo real. 

### B. Incompatibilidad del Storage Access Framework (SAF) con audio profesional en tiempo real
Android SAF canaliza las operaciones a través de URIs (`content://`) gestionadas por ContentProviders y llamadas IPC mediante Binder a través de la máquina virtual ART.
1. **Sobrecarga de latencia**: Cada lectura de buffer a través de SAF introduce cambios de contexto en modo usuario/kernel e interprocesos que rompen los presupuestos temporales de audio de ~5 ms necesarios para scratching y timecode DVS.
2. **Imposibilidad de mmap**: Las APIs de decodificación y mapeo de forma de onda (waveforms) no pueden mapear descriptores de archivo virtuales fragmentados expuestos por SAF sin copiar archivos enteros a la memoria interna, lo que provocaría fallos por falta de memoria (OOM) en colecciones de decenas de gigabytes.

### C. Almacenamiento externo USB (memorias OTG y tarjetas SD)
Los DJs transportan su música en memorias USB y unidades SSD externas formateadas en exFAT o FAT32 organizadas por carpetas. Para escanear, indexar y reproducir colecciones directamente desde pendrives USB sin duplicar los archivos en el almacenamiento interno del teléfono, se requiere acceso directo al sistema de archivos del punto de montaje `/storage/XXXX-XXXX/`.

### D. Escritura de etiquetas ID3 y metadatos sin duplicación
Mixxx calcula y guarda metadatos críticos directamente en los archivos de audio (o en archivos auxiliares de beatgrids, cues y waveforms):
- Clave musical y detección armónica (Camelot/OpenKey).
- Beatgrids con marcadores de tempo dinámico.
- Puntos de Hotcue y loops guardados.
- Puntuación y etiquetas ID3.
MediaStore solo expone campos limitados de metadatos de audio estándar y no admite atributos avanzados de DJing.

---

## 2. Plan a futuro: Integración híbrida con MediaStore y SAF

Para las funciones que no comprometan el rendimiento del hilo de audio en tiempo real, se establece el siguiente plan de migración por capas:

| Caso de uso | Enfoque actual | Enfoque futuro |
|---|---|---|
| **Biblioteca de música DJ (carpetas / USB)** | Acceso POSIX vía `MANAGE_EXTERNAL_STORAGE` | Mantener `MANAGE_EXTERNAL_STORAGE` como requisito para DJing profesional con colecciones externas. |
| **Importación de tracks individuales** | Explorador de archivos nativo | Selector de archivos del sistema mediante SAF (`ACTION_OPEN_DOCUMENT`) con copia a directorio privado de Mixxx. |
| **Grabaciones de sesiones DJ** | `/storage/emulated/0/Music/Mixxx/Recordings` | `MediaStore.Audio.Media` para que las sesiones grabadas aparezcan de inmediato en reproductores del sistema. |
| **Exportación de playlists (M3U8)** | Escritura directa a disco | `MediaStore.Downloads` o SAF para guardado de archivos de listas de reproducción. |

