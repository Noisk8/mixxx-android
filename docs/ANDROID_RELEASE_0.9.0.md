<!-- Inicio del texto generado autónomamente por un agente de IA. -->

# Publicación Android 0.9.0 — Otto Mann

Estado: preparación local en newverrsion. No se ha creado commit, push,
merge, tag ni release remota. No publicar todavía como estable.

## Archivos de entrega

- APK: Mixxx-Android-v0.9.0-Otto-Mann.apk
- Checksum: Mixxx-Android-v0.9.0-Otto-Mann.apk.sha256
- Notas: packaging/android/releases/0.9.0.md
- Changelog: CHANGELOG.md
- Evidencia por completar: packaging/android/qa/0.9.0-otto-mann.json

El APK local se construyó con cambios sin commit. Revisar todos los archivos
antes de preparar el commit; no añadir buildenv, claves, android_env.sh,
credenciales ni cachés. Hay cambios del usuario previos a esta preparación,
incluido src/audio/signalinfo.cpp, que no se deben incorporar sin revisión.

## Antes de llevarlo a main

1. Revisar la integración completa y las atribuciones/licencias.
2. Corregir o resolver el fallo conocido de cierre/segundo plano.
3. Hacer pruebas reales con controladora y audio, no solo arranque.
4. Ejecutar también los checks Android y comprobar escritorio.
5. Revisar el changelog y eliminar el estado pendiente solo con evidencia.
6. El humano prepara el commit y sube newverrsion; revisa y lleva los cambios
   a main siguiendo las reglas de protección de la rama.
7. Construir el APK del commit final: cualquier cambio requiere nuevo checksum
   y nuevas pruebas sobre ese binario.

## Publicar mediante el workflow existente

El workflow .github/workflows/build.yml produce android-release-arm64 cuando
la firma de Noisk8 está configurada. Una compilación local no aparece por sí
sola en GitHub Releases.

1. Construir la revisión final de main en Actions con firma configurada.
2. Descargar android-release-arm64 y probar ESE APK en hardware.
3. Completar el JSON QA con el SHA-256 de ese APK, tester, dispositivo,
   controladora, fecha y evidencia. Se exigen todos los casos en pass,
   al menos 7200 segundos continuos y 20 ciclos de reconexión USB.
4. El humano registra el JSON de QA. El workflow permite que entre el build
   y el tag solo cambien archivos en packaging/android/qa/.
5. El humano crea y sube el tag android-v0.9.0 sobre esa revisión de main.
6. Lanzar manualmente android-release.yml sobre el tag con build_run_id de
   esa compilación y qa_path=packaging/android/qa/0.9.0-otto-mann.json.
7. El workflow verifica versión, firma, checksum, revisión y QA, y crea un
   borrador con APK, checksum, QA y notas completas de la versión.
8. El humano revisa el borrador y decide su publicación.

No saltarse el gate ni rellenar pruebas no realizadas. No reutilizar el QA
de otro APK. El binario local solo es candidato para validación.

<!-- Fin del texto generado autónomamente por un agente de IA. -->
