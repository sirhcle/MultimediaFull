import SwiftUI
import PhotosUI

/// Estado y acciones de la pantalla "Mi álbum" (ejemplo del día 1).
///
/// Capa MVVM: **ViewModel**. Recibe las fotos que el usuario elige, se las pasa a
/// `FotoManager` para guardarlas en disco y mantiene la lista de archivos que dibuja `AlbumView`.
/// A diferencia de la Galería, aquí las fotos se guardan y siguen ahí al volver a abrir la app.
///
/// - `@MainActor` hace que todo este código corra en el hilo principal,
///   que es el único que puede actualizar la pantalla.
/// - `@Observable` hace que SwiftUI vigile las propiedades: cuando una cambia,
///   la vista que la usa se vuelve a dibujar sola.
/// - Es una `class` porque la vista y el ViewModel deben compartir el mismo objeto (referencia).
@MainActor
@Observable
final class AlbumViewModel {

    // MARK: - Estado

    /// Lo que el usuario eligió en el `PhotosPicker`.
    /// Un `PhotosPickerItem` es solo una referencia a una foto de la fototeca:
    /// todavía no es una imagen, hay que cargarla. Es `var` normal porque la vista la modifica.
    var seleccion: [PhotosPickerItem] = []

    /// Nombres de los archivos guardados. La vista dibuja una miniatura por cada uno.
    /// `private(set)`: la vista puede leerla, pero solo este ViewModel puede cambiarla.
    /// Guardamos solo el nombre, no la ruta completa, porque la ruta del sandbox cambia entre instalaciones.
    private(set) var archivos: [String] = []

    // MARK: - Acciones

    /// Lee del disco la lista de archivos. La vista lo llama al aparecer.
    func cargarArchivos() {
        archivos = FotoManager.shared.listar()
    }

    /// Guarda en disco cada foto elegida y actualiza la lista.
    /// Es `async` porque cargar cada foto tarda; con `await` esperamos sin congelar la pantalla.
    func guardar(_ items: [PhotosPickerItem]) async {
        // Al final vaciamos `seleccion`, y eso vuelve a llamar a esta función con una lista vacía.
        // Este `guard` corta ese segundo llamado para no hacer trabajo de más.
        guard !items.isEmpty else { return }

        for item in items {
            // `loadTransferable(type: Data.self)` pide los bytes de la foto a la fototeca.
            // `if let` desenvuelve los opcionales: el bloque solo corre si las dos cosas salieron bien
            // (llegaron los datos y se pudieron convertir en UIImage).
            if let data = try? await item.loadTransferable(type: Data.self),
               let imagen = UIImage(data: data) {
                // try? ignora el error; una app real mostraría un aviso al usuario.
                // `_ =` descarta el nombre que devuelve `guardar`, porque aquí no lo necesitamos.
                _ = try? FotoManager.shared.guardar(imagen)
            }
        }
        archivos = FotoManager.shared.listar()

        // Se vacía la selección para poder elegir las mismas fotos otra vez.
        seleccion = []
    }

    /// Lee del disco la imagen con ese nombre. Devuelve nil si no existe.
    func imagen(para nombre: String) -> UIImage? {
        FotoManager.shared.cargar(nombre)
    }

    /// Borra la foto del disco y vuelve a leer la lista para que la pantalla se actualice.
    func eliminar(_ nombre: String) {
        FotoManager.shared.borrar(nombre)
        archivos = FotoManager.shared.listar()
    }
}
