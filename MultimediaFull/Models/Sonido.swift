import Foundation

/// Un sonido que viene incluido dentro de la app (ejemplo "Reproductor de audio", día 2).
///
/// Capa MVVM: **Model**. Describe cada sonido de la carpeta Recursos;
/// quien lo reproduce es `ReproductorAudioManager`.
///
/// Estos archivos viven dentro del paquete de la app (el "bundle"), no en Documents.
/// Por eso no se pueden borrar ni cambiar: son parte de la app, como los íconos.
///
/// - `Identifiable` pide un `id` único para listas y `ForEach`.
/// - `Hashable` permite comparar sonidos, por ejemplo para marcar cuál está elegido.
struct Sonido: Identifiable, Hashable {
    /// Nombre que ve el usuario.
    let titulo: String
    /// Nombre del archivo .wav, sin la extensión.
    let archivo: String
    /// Nombre de un SF Symbol (los íconos que trae iOS), por ejemplo "bell".
    let icono: String

    /// Propiedad calculada: el nombre del archivo sirve como id porque no se repite.
    var id: String { archivo }

    /// Dirección del archivo dentro de la app.
    /// `URL?` (con signo de interrogación) es un opcional: puede tener una URL o ser `nil`.
    /// Es nil si el archivo no está dentro de la app (por ejemplo, si el .wav no está en la carpeta Recursos).
    var url: URL? {
        // Bundle.main es el paquete de tu app. Aquí le pedimos un archivo por nombre y extensión.
        Bundle.main.url(forResource: archivo, withExtension: "wav")
    }

    // MARK: - Lista de sonidos

    /// Todos los sonidos incluidos en la app.
    /// `static` hace que la lista pertenezca al tipo: la lees como `Sonido.todos`.
    static let todos = [
        Sonido(titulo: "Campana", archivo: "campana", icono: "bell"),
        Sonido(titulo: "Melodía", archivo: "melodia", icono: "music.note"),
        Sonido(titulo: "Pulso", archivo: "pulso", icono: "waveform")
    ]
}
