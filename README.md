# Multimedia

Proyecto de práctica del Módulo 9 (Desarrollo de Apps profesionales para iOS). Un solo proyecto con un menú de ejemplos; cada día agrega los suyos.

| Día | Tema | Ejemplos |
| --- | --- | --- |
| 1 | Imágenes | Galería, Mi álbum, Filtros (extra), Imágenes remotas (extra) |
| 2 | Audio | Reproductor, Grabadora, Texto a voz (extra), Mis audios e importar (extra) |
| 3 | Video y cámara | Reproductor de video, Videoteca, Controles de video (extra), Cámara (extra, solo iPhone) |

- Interfaz: 100% SwiftUI (único puente a UIKit: la vista previa de la cámara, en el ejemplo extra del día 3)
- Patrón: MVVM, con la misma idea de carpetas del módulo 7
- Requisitos: Xcode con deployment target iOS 17 (usa `@Observable`, `ContentUnavailableView`, `onChange` de dos parámetros y `AVAudioApplication`)

> Estos archivos no se compilaron en Xcode al prepararlos. Compílalos una vez y corrige cualquier ajuste menor de tu versión.

## Cómo crear el proyecto en Xcode

1. File > New > Project > iOS > App.
2. Product Name: `Multimedia`. Interface: SwiftUI. Language: Swift. Storage: None. Guarda el proyecto.
3. En el navegador de Xcode, borra `MultimediaApp.swift` y `ContentView.swift` (Move to Trash).
4. Selecciona el proyecto > target Multimedia > General > Minimum Deployments: iOS 17.0.
5. Arrastra desde Finder `MultimediaApp.swift` y las cuatro carpetas de `Fuentes/` (`Models`, `Services`, `ViewModels`, `Views`) al grupo `Multimedia` del navegador. En el cuadro: Copy items if needed activado, Create groups seleccionado y el target Multimedia marcado.
6. Arrastra los tres archivos de `Recursos/` (`campana.wav`, `melodia.wav`, `pulso.wav`) al mismo grupo, con las mismas opciones. Los usa el reproductor de audio del día 2.
7. Permisos (target Multimedia > pestaña Info > Custom iOS Target Properties, botón +):
   - `Privacy - Microphone Usage Description`: "Para grabar notas de voz." (día 2, grabadora)
   - `Privacy - Camera Usage Description`: "Para tomar fotos desde la app." (día 3, cámara)
8. Product > Run en un simulador con iOS 17 o superior.

## Estructura

```
Multimedia/
├── MultimediaApp.swift
├── Models/
│   ├── Filtro.swift
│   ├── Foto.swift
│   ├── FuenteVideo.swift
│   ├── Grabacion.swift
│   ├── IdiomaVoz.swift
│   ├── ImagenRemota.swift
│   ├── PeliculaElegida.swift
│   ├── Sonido.swift
│   └── VideoGuardado.swift
├── Services/
│   ├── AudioManager.swift
│   ├── CamaraManager.swift
│   ├── FiltroManager.swift
│   ├── FotoManager.swift
│   ├── GrabadoraManager.swift
│   ├── ImagenesRemotasManager.swift
│   ├── ReproductorAudioManager.swift
│   ├── ReproductorVideoManager.swift
│   ├── TimeInterval+Formato.swift
│   ├── UIImage+Reducida.swift
│   ├── VideoManager.swift
│   └── VozManager.swift
├── ViewModels/
│   ├── AlbumViewModel.swift
│   ├── CamaraViewModel.swift
│   ├── ControlesVideoViewModel.swift
│   ├── DetalleVideoViewModel.swift
│   ├── FiltrosViewModel.swift
│   ├── GaleriaViewModel.swift
│   ├── GrabadoraViewModel.swift
│   ├── ImagenesRemotasViewModel.swift
│   ├── MisAudiosViewModel.swift
│   ├── ReproductorAudioViewModel.swift
│   ├── ReproductorVideoViewModel.swift
│   ├── VideotecaViewModel.swift
│   └── VozViewModel.swift
└── Views/
    ├── AlbumView.swift
    ├── CamaraView.swift
    ├── CeldaCuadrada.swift
    ├── ControlesVideoView.swift
    ├── DetalleFotoView.swift
    ├── DetalleVideoView.swift
    ├── Ejemplo.swift
    ├── FiltrosView.swift
    ├── GaleriaView.swift
    ├── GrabadoraView.swift
    ├── ImagenesRemotasView.swift
    ├── MenuView.swift
    ├── MiniaturaVideoView.swift
    ├── MiniaturaView.swift
    ├── MisAudiosView.swift
    ├── ReproductorAudioView.swift
    ├── ReproductorVideoView.swift
    ├── VideotecaView.swift
    ├── VistaPreviaCamara.swift
    └── VozView.swift
```

