import AVFoundation

/// Graba la voz del usuario con el micrófono (ejemplo "Grabadora", día 2).
///
/// Capa MVVM: **Service** (manager). Sabe encender y apagar la grabación;
/// `GrabadoraViewModel` decide cuándo y dónde guardar cada archivo.
///
/// Usa `AVAudioRecorder`, la clase de AVFoundation que graba audio a un archivo.
///
/// Es una `class` (se comparte por referencia) porque maneja un recurso vivo: el micrófono.
/// No es un singleton: cada pantalla crea el suyo con `GrabadoraManager()`,
/// y la grabadora se libera cuando la pantalla se cierra.
final class GrabadoraManager {

    // MARK: - Estado

    /// La grabadora actual. Es opcional (`?`) porque solo existe mientras grabas.
    private var grabadora: AVAudioRecorder?

    // Propiedades calculadas: preguntan a la grabadora cada vez que alguien las lee.
    // `?.` llama solo si la grabadora existe; `?? valor` da un valor por defecto si es nil.

    /// true mientras se está grabando.
    var estaGrabando: Bool { grabadora?.isRecording ?? false }

    /// Segundos grabados hasta ahora. El ViewModel lo lee cada 200 ms para mostrar el tiempo.
    var tiempo: TimeInterval { grabadora?.currentTime ?? 0 }

    // MARK: - Acciones

    /// Pide permiso de micrófono. iOS muestra el aviso solo la primera vez.
    /// Es `async`: espera la respuesta del usuario sin congelar la pantalla.
    func pedirPermiso() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    /// Empieza a grabar y guarda el audio en `url`.
    /// `throws` significa que puede fallar; quien la llama debe usar `try`
    /// (y normalmente `do-catch`) para atrapar el error.
    func empezar(en url: URL) throws {
        // `AVAudioSession` es la sesión de audio de la app: le dice a iOS cómo vas a usar el sonido.
        // `.playAndRecord` permite grabar y reproducir. `.defaultToSpeaker` hace que el sonido
        // salga por la bocina principal y no por la del oído (la de las llamadas).
        // `setActive(true)` activa la sesión con esos ajustes.
        let sesion = AVAudioSession.sharedInstance()
        try sesion.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try sesion.setActive(true)

        // Ajustes del archivo: es un diccionario (clave: valor).
        // - Formato AAC (archivo .m4a): suena bien y pesa poco.
        // - 44 100 muestras por segundo: calidad de CD.
        // - 1 canal (mono): para voz basta y el archivo pesa la mitad que en estéreo.
        // - Calidad alta del codificador.
        let ajustes: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        // Creamos la grabadora apuntando al archivo y empezamos a grabar.
        grabadora = try AVAudioRecorder(url: url, settings: ajustes)
        grabadora?.record()
    }

    /// Detiene la grabación. Al hacer `stop()` el archivo queda cerrado y listo para escucharse.
    /// Luego soltamos la grabadora (nil) porque cada grabación nueva crea una propia.
    func detener() {
        grabadora?.stop()
        grabadora = nil
    }
}
