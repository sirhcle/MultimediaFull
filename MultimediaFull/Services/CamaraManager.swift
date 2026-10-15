import AVFoundation
import UIKit

/// Maneja la cámara del dispositivo para mostrar la vista previa y tomar fotos
/// (ejemplo "Cámara", día 3).
///
/// Capa MVVM: **Service** (manager). Hace el trabajo con la cámara; quien decide
/// cuándo usarla es `CamaraViewModel`. La vista nunca habla con este manager.
///
/// Solo funciona en un iPhone o iPad reales: el simulador no tiene cámara.
///
/// - `class` (y no `struct`): una clase se comparte por referencia. Todos los que
///   la usan ven el mismo objeto, y eso es lo que queremos con un recurso vivo como la cámara.
/// - `final` significa que nadie puede heredar de esta clase. Lo ponemos porque no lo necesitamos.
/// - `NSObject` es la clase base de los objetos de Apple más antiguos (Objective-C).
///   AVFoundation la exige para poder ser su delegado.
/// - `AVCapturePhotoCaptureDelegate` es un protocolo "delegado": una lista de funciones
///   que la cámara llamará para avisarnos cosas (por ejemplo, "ya terminé la foto").
///
/// No es un singleton (`shared`): cada pantalla crea el suyo con `CamaraManager()`.
/// Así, al salir de la pantalla, la cámara se libera junto con su ViewModel.
final class CamaraManager: NSObject, AVCapturePhotoCaptureDelegate {

    // MARK: - Estado

    /// La sesión conecta la cámara (entrada) con la captura de fotos (salida).
    /// `AVCaptureSession` es el "director de orquesta": mientras está corriendo,
    /// recibe imágenes de la cámara y las reparte a la vista previa y a la salida.
    let sesion = AVCaptureSession()

    /// Salida de la sesión que sabe tomar fotos fijas.
    private let salida = AVCapturePhotoOutput()

    /// Recuerda si ya configuramos la sesión, para no hacerlo dos veces.
    private var configurada = false

    /// Closure (bloque de código guardado en una variable) que se ejecuta cuando la foto está lista.
    /// Recibe la imagen y no devuelve nada (`-> Void`). Es opcional (`?`) porque al inicio no hay ninguno.
    private var alCapturar: ((UIImage) -> Void)?

    /// Dice si el dispositivo tiene cámara. El simulador no tiene, así que aquí devuelve false.
    /// Es una propiedad calculada: no guarda nada, pregunta cada vez que alguien la lee.
    var hayCamara: Bool {
        AVCaptureDevice.default(for: .video) != nil
    }

    // MARK: - Acciones

    /// Pide permiso para usar la cámara. iOS muestra el aviso solo la primera vez;
    /// después recuerda la respuesta del usuario.
    /// `async` indica que la función puede tardar (espera a que el usuario toque un botón).
    /// Quien la llama usa `await` para esperar el resultado sin congelar la pantalla.
    func pedirPermiso() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    /// Conecta la cámara trasera con la salida de fotos. Devuelve false si algo falla.
    func configurar() -> Bool {
        if configurada { return true }

        // `guard` revisa que todo esté bien; si no, sale de la función con el `else`.
        // `try?` intenta crear la entrada y, si hay error, da nil en lugar de lanzar el error.
        guard let dispositivo = AVCaptureDevice.default(for: .video),
              let entrada = try? AVCaptureDeviceInput(device: dispositivo) else { return false }

        // Los cambios a la sesión van entre beginConfiguration y commitConfiguration:
        // así iOS los aplica todos juntos, de una sola vez.
        // `.photo` pide la mejor calidad para fotos fijas.
        // Antes de agregar entrada o salida se pregunta si se puede (canAdd...).
        sesion.beginConfiguration()
        sesion.sessionPreset = .photo
        if sesion.canAddInput(entrada) { sesion.addInput(entrada) }
        if sesion.canAddOutput(salida) { sesion.addOutput(salida) }
        sesion.commitConfiguration()

        configurada = true
        return true
    }

    // startRunning y stopRunning bloquean el hilo, por eso se llaman fuera del hilo principal.
    // Si los llamáramos en el hilo principal, la pantalla se congelaría un momento.
    // `DispatchQueue.global(...).async { }` ejecuta el bloque en otro hilo, en segundo plano.
    // `.userInitiated` le dice a iOS que es importante porque el usuario está esperando.
    // Fíjate en `let sesion = sesion`: copiamos la sesión a una constante local para que
    // el bloque use esa copia y no tenga que tocar `self` desde otro hilo.

    /// Enciende la cámara (empieza a llegar imagen a la vista previa).
    func iniciar() {
        let sesion = sesion
        DispatchQueue.global(qos: .userInitiated).async {
            if !sesion.isRunning { sesion.startRunning() }
        }
    }

    /// Apaga la cámara. Se llama al salir de la pantalla para ahorrar batería.
    func detener() {
        let sesion = sesion
        DispatchQueue.global(qos: .userInitiated).async {
            if sesion.isRunning { sesion.stopRunning() }
        }
    }

    /// Pide una foto. La foto no llega de inmediato: cuando está lista, la cámara llama
    /// a `photoOutput(...)` (abajo) y ahí ejecutamos el closure `alCapturar`.
    /// `@escaping` significa que el closure se guarda para usarse más tarde,
    /// después de que esta función ya terminó.
    func tomarFoto(alCapturar: @escaping (UIImage) -> Void) {
        self.alCapturar = alCapturar
        // `delegate: self` le dice a la salida: "avísame a mí cuando termines".
        salida.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    /// La llama AVFoundation cuando la foto ya se procesó. No la llamamos nosotros.
    /// Convierte la foto en datos, los datos en `UIImage` y se la pasa al closure.
    /// Si algo falla, simplemente no hace nada.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let datos = photo.fileDataRepresentation(),
              let imagen = UIImage(data: datos) else { return }
        alCapturar?(imagen)
    }
}
