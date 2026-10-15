import SwiftUI
import AVFoundation

/// Puente mínimo entre SwiftUI y la vista previa de la cámara (capa View de MVVM).
/// SwiftUI no tiene una vista propia para mostrar la cámara, así que se envuelve la de AVFoundation.
/// Es el único puente de este tipo en el proyecto; el resto de la app es SwiftUI puro.
/// La usa `CamaraView` para mostrar en vivo lo que ve la cámara.
///
/// `UIViewRepresentable` es el protocolo que convierte una vista de UIKit
/// (el sistema de interfaz anterior a SwiftUI) en algo que SwiftUI sabe dibujar.
/// Pide dos funciones: `makeUIView` (crearla) y `updateUIView` (actualizarla).
struct VistaPreviaCamara: UIViewRepresentable {
    /// La sesión de captura que trae la imagen de la cámara. Se la pasa `CamaraView`.
    let sesion: AVCaptureSession

    // MARK: - UIViewRepresentable

    /// SwiftUI la llama una sola vez, cuando la vista aparece por primera vez.
    func makeUIView(context: Context) -> VistaCamaraUIView {
        let vista = VistaCamaraUIView()
        // Conectas la capa de vista previa con la sesión: desde aquí ya se ve la cámara.
        vista.previewLayer.session = sesion
        // `.resizeAspectFill` llena todo el espacio sin deformar la imagen (recorta las orillas).
        vista.previewLayer.videoGravity = .resizeAspectFill
        return vista
    }

    /// SwiftUI la llama cuando cambian los datos. Aquí no hay nada que actualizar,
    /// porque la sesión es siempre la misma; por eso queda vacía.
    func updateUIView(_ uiView: VistaCamaraUIView, context: Context) {}
}

/// Vista cuya capa es directamente la capa de vista previa de la cámara.
/// Toda `UIView` dibuja sobre una "capa" (`layer`). Aquí cambias el tipo de esa capa
/// para que sea la de la cámara; así siempre mide lo mismo que la vista,
/// incluso al girar el teléfono, sin que tengas que ajustar su tamaño a mano.
final class VistaCamaraUIView: UIView {
    /// `layerClass` le dice a UIKit qué tipo de capa crear para esta vista.
    /// `override` indica que reemplazas la versión que trae `UIView`.
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    /// La capa ya convertida a su tipo real, para poder usar `session` y `videoGravity`.
    /// `as!` fuerza la conversión; aquí es seguro porque `layerClass` garantiza el tipo.
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
