// MARK: - Seccion

/// Agrupa los ejemplos del menú por día de clase.
///
/// Capa MVVM: **Model** del menú. Son datos simples que `MenuView` usa
/// para dibujar los encabezados de la lista.
///
/// - `enum` es una lista cerrada de opciones: una sección solo puede ser uno de estos casos.
/// - `: String` le da a cada caso un texto asociado, llamado `rawValue`.
///   Aquí ese texto es justo el encabezado que ve el usuario.
/// - `CaseIterable` te regala `Seccion.allCases`, un arreglo con todos los casos,
///   para recorrerlos con `ForEach` sin escribirlos a mano.
/// - `Identifiable` pide una propiedad `id` única. `ForEach` la usa
///   para distinguir una sección de otra.
enum Seccion: String, CaseIterable, Identifiable {
    case dia1 = "Día 1 · Imágenes"
    case dia2 = "Día 2 · Audio"
    case dia3 = "Día 3 · Video y cámara"

    /// Identificador de cada caso: su texto, que ya es único.
    /// Es una propiedad calculada (computed property): no guarda nada,
    /// calcula su valor cada vez que alguien la lee.
    var id: String { rawValue }

    /// Los ejemplos que pertenecen a esta sección.
    ///
    /// `filter` recorre todos los ejemplos y se queda solo con los que cumplen
    /// la condición. `$0` es el nombre corto del elemento que se está revisando,
    /// y `self` es la sección actual. Así no repites la lista de ejemplos aquí:
    /// cada ejemplo ya dice a qué sección pertenece (ver `seccion` más abajo).
    var ejemplos: [Ejemplo] {
        Ejemplo.allCases.filter { $0.seccion == self }
    }
}

// MARK: - Ejemplo

/// Un caso por cada pantalla de ejemplo del proyecto.
///
/// Capa MVVM: **Model** del menú. Describe qué ejemplos existen, con su título,
/// su ícono y su día. `MenuView` lo usa para dibujar las filas y para navegar.
///
/// Para agregar un ejemplo nuevo: un caso aquí (con su `titulo`, `icono` y `seccion`)
/// y una línea en el `switch` de `MenuView.destino(para:)`.
///
/// - Aquí los casos no tienen texto escrito, así que el `rawValue` es el propio
///   nombre del caso (`"galeria"`, `"album"`...).
/// - `Hashable` permite usar un `Ejemplo` como valor de navegación:
///   `NavigationLink(value:)` y `.navigationDestination(for:)` lo necesitan
///   para comparar y guardar valores en la pila de pantallas.
enum Ejemplo: String, CaseIterable, Identifiable, Hashable {
    // MARK: Casos

    // Día 1
    case galeria
    case album
    case filtros
    case imagenesRemotas
    // Día 2
    case reproductorAudio
    case grabadora
    case textoAVoz
    case misAudios
    // Día 3
    case reproductorVideo
    case videoteca
    case controlesVideo
    case camara

    // MARK: Datos para el menú

    /// Identificador único: el nombre del caso.
    var id: String { rawValue }

    /// Texto que se ve en la fila del menú.
    ///
    /// `switch self` revisa en qué caso estás y devuelve un texto distinto para cada uno.
    /// Fíjate que no hace falta escribir `return`: cuando cada rama tiene
    /// una sola expresión, Swift entiende que ese es el valor a devolver.
    var titulo: String {
        switch self {
        case .galeria: "Galería con PhotosPicker"
        case .album: "Mi álbum con FileManager"
        case .filtros: "Editor de filtros (extra)"
        case .imagenesRemotas: "Imágenes remotas (extra)"
        case .reproductorAudio: "Reproductor de audio"
        case .grabadora: "Grabadora de voz"
        case .textoAVoz: "Texto a voz (extra)"
        case .misAudios: "Mis audios e importar (extra)"
        case .reproductorVideo: "Reproductor de video"
        case .videoteca: "Videoteca con PhotosPicker"
        case .controlesVideo: "Controles de video (extra)"
        case .camara: "Cámara (extra, solo iPhone)"
        }
    }

    /// Nombre del ícono SF Symbol de cada fila.
    /// Los SF Symbols son íconos que ya vienen en iOS; puedes buscarlos
    /// con la app gratuita "SF Symbols" de Apple.
    var icono: String {
        switch self {
        case .galeria: "photo.on.rectangle"
        case .album: "folder"
        case .filtros: "wand.and.stars"
        case .imagenesRemotas: "network"
        case .reproductorAudio: "play.circle"
        case .grabadora: "mic"
        case .textoAVoz: "text.bubble"
        case .misAudios: "music.note.list"
        case .reproductorVideo: "play.rectangle"
        case .videoteca: "film.stack"
        case .controlesVideo: "slider.horizontal.3"
        case .camara: "camera"
        }
    }

    /// Día de clase al que pertenece el ejemplo.
    /// Puedes juntar varios casos en una misma rama separándolos con comas.
    var seccion: Seccion {
        switch self {
        case .galeria, .album, .filtros, .imagenesRemotas: .dia1
        case .reproductorAudio, .grabadora, .textoAVoz, .misAudios: .dia2
        case .reproductorVideo, .videoteca, .controlesVideo, .camara: .dia3
        }
    }
}
