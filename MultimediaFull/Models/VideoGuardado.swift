import Foundation

/// Un video guardado en la carpeta Documents/Videos (ejemplo "Videoteca", día 3).
///
/// Capa MVVM: **Model**. Representa cada video de la lista; los archivos
/// los maneja `VideoManager`.
///
/// Fíjate que solo guardamos el **nombre** del archivo, no la ruta completa.
/// La ruta de Documents cambia cada vez que reinstalas la app, así que una ruta
/// guardada dejaría de servir. Con el nombre, `VideoManager.url(de:)` arma la ruta correcta.
///
/// - `Identifiable` pide un `id` único para listas y `ForEach`.
/// - `Hashable` permite comparar videos y usarlos, por ejemplo, para navegar a su detalle.
struct VideoGuardado: Identifiable, Hashable {
    /// Nombre del archivo, por ejemplo "1760550000-AB12CD34.mov".
    let nombre: String

    /// Propiedad calculada: el nombre sirve como id porque no se repite en la carpeta.
    var id: String { nombre }
}
