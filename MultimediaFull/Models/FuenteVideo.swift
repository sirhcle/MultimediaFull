// Foundation trae tipos básicos como URL, Date o String.
import Foundation

/// Un video que vive en internet y que la app puede reproducir.
///
/// Capa MVVM: **Model**. Lo usan los ejemplos "Reproductor de video" y "Controles de video".
///
/// - `Identifiable` pide un `id` único para usarlo en listas y `ForEach`.
/// - `Hashable` permite comparar dos fuentes y usarlas como selección,
///   por ejemplo en un `Picker`. Swift lo implementa solo porque
///   todas las propiedades (String y URL) ya son Hashable.
struct FuenteVideo: Identifiable, Hashable {
    /// Nombre que ve el usuario.
    let titulo: String
    /// Dirección del video en internet.
    let url: URL

    /// Propiedad calculada: usamos la dirección como identificador
    /// porque no hay dos videos con la misma dirección.
    var id: URL { url }

    // MARK: - Lista de videos

    /// Todos los videos disponibles.
    /// `static` significa que la lista pertenece al tipo, no a cada video:
    /// la lees como `FuenteVideo.todas`, sin crear nada antes.
    ///
    /// Hay dos formatos para que veas la diferencia:
    /// - HLS (.m3u8): el video llega en pedacitos y se adapta a tu conexión.
    /// - MP4: un archivo completo que se descarga mientras se reproduce.
    // Las direcciones son de pruebas públicas y pueden cambiar con el tiempo.
    // URL(string:) devuelve un opcional (puede fallar si el texto no es una dirección).
    // Los signos ! lo "desenvuelven" a la fuerza. Aquí son seguros: los textos son
    // direcciones válidas escritas a mano. Con texto que venga del usuario, nunca uses !.
    static let todas = [
        FuenteVideo(
            titulo: "Apple (HLS)",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
        ),
        FuenteVideo(
            titulo: "Big Buck Bunny (MP4)",
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        )
    ]
}
