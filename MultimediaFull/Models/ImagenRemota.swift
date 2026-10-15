import Foundation

/// Una imagen que vive en internet (ejemplo "Imágenes remotas", día 1).
///
/// Capa MVVM: **Model**. Solo guarda la dirección; la descarga la hace
/// `AsyncImage` en la vista. La lista de imágenes la entrega `ImagenesRemotasManager`.
///
/// - `Identifiable` pide un `id` único para que `ForEach` distinga cada imagen.
struct ImagenRemota: Identifiable {
    /// Dirección de la imagen en internet.
    let url: URL

    /// Propiedad calculada: la dirección sirve también como identificador.
    var id: URL { url }
}