Los archivos de `Recursos/` se agregan al mismo grupo `Multimedia`.

## Qué va en cada carpeta

| Carpeta | Qué contiene |
| --- | --- |
| Models | Los datos: `Foto`, `Filtro`, `Sonido`, `Grabacion`, `FuenteVideo`... |
| Services | Quien hace el trabajo: archivos, filtros, audio, video, cámara. Los que guardan archivos o no tienen estado se usan como `XxxManager.shared`; los que mantienen un reproductor, una grabadora o una cámara se crean con `XxxManager()` dentro del ViewModel |
| ViewModels | El estado de cada pantalla (`@Observable`) y lo que pasa cuando el usuario actúa |
| Views | Lo que se dibuja: el menú y las pantallas |

## MVVM en este proyecto

- **View**: dibuja y reenvía eventos. No toca archivos, audio ni cámara.
- **ViewModel**: guarda el estado y decide qué pasa. Llama a los services.
- **Model**: los datos.

Cada pantalla crea su ViewModel con `@State private var viewModel = XxxViewModel()`. El ViewModel no hace trabajo pesado al crearse; la lectura de datos se dispara con `.task` en la vista.

## Qué funciona en simulador

| Ejemplo | Simulador | Notas |
| --- | --- | --- |
| Día 1 completo | Sí | Imágenes remotas necesita internet |
| Reproductor de audio | Sí | El sonido sale por las bocinas de la Mac |
| Grabadora de voz | Sí | Usa el micrófono de la Mac; pide permiso la primera vez |
| Texto a voz | Sí | Puede tardar en la primera voz |
| Mis audios e importar | Sí | Arrastra un audio a la app Archivos del simulador |
| Reproductor de video y controles | Sí | Necesita internet |
| Videoteca | Sí | Arrastra un video a la app Fotos del simulador |
| Cámara | No | Requiere iPhone o iPad; en el simulador muestra un aviso |

## Agregar un ejemplo nuevo

1. Un `XxxViewModel` en `ViewModels/` y una `XxxView` en `Views/`.
2. Si necesita guardar o hacer algo nuevo, un `XxxManager` en `Services/`.
3. Un caso en el enum `Ejemplo` (título, ícono y sección).
4. El caso en el `switch` de `MenuView.destino(para:)`.

## Reglas del proyecto

- Las pantallas de ejemplo no crean su propio `NavigationStack`; ya viven dentro del de `MenuView`. Solo llevan `.navigationTitle` y `.toolbar`.
- Un archivo por tipo y con el nombre del tipo (excepción: `VistaPreviaCamara.swift` lleva el puente y su vista auxiliar).
- Se guarda solo el nombre del archivo, nunca la ruta completa.
- La View nunca llama a un Manager directamente: siempre pasa por su ViewModel.

## Notas de compilación

- Si usas Xcode 26 y el proyecto nuevo trae Default Actor Isolation en MainActor, el código funciona igual. Si aparece un aviso de concurrencia, deja el proyecto en modo Swift 5.
- Los videos de internet son direcciones públicas de prueba y pueden cambiar; si alguna no responde, cambia la URL en `FuenteVideo.swift`.
