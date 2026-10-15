// UIKit nos da UIImage, el tipo con el que iOS representa una imagen.
import UIKit

/// Una foto en memoria (por ejemplo, la que el usuario eligió en la galería).
///
/// Capa MVVM: **Model**. Solo guarda datos; no sabe dibujarse ni guardarse en disco.
///
/// - `struct` es un tipo de valor: si lo copias, obtienes otra copia independiente.
///   Para datos simples como este es lo más recomendable.
/// - `Identifiable` pide una propiedad `id` única. Gracias a ella,
///   `ForEach` y `.fullScreenCover(item:)` pueden distinguir una foto de otra.
struct Foto: Identifiable {
    /// `UUID()` crea un identificador al azar que nunca se repite.
    /// `let` significa que el valor no cambia después de crearse.
    let id = UUID()
    /// La imagen en sí.
    let imagen: UIImage
}
