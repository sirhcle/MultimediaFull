import SwiftUI
import PhotosUI

/// Estado y acciones de la pantalla "Galería" (ejemplo del día 1).
///
/// Capa MVVM: **ViewModel**. Convierte las fotos que el usuario elige en imágenes
/// que `GaleriaView` dibuja en una cuadrícula. Las fotos solo viven en memoria:
/// al salir de la pantalla se pierden (para guardarlas está "Mi álbum").
///
/// - `@MainActor` hace que todo este código corra en el hilo principal,
///   que es el único que puede actualizar la pantalla.
/// - `@Observable` hace que SwiftUI vigile las propiedades: cuando una cambia,
///   la vista que la usa se vuelve a dibujar sola.
/// - Es una `class` porque la vista y el ViewModel deben compartir el mismo objeto (referencia).
@MainActor
@Observable
final class GaleriaViewModel {

    // MARK: - Estado

    /// Lo que el usuario eligió en el selector (referencias, todavía no son imágenes).
    /// Un `PhotosPickerItem` apunta a una foto de la fototeca; hay que cargarla para tener la imagen.
    var seleccion: [PhotosPickerItem] = []

    /// Foto que se muestra a pantalla completa; nil = ninguna.
    /// La vista la usa con `.fullScreenCover(item:)`: cuando tiene valor se abre, y al cerrarse vuelve a nil.
    var fotoAmpliada: Foto?

    /// Fotos ya cargadas en memoria.
    /// `private(set)`: la vista puede leerla, pero solo este ViewModel puede cambiarla.
    private(set) var fotos: [Foto] = []

    /// Cuántas fotos se pueden elegir como máximo. Es `let` porque nunca cambia.
    let maximoFotos = 6

    // MARK: - Acciones

    /// Convierte cada elemento elegido en una imagen.
    /// Es `async` porque cargar cada foto tarda; con `await` esperamos sin congelar la pantalla.
    func cargar(_ items: [PhotosPickerItem]) async {
        // Juntamos las fotos en una lista temporal y la asignamos al final,
        // así la pantalla se actualiza una sola vez y no foto por foto.
        var resultado: [Foto] = []
        for item in items {
            // `loadTransferable(type: Data.self)` pide los bytes de la foto.
            // `try?` convierte un error en nil, y `if let` solo entra si todo salió bien.
            if let data = try? await item.loadTransferable(type: Data.self),
               let imagen = UIImage(data: data) {
                resultado.append(Foto(imagen: imagen))
            }
        }
        fotos = resultado
    }
}
