import AVFoundation

/// Reproduce un archivo de audio (ejemplos "Reproductor de audio" y "Grabadora", día 2).
///
/// Capa MVVM: **Service** (manager). Sabe cargar, reproducir, pausar y mover el audio.
/// El ViewModel decide qué sonido tocar y guarda el estado que ve la pantalla.
///
/// Usa `AVAudioPlayer`, la clase de AVFoundation para reproducir archivos de audio locales.
///
/// - `class` (y no `struct`) porque maneja un recurso vivo y debe compartirse por referencia.
/// - `NSObject` es la clase base de los objetos de Apple más antiguos (Objective-C);
///   AVFoundation la exige para ser su delegado.
/// - `AVAudioPlayerDelegate` es un protocolo delegado: funciones que el reproductor
///   llama para avisarnos cosas, como "ya terminé".
///
/// No es un singleton: cada pantalla crea el suyo con `ReproductorAudioManager()`.
/// Así cada pantalla tiene su propio reproductor y no se pisan entre ellas.
final class ReproductorAudioManager: NSObject, AVAudioPlayerDelegate {

    // MARK: - Estado

    /// El reproductor del archivo cargado. Es opcional porque al inicio no hay ninguno.
    private var reproductor: AVAudioPlayer?

    /// Se llama cuando el audio llega a su final.
    /// Es un closure: un bloque de código que el ViewModel guarda aquí para que lo ejecutemos.
    /// `() -> Void` significa que no recibe nada y no devuelve nada.
    var alTerminar: (() -> Void)?

    // Propiedades calculadas: le preguntan al reproductor cada vez que alguien las lee.
    // Si no hay reproductor (`?.` da nil), usamos un valor por defecto con `??`.

    /// Duración total del audio en segundos.
    var duracion: TimeInterval { reproductor?.duration ?? 0 }

    /// Segundo en el que va la reproducción.
    var tiempoActual: TimeInterval { reproductor?.currentTime ?? 0 }

    /// true mientras el audio está sonando.
    var estaReproduciendo: Bool { reproductor?.isPlaying ?? false }

    // MARK: - Acciones

    /// Prepara un archivo para reproducirlo. Puede fallar (`throws`) si el archivo
    /// no existe o no es un audio válido; quien la llama usa `try`.
    func cargar(_ url: URL) throws {
        // La sesión de audio le dice a iOS para qué usará el audio la app.
        // `.playback` significa "voy a reproducir": el sonido se oye aunque el
        // interruptor de silencio del iPhone esté activado.
        let sesion = AVAudioSession.sharedInstance()
        try sesion.setCategory(.playback)
        try sesion.setActive(true)

        // Creamos el reproductor y nos ponemos como su delegado (`self`)
        // para enterarnos cuando termine. `prepareToPlay()` carga el audio
        // por adelantado para que empiece a sonar sin retraso.
        reproductor = try AVAudioPlayer(contentsOf: url)
        reproductor?.delegate = self
        reproductor?.prepareToPlay()
    }

    /// Empieza o continúa la reproducción.
    func reproducir() {
        reproductor?.play()
    }

    /// Pausa sin perder la posición; al reproducir sigue donde se quedó.
    func pausar() {
        reproductor?.pause()
    }

    /// Detiene y regresa al inicio. `stop()` no regresa solo, por eso ponemos el tiempo en 0.
    func detener() {
        reproductor?.stop()
        reproductor?.currentTime = 0
    }

    /// Salta a un segundo concreto (por ejemplo, al mover la barra de progreso).
    func ir(a tiempo: TimeInterval) {
        reproductor?.currentTime = tiempo
    }

    // MARK: - AVAudioPlayerDelegate

    /// La llama AVFoundation cuando el audio termina; no la llamamos nosotros.
    /// Solo reenvía el aviso al ViewModel ejecutando el closure `alTerminar`.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        alTerminar?()
    }
}
