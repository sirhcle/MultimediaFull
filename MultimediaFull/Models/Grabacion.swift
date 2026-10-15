import Foundation

/// Un audio guardado en la carpeta Documents/Audios (grabado con el micrófono o importado).
///
/// Capa MVVM: **Model**. Lo crea `AudioManager` al listar la carpeta
/// y lo muestran los ejemplos "Grabadora" y "Mis audios".
///
/// Fíjate que solo guardamos el **nombre** del archivo, no la ruta completa.
/// La ruta de la carpeta Documents cambia cada vez que reinstalas la app,
/// así que una ruta guardada dejaría de servir. Con el nombre, `AudioManager`
/// arma la ruta correcta en el momento con `url(de:)`.
///
/// - `Identifiable` pide un `id` único para listas y `ForEach`.
/// - `Hashable` permite comparar grabaciones, por ejemplo para saber cuál está sonando.
struct Grabacion: Identifiable, Hashable {
    /// Nombre del archivo, por ejemplo "grabacion-1760550000.m4a".
    let nombre: String
    /// Fecha en que se creó el archivo. Sirve para ordenar la lista.
    let fecha: Date

    /// Propiedad calculada: el nombre sirve como id porque en una carpeta
    /// no puede haber dos archivos con el mismo nombre.
    var id: String { nombre }
}
