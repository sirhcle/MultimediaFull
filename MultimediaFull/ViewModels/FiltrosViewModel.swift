import SwiftUI
import PhotosUI

/// Estado y acciones de la pantalla "Filtros" (ejemplo extra del día 1).
///
/// Capa MVVM: **ViewModel**. Carga la foto que elige el usuario, le pide a `FiltroManager`
/// que aplique el filtro y, si el usuario quiere, la guarda en "Mi álbum" con `FotoManager`.
/// `FiltrosView` solo dibuja lo que hay aquí.
///
/// - `@MainActor` hace que todo este código corra en el hilo principal,
///   que es el único que puede actualizar la pantalla.
/// - `@Observable` hace que SwiftUI vigile las propiedades: cuando una cambia,
///   la vista que la usa se vuelve a dibujar sola.
/// - Es una `class` porque la vista y el ViewModel deben compartir el mismo objeto (referencia).
@MainActor
@Observable
final class FiltrosViewModel {

    // MARK: - Estado

    // Estas dos son `var` normales porque la vista las cambia (con el PhotosPicker y el Picker).

    /// Foto elegida en el selector. Es un `PhotosPickerItem` opcional: una referencia
    /// a una foto de la fototeca (todavía no es imagen), o nil si no hay ninguna.
    var seleccion: PhotosPickerItem?

    /// Filtro elegido. Al cambiar, la vista llama a `aplicarFiltro()`.
    var filtro: Filtro = .original

    /// Foto elegida, ya reducida.
    /// `private(set)`: la vista puede leerla, pero solo este ViewModel puede cambiarla.
    /// La guardamos aparte para aplicar cada filtro siempre sobre la foto limpia
    /// y no encimar un filtro sobre otro.
    private(set) var original: UIImage?

    /// Foto con el filtro aplicado; es la que se ve en pantalla.
    private(set) var resultado: UIImage?

    /// Texto para avisar al usuario (por ejemplo, si la foto se guardó o no). Vacío = sin aviso.
    private(set) var mensaje = ""

    /// Propiedad calculada: true si ya hay una foto cargada. La vista la usa para
    /// desactivar los controles mientras no hay foto.
    var hayFoto: Bool { original != nil }

    // MARK: - Acciones

    /// Convierte la foto elegida en imagen, la reduce y la deja lista para filtrar.
    /// Es `async` porque cargar la foto tarda; con `await` esperamos sin congelar la pantalla.
    func cargar(_ item: PhotosPickerItem?) async {
        // `guard` revisa tres cosas: que haya algo elegido, que lleguen sus datos
        // con `loadTransferable` y que esos datos sean una imagen. Si algo falla, salimos.
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let imagen = UIImage(data: data) else { return }

        // Filtrar una foto de 12 MP es lento y la pantalla no necesita tanto detalle.
        // Por eso la reducimos a 1200 px en su lado más largo.
        // Al cargar una foto nueva volvemos al filtro original y borramos el aviso anterior.
        let reducida = imagen.reducida(maxLado: 1200)
        original = reducida
        filtro = .original
        resultado = reducida
        mensaje = ""
    }

    /// Aplica el filtro elegido sobre la foto original y guarda el resultado.
    func aplicarFiltro() {
        // `guard let original` desenvuelve el opcional: si no hay foto, no hay nada que filtrar.
        guard let original else { return }
        resultado = FiltroManager.shared.aplicar(filtro, a: original)
    }

    /// Guarda la foto filtrada en "Mi álbum" y avisa si salió bien o mal.
    func guardar() {
        guard let resultado else { return }
        // `do-catch`: intentamos (`try`) guardar; si `guardar` lanza un error, saltamos al `catch`.
        // El error no llega a la vista: lo convertimos en un texto para el usuario.
        do {
            _ = try FotoManager.shared.guardar(resultado)
            mensaje = "Guardada en Mi álbum."
        } catch {
            mensaje = "No se pudo guardar la imagen."
        }
    }
}
