import Foundation

/// Entrega la lista de imágenes de internet para el ejemplo "Imágenes remotas" (día 1).
///
/// Capa MVVM: **Service** (un "Manager"). Lo usa `ImagenesRemotasViewModel`;
/// la descarga real la hace `AsyncImage` en la vista.
///
/// Las direcciones son de picsum.photos, un servicio público de imágenes de prueba.
/// La última dirección no existe a propósito, para que veas cómo se ve
/// el estado de fallo de `AsyncImage`.
///
/// Como no guarda estado, se usa como singleton: `ImagenesRemotasManager.shared`.
struct ImagenesRemotasManager {
    /// `static let shared` crea una sola instancia compartida por toda la app.
    static let shared = ImagenesRemotasManager()

    /// `private init()` impide crear otra instancia desde fuera: solo existe `shared`.
    /// Está vacío porque no hay nada que preparar.
    private init() {}

    /// Devuelve las imágenes a mostrar: 8 válidas y 1 que falla a propósito.
    func obtener() -> [ImagenRemota] {
        // (10...17) es un rango: los números del 10 al 17, incluidos.
        // map convierte cada número ($0) en una dirección de texto con ese id de imagen.
        // El "/400/400" del final pide la imagen de 400 x 400 píxeles.
        let validas = (10...17).map { "https://picsum.photos/id/\($0)/400/400" }
        let invalida = "https://example.invalid/no-existe.jpg"

        // Unimos las dos listas y convertimos cada texto en una ImagenRemota.
        // URL(string:) devuelve un opcional (nil si el texto no es una dirección válida).
        // El .map sobre ese opcional crea la ImagenRemota solo si hay URL.
        // compactMap descarta los nil, así la lista final solo tiene imágenes con URL.
        return (validas + [invalida]).compactMap { texto in
            URL(string: texto).map { ImagenRemota(url: $0) }
        }
    }
}
