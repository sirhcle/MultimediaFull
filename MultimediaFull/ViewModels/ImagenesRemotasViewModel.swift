import SwiftUI

/// Estado de la pantalla "Imágenes remotas" (ejemplo extra del día 1).
///
/// Capa MVVM: **ViewModel**. Pide a `ImagenesRemotasManager` la lista de direcciones
/// de imágenes en internet y la guarda para que `ImagenesRemotasView` las dibuje.
/// La descarga de cada imagen la hace la vista con `AsyncImage`; aquí solo están las direcciones.
///
/// - `@MainActor` hace que todo este código corra en el hilo principal,
///   que es el único que puede actualizar la pantalla.
/// - `@Observable` hace que SwiftUI vigile las propiedades: cuando una cambia,
///   la vista que la usa se vuelve a dibujar sola.
/// - Es una `class` porque la vista y el ViewModel deben compartir el mismo objeto (referencia).
@MainActor
@Observable
final class ImagenesRemotasViewModel {

    // MARK: - Estado

    /// Imágenes que se van a mostrar.
    /// `private(set)`: la vista puede leerla, pero solo este ViewModel puede cambiarla.
    private(set) var imagenes: [ImagenRemota] = []

    // MARK: - Acciones

    /// Llena la lista de imágenes. La vista lo llama en `.task`, al aparecer,
    /// para que el `init` del ViewModel no haga trabajo.
    func cargar() {
        imagenes = ImagenesRemotasManager.shared.obtener()
    }
}
