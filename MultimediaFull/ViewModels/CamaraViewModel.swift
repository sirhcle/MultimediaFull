import AVFoundation
import SwiftUI

/// ViewModel de la pantalla "Cámara" (capa ViewModel de MVVM).
/// Guarda el estado que dibuja `CamaraView` (si la cámara está lista, el mensaje
/// y la última foto) y le pide al `CamaraManager` que haga el trabajo real.
/// Solo funciona en un iPhone o iPad reales; en el simulador muestra un aviso.
///
/// - `@MainActor`: todo lo de esta clase corre en el hilo principal, que es
///   el único donde se puede tocar lo que se ve en pantalla.
/// - `@Observable`: SwiftUI vigila sus propiedades y redibuja la vista
///   cada vez que una cambia.
/// - `final class`: nadie puede heredar de ella. Es una clase (y no un struct)
///   porque la vista y el manager comparten el mismo objeto.
@MainActor
@Observable
final class CamaraViewModel {
    // MARK: - Estado

    // `private(set)` significa: la vista puede LEER estos valores,
    // pero solo el ViewModel puede cambiarlos.

    /// true cuando la cámara ya tiene permiso, está configurada y encendida.
    private(set) var listo = false
    /// Texto para el usuario: errores o "Foto guardada". Vacío = nada que decir.
    private(set) var mensaje = ""
    /// La última foto tomada. Es opcional (`?`) porque al inicio no hay ninguna.
    private(set) var ultimaFoto: UIImage?

    /// El manager que habla con la cámara. Es un recurso "vivo", por eso
    /// se crea aquí y no es un singleton.
    /// `@ObservationIgnored` le dice a SwiftUI que no lo vigile: no es algo
    /// que se dibuje, es una herramienta interna.
    @ObservationIgnored private let camara = CamaraManager()

    /// La sesión de captura que necesita `VistaPreviaCamara` para mostrar la imagen.
    /// Es una propiedad calculada (computed property): no guarda nada,
    /// cada vez que la lees devuelve la sesión del manager.
    var sesion: AVCaptureSession { camara.sesion }

    // MARK: - Acciones

    /// Pide permiso, configura la sesión y arranca la vista previa.
    /// Es `async` porque pedir permiso espera a que el usuario toque
    /// "Permitir" o "No permitir"; con `await` esperas sin congelar la app.
    func preparar() async {
        // `guard` revisa una condición; si no se cumple, entra al `else`
        // y sale de la función con `return`. Así cada problema se trata
        // al inicio y el camino feliz queda al final, sin anidar `if`.
        guard camara.hayCamara else {
            mensaje = "Este dispositivo no tiene cámara. El simulador tampoco; usa un iPhone."
            return
        }
        guard await camara.pedirPermiso() else {
            mensaje = "Sin permiso de cámara. Actívalo en Ajustes."
            return
        }
        guard camara.configurar() else {
            mensaje = "No se pudo configurar la cámara."
            return
        }
        // Si llegaste aquí, todo salió bien: enciendes la cámara y avisas a la vista.
        camara.iniciar()
        listo = true
    }

    /// Toma una foto. El resultado no llega de inmediato: el manager
    /// llama al closure (el bloque entre llaves) cuando la foto está lista.
    func tomarFoto() {
        // `[weak self]`: el closure no "amarra" al ViewModel. Si el usuario
        // ya salió de la pantalla, `self` será nil y no pasa nada (`self?.`).
        camara.tomarFoto { [weak self] imagen in
            // La foto llega desde un hilo de AVFoundation. Con
            // `Task { @MainActor in ... }` vuelves al hilo principal
            // antes de tocar el estado que se ve en pantalla.
            Task { @MainActor in self?.guardar(imagen) }
        }
    }

    /// Apaga la cámara. La vista lo llama al salir de la pantalla
    /// para no gastar batería ni dejar la cámara encendida.
    func detener() {
        camara.detener()
    }

    // MARK: - Ayudantes

    /// Guarda la foto en el álbum de la app (Documents/Fotos) y avisa al usuario.
    private func guardar(_ imagen: UIImage) {
        // Se reduce antes de guardar para que el álbum no pese de más.
        // Una foto de iPhone puede medir más de 4000 px por lado; 2000 basta para verla bien.
        let reducida = imagen.reducida(maxLado: 2000)
        // `do-catch`: si guardar falla, avisas al usuario en vez de decirle que todo salió bien.
        // `_ =` indica que a propósito no usas el resultado (el nombre del archivo).
        do {
            _ = try FotoManager.shared.guardar(reducida)
            ultimaFoto = reducida
            mensaje = "Foto guardada en Mi álbum."
        } catch {
            mensaje = "No se pudo guardar la foto."
        }
    }
}
