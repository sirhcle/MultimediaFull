# AGENTS.md — Contexto del proyecto MultimediaFull

Este archivo es para cualquier agente o modelo de IA (Cursor, Claude, ChatGPT, etc.) que vaya a analizar o cambiar este proyecto. Léelo completo antes de tocar código. Si haces un cambio, registra una entrada en `docs/BITACORA.md`.

## 1. Qué es

- App de iOS de práctica para un **curso de desarrollo de apps de nivel muy básico** (Módulo 9: "Desarrollo de Apps profesionales para iOS").
- El instructor la construye **desde cero frente a los alumnos**, por eso el código debe ser simple, legible y **muy comentado** en español.
- Es un solo proyecto con un menú de ejemplos, agrupados por día de clase:

| Día | Tema | Ejemplos (caso del enum `Ejemplo`) |
| --- | --- | --- |
| 1 | Imágenes | `galeria`, `album`, `filtros` (extra), `imagenesRemotas` (extra) |
| 2 | Audio | `reproductorAudio`, `grabadora`, `textoAVoz` (extra), `misAudios` (extra) |
| 3 | Video y cámara | `reproductorVideo`, `videoteca`, `controlesVideo` (extra), `camara` (extra, solo iPhone real) |

## 2. Tecnología

- Swift + **SwiftUI** (100 %). Único puente a UIKit: `Views/VistaPreviaCamara.swift` (`UIViewRepresentable`).
- Frameworks de Apple: PhotosUI, AVFoundation, AVKit, Core Image, UniformTypeIdentifiers. **Sin dependencias externas** (no agregar paquetes SPM/CocoaPods).
- Observación con `@Observable` (no `ObservableObject`/`@Published`).
- Proyecto Xcode con carpetas sincronizadas (`objectVersion = 90`): todo archivo dentro de `MultimediaFull/` entra solo al target. **No hace falta editar `project.pbxproj` para agregar archivos.**
- Build settings relevantes: `SWIFT_VERSION = 5.0`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`, Info.plist generado (`GENERATE_INFOPLIST_FILE = YES`, las claves van como `INFOPLIST_KEY_*` en build settings).
- Persistencia: solo archivos en el sandbox (`Documents/Fotos`, `Documents/Audios`, `Documents/Videos`). Sin base de datos.

## 3. Estructura y arquitectura (MVVM)

```
MultimediaFull/
├── MultimediaApp.swift      Punto de entrada (@main). Muestra MenuView.
├── Models/                  Datos simples (structs/enums).
├── Services/                "Managers": hacen el trabajo (archivos, audio, video, cámara, filtros).
├── ViewModels/              Estado de cada pantalla (@MainActor @Observable) y acciones del usuario.
├── Views/                   Lo que se dibuja. MenuView + una vista por ejemplo + vistas auxiliares.
├── Recursos/                campana.wav, melodia.wav, pulso.wav (los usa el reproductor de audio).
└── Assets.xcassets/         AppIcon (sin imagen todavía) y AccentColor.
```

Configuración del target: iOS 17.0 mínimo, solo iPhone y iPad (`TARGETED_DEVICE_FAMILY = 1,2`), permisos `NSCameraUsageDescription` y `NSMicrophoneUsageDescription` como `INFOPLIST_KEY_*` en build settings. Si un ejemplo nuevo necesita otro permiso, agrégalo igual en las dos configuraciones (Debug y Release) del target.

Flujo: **View → ViewModel → Manager**. Nunca al revés y nunca saltándose capas.

### Reglas que no se rompen

1. La **View** solo dibuja y reenvía eventos. Nunca llama a un Manager directamente.
2. El **ViewModel** guarda el estado (`private(set) var` para lo que la vista solo lee) y llama a los Managers. Los Managers internos van con `@ObservationIgnored`.
3. Cada pantalla crea su ViewModel con `@State private var viewModel = XxxViewModel()`. El `init` del ViewModel no hace trabajo pesado; la carga se dispara con `.task` en la vista.
4. Managers:
   - Sin estado o que solo manejan archivos → singleton `XxxManager.shared` con `private init()`.
   - Con un recurso vivo (reproductor, grabadora, cámara, voz) → `XxxManager()` creado dentro del ViewModel.
5. Hay **un solo `NavigationStack`**, en `MenuView`. Las pantallas de ejemplo solo usan `.navigationTitle` y `.toolbar`.
6. Se guarda **solo el nombre del archivo**, nunca la ruta completa (la ruta del sandbox cambia entre instalaciones).
7. **Un archivo por tipo**, con el nombre del tipo. Excepción: `VistaPreviaCamara.swift` (puente + su `UIView`).
8. Errores: el ViewModel los convierte en un texto `mensaje` que la vista muestra. No se lanzan errores hacia la vista.
9. Avisos de AVFoundation (delegados) llegan por un closure (`alTerminar`, `alCapturar`) y el ViewModel vuelve al hilo principal con `Task { @MainActor in ... }`.
10. Seguimiento de tiempo (barras de progreso): un `Task` que lee cada 200 ms, no `Timer`.
### Agregar un ejemplo nuevo

1. `ViewModels/XxxViewModel.swift` y `Views/XxxView.swift`.
2. Si hace falta trabajo nuevo: `Services/XxxManager.swift`.
3. Un caso en el enum `Ejemplo` (`Views/Ejemplo.swift`): `titulo`, `icono` (SF Symbol) y `seccion`.
4. El caso en el `switch` de `MenuView.destino(para:)`.

## 4. Convenciones de código

- **Todo en español**: tipos, propiedades, funciones, mensajes y comentarios (`reproducir()`, `tiempoActual`, `FotoManager`). Las APIs de Apple quedan en inglés, obviamente.
- Nivel del curso: **muy básico**. Prefiere código explícito y fácil de leer sobre código ingenioso o corto. Evita genéricos propios, protocolos propios, Combine, actores propios, macros, extensiones complejas o patrones avanzados, salvo que el instructor lo pida.
- No cambiar la lógica al comentar. No renombrar cosas sin que se pida.

## 5. Guía de comentarios (para explicar a los alumnos)

Los comentarios son **material didáctico**. Se escriben pensando en alguien que está aprendiendo Swift y SwiftUI por primera vez.

- Idioma español, tuteo ("aquí guardas…", "fíjate que…"), frases cortas y claras. Sin emojis.
- Al inicio de cada archivo, un comentario `///` sobre el tipo principal que diga: **qué es**, **a qué capa de MVVM pertenece** y **para qué sirve en la app**.
- Usa `// MARK: - Sección` para separar bloques (Estado, Acciones, Ayudantes, Delegado…) cuando el archivo tenga más de un bloque.
- `///` para documentar propiedades y funciones (qué hacen / qué devuelven). `//` dentro del código para explicar pasos.
- Explica **cada concepto de Swift o SwiftUI la primera vez que aparece en un archivo**, en una línea o dos: `@Observable`, `@State`, `@Bindable`, `private(set)`, `guard`, `if let`, `async/await`, `Task`, `[weak self]`, `try?`/`do-catch`, `static let shared`, `@MainActor`, `@ObservationIgnored`, `@ViewBuilder`, `some View`, `enum` con `switch`, `CaseIterable`, `Identifiable`, closures, computed properties, modificadores como `.task`, `.onChange`, `.toolbar`, `.sheet`/`.fullScreenCover`, etc.
- Explica el **porqué** de las decisiones (por qué se reduce una imagen, por qué la cámara arranca en otro hilo, por qué se guarda solo el nombre del archivo).
- No comentar lo totalmente obvio línea por línea (`// suma 1`); agrupa un comentario por bloque lógico.
- Mantener los comentarios actualizados si el código cambia.

## 6. Compilar y probar

```bash
xcodebuild -project MultimediaFull.xcodeproj -scheme MultimediaFull \
  -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

- Casi todo funciona en simulador. La **cámara requiere un iPhone/iPad real** (en simulador muestra un aviso).
- Imágenes remotas y reproductor/controles de video necesitan internet (URLs públicas de prueba en `Models/FuenteVideo.swift`).

## 7. Pendientes conocidos

Ver `docs/BITACORA.md`, sección "Pendientes".

## 8. Archivos de contexto

- `AGENTS.md` (este archivo): reglas y contexto. Fuente de verdad.
- `CLAUDE.md`: apunta a este archivo para Claude Code.
- `docs/BITACORA.md`: historial de cambios y decisiones, y lista de pendientes. **Agrega una entrada cada vez que cambies algo.**
- `README.md` (raíz del repo): guía para alumnos (cómo crear el proyecto en Xcode paso a paso). Va fuera de `MultimediaFull/` para que no se copie dentro de la app; lo mismo aplica a cualquier documento nuevo.
