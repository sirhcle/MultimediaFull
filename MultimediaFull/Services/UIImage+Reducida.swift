import UIKit

/// Ayudante para hacer más pequeñas las imágenes antes de mostrarlas o guardarlas.
///
/// Capa MVVM: **Service** (un ayudante compartido). Lo usan los ViewModels de "Filtros" y "Cámara".
///
/// ¿Por qué reducir? Una foto del iPhone puede medir 4000 x 3000 píxeles y ocupar
/// decenas de megas en memoria. Para verla en pantalla basta con mucho menos,
/// y así la app no se vuelve lenta ni se cierra por falta de memoria.
///
/// - `extension` agrega funciones a un tipo que ya existe (aquí `UIImage`) sin modificarlo.
///   Después la usas como si fuera de Apple: `imagen.reducida(maxLado: 1200)`.
extension UIImage {
    /// Devuelve una copia cuyo lado mayor no pasa de `maxLado` píxeles.
    /// La imagen original no cambia.
    ///
    /// Al redibujar la imagen también se normaliza su orientación,
    /// así que el resultado siempre sale derecho.
    func reducida(maxLado: CGFloat) -> UIImage {
        // Buscamos el lado más largo. Si la imagen no tiene tamaño, la devolvemos tal cual.
        let mayor = max(size.width, size.height)
        guard mayor > 0 else { return self }

        // Cuánto hay que achicarla. min(1, ...) evita agrandar imágenes que ya son pequeñas.
        // Multiplicar ancho y alto por la misma escala conserva la proporción.
        let escala = min(1, maxLado / mayor)
        let nuevoTamano = CGSize(width: size.width * escala, height: size.height * escala)

        // scale = 1 hace que 1 punto sea 1 píxel. Sin esto, en una pantalla Retina
        // la imagen saldría 2 o 3 veces más grande de lo que pediste.
        let formato = UIGraphicsImageRendererFormat.default()
        formato.scale = 1

        // El renderer es un "lienzo" del tamaño nuevo. Dentro del closure dibujamos
        // la imagen original estirada a ese tamaño y el renderer nos da la imagen resultante.
        // El "_" indica que no usamos el parámetro que nos pasa el closure.
        let renderer = UIGraphicsImageRenderer(size: nuevoTamano, format: formato)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: nuevoTamano))
        }
    }
}
