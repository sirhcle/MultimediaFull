# Bitácora de cambios y decisiones

Registro para que cualquier persona o agente de IA sepa qué se ha hecho, por qué y qué falta. Lo más reciente va arriba.

Formato de cada entrada:

```
## AAAA-MM-DD — Título corto
- Herramienta: Cursor / Claude / manual
- Qué cambió: ...
- Por qué: ...
- Archivos: ...
```

---

## Pendientes

- [ ] **Ícono de la app**: `Assets.xcassets/AppIcon.appiconset` existe pero sin imagen (falta un PNG de 1024x1024).
- [ ] Comentarios que mencionan "el módulo 7" (`FotoManager`, README): mantener solo si los alumnos ya vieron ese módulo.
- [ ] Probar en un iPhone real la Cámara y la Grabadora con los permisos nuevos.

---

## 2026-10-15 — Correcciones de configuración y de código
- Herramienta: Cursor
- Qué cambió:
  - Proyecto: permisos `NSCameraUsageDescription` y `NSMicrophoneUsageDescription`; deployment target iOS 17.0 (antes 27.0); solo iPhone y iPad (se quitaron macOS y visionOS); se restauró `Assets.xcassets` con `AccentColor` y un `AppIcon` vacío.
  - `CamaraViewModel.guardar`: avisa si la foto no se pudo guardar. `CamaraView` muestra "Preparando la cámara…" con un `ProgressView` en vez de "Cámara no disponible".
  - `MisAudiosViewModel.importar` y `VideotecaViewModel.guardar`: cuentan los fallos y los muestran en `mensaje`. `MisAudiosView` y `VideotecaView` ahora muestran ese mensaje abajo (`.safeAreaInset`).
  - `AudioManager`: extensión "m4a" de respaldo al importar; `nuevaURL()` agrega 4 letras del UUID para no sobrescribir grabaciones.
  - `ControlesVideoViewModel`: seguimiento cada 200 ms, como el resto.
  - `ReproductorAudioViewModel` / `ReproductorAudioView`: el Slider avisa con `onEditingChanged` y el seguimiento no mueve la barra mientras la arrastras.
  - Nuevo `DetalleVideoViewModel`; `DetalleVideoView` ya sigue el patrón View → ViewModel → Manager (usa `ReproductorVideoManager`).
  - `README.md` se movió a la raíz del repo para que no se copie dentro de la app.
  - Git: se sacó del índice `MultimediaFull/Menu/MenuView.swift` (ya no existía).
- Por qué: resolver los pendientes detectados en la revisión y al comentar.
- Archivos: `project.pbxproj`, `Assets.xcassets/`, `CamaraViewModel`, `CamaraView`, `MisAudiosViewModel`, `MisAudiosView`, `VideotecaViewModel`, `VideotecaView`, `AudioManager`, `ControlesVideoViewModel`, `ReproductorAudioViewModel`, `ReproductorAudioView`, `DetalleVideoViewModel` (nuevo), `DetalleVideoView`, `Sonido` (comentario), `README.md`.
- Verificación: `BUILD SUCCEEDED` en simulador; el Info.plist generado trae los dos permisos y `MinimumOSVersion = 17.0`.

## 2026-10-15 — Comentarios didácticos en todo el código
- Herramienta: Cursor
- Qué cambió: se agregaron comentarios en español, pensados para alumnos de nivel muy básico, en todos los archivos `.swift` (Models, Services, ViewModels, Views y `MultimediaApp.swift`). No se cambió lógica.
- Por qué: el código se usará para explicar en clase.
- Archivos: todos los `.swift` de `MultimediaFull/`.

## 2026-10-15 — Archivos de contexto para agentes de IA
- Herramienta: Cursor
- Qué cambió: se crearon `AGENTS.md`, `CLAUDE.md` y `docs/BITACORA.md`.
- Por qué: que otros agentes (Claude, etc.) tengan el contexto del proyecto, sus reglas y el historial.
- Archivos: `AGENTS.md`, `CLAUDE.md`, `docs/BITACORA.md`.

## 2026-10-15 — Revisión inicial del proyecto
- Herramienta: Cursor
- Qué cambió: nada en código. Se revisó la arquitectura y se compiló para simulador (`BUILD SUCCEEDED`).
- Hallazgos: ver "Pendientes".
