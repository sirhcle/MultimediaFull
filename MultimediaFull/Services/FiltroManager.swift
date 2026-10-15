import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// Aplica filtros de color a una foto con Core Image (ejemplo "Filtros", día 1).
///
/// Capa MVVM: **Service** (manager). Recibe una imagen y un `Filtro` y devuelve
/// la imagen filtrada. No guarda nada de la pantalla; eso lo hace `FiltrosViewModel`.
///
/// Core Image es el framework de Apple para procesar imágenes: trae cientos de filtros listos.
/// `CIFilterBuiltins` nos deja crearlos con nombres claros, como `CIFilter.sepiaTone()`.
///
/// Es un singleton: se usa siempre la misma instancia con `FiltroManager.shared`.
/// Tiene sentido porque no guarda estado de ninguna pantalla, y así el `CIContext`
/// (que es caro de crear) se comparte en toda la app.
final class FiltroManager {
    /// `static let shared` crea una única instancia que vive toda la app.
    /// `static` significa que pertenece al tipo, no a cada objeto.
    static let shared = FiltroManager()

    // Crear un CIContext es caro, por eso se crea una sola vez y se reutiliza.
    // El `CIContext` es el "motor" que hace el cálculo real de los filtros
    // (puede usar la tarjeta gráfica). Crearlo en cada filtro haría la app lenta.
    private let contexto = CIContext()

    /// `private init()` impide que alguien escriba `FiltroManager()` desde fuera.
    /// Así te aseguras de que solo exista `shared`.
    private init() {}

    // MARK: - Acciones

    /// Devuelve una copia de `imagen` con el `filtro` aplicado.
    /// Si el filtro es `.original` o algo falla, devuelve la imagen tal cual.
    func aplicar(_ filtro: Filtro, a imagen: UIImage) -> UIImage {
        // Core Image no trabaja con UIImage, sino con su propio tipo: CIImage.
        // Si es el filtro original no hay nada que hacer, así que salimos rápido.
        guard filtro != .original, let entrada = CIImage(image: imagen) else { return imagen }

        // Declaramos `salida` sin valor; cada caso del switch le da uno.
        // Es opcional (`CIImage?`) porque `outputImage` puede ser nil.
        let salida: CIImage?

        // `switch` sobre un enum obliga a cubrir todos los casos.
        // Por eso aparece `.original` aunque el guard de arriba ya lo descartó.
        // En cada caso: creas el filtro, le das la imagen de entrada,
        // ajustas sus opciones (si tiene) y lees la imagen de salida.
        switch filtro {
        case .original:
            return imagen
        case .sepia:
            let f = CIFilter.sepiaTone()
            f.inputImage = entrada
            f.intensity = 0.9
            salida = f.outputImage
        case .mono:
            let f = CIFilter.photoEffectMono()
            f.inputImage = entrada
            salida = f.outputImage
        case .noir:
            let f = CIFilter.photoEffectNoir()
            f.inputImage = entrada
            salida = f.outputImage
        case .negativo:
            let f = CIFilter.colorInvert()
            f.inputImage = entrada
            salida = f.outputImage
        }

        // Hasta aquí el filtro es solo una "receta"; el contexto la ejecuta
        // y produce una imagen de verdad (CGImage). `extent` es el tamaño de la imagen.
        // Al final la convertimos a UIImage conservando la escala y la orientación
        // de la original; si no, una foto vertical podría salir girada.
        guard let salida,
              let cg = contexto.createCGImage(salida, from: salida.extent) else { return imagen }
        return UIImage(cgImage: cg, scale: imagen.scale, orientation: imagen.imageOrientation)
    }
}
