import AVFoundation
import SwiftUI

/// ViewModel de la pantalla "Controles de video" (capa ViewModel de MVVM).
/// Además de reproducir un video, deja cambiar la velocidad, silenciar
/// y saltar 10 segundos. Guarda ese estado y le pasa las órdenes
/// al `ReproductorVideoManager`.
///
/// - `@MainActor`: todo corre en el hilo principal, donde vive la interfaz.
/// - `@Observable`: SwiftUI redibuja la vista cuando cambia alguna propiedad.
@MainActor
@Observable
final class ControlesVideoViewModel {
    // MARK: - Estado

    /// Velocidades que ofrece la pantalla.
    /// Es `let` porque nunca cambian. `Float` es un número con decimales.
    let velocidades: [Float] = [0.5, 1, 1.5, 2]

    // Estas dos son `var` normales (sin `private(set)`) porque la vista
    // las modifica directamente con un Picker y un Toggle mediante un binding (`$`).

    /// Velocidad elegida: 1 = normal, 2 = el doble de rápido.
    var velocidad: Float = 1
    /// true = el video suena sin volumen.
    var silenciado = false

    // `private(set)`: la vista las lee para mostrar el reloj, pero solo
    // el ViewModel las cambia. `TimeInterval` es un número de segundos.

    /// Segundo en el que va el video.
    private(set) var tiempoActual: TimeInterval = 0
    /// Cuánto dura el video completo, en segundos.
    private(set) var duracion: TimeInterval = 0

    // `@ObservationIgnored`: SwiftUI no vigila estas propiedades porque
    // son herramientas internas, no algo que se dibuje.

    /// El manager que controla el video. Es un recurso vivo, por eso se crea aquí.
    @ObservationIgnored private let reproductor = ReproductorVideoManager()
    /// La tarea que lee el tiempo del video una y otra vez.
    /// Se guarda para poder cancelarla después. Es opcional: nil = no hay tarea.
    @ObservationIgnored private var seguimiento: Task<Void, Never>?

    /// El AVPlayer que muestra `VideoPlayer` en la vista.
    /// Propiedad calculada: devuelve el player del manager cada vez que la lees.
    var player: AVPlayer { reproductor.player }

    // MARK: - Acciones

    /// Carga el primer video de la lista y empieza a seguir su tiempo.
    func preparar() {
        reproductor.cargar(FuenteVideo.todas[0].url)
        reproductor.reproducir()

        // Si ya había una tarea de seguimiento, la cancelas para no tener dos.
        seguimiento?.cancel()
        // `Task { ... }` arranca un trabajo que corre "en paralelo" sin congelar la pantalla.
        // Como la clase es @MainActor, la tarea también corre en el hilo principal
        // y puede cambiar `tiempoActual` sin problema.
        seguimiento = Task {
            // El ciclo se repite hasta que alguien llame a `cancel()`.
            while !Task.isCancelled {
                // AVPlayer no avisa solo de su tiempo, así que lo copias
                // aquí para que el reloj de la pantalla se actualice.
                tiempoActual = reproductor.tiempoActual
                duracion = reproductor.duracion
                // Espera 0.2 segundos antes de volver a leer.
                // `await` pausa la tarea sin bloquear la app; `try?` ignora
                // el error que lanza `sleep` cuando la tarea se cancela.
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }

    /// Aplica la velocidad elegida. La vista lo llama cuando cambia el Picker.
    func cambiarVelocidad() {
        reproductor.cambiarVelocidad(velocidad)
    }

    /// Aplica el silencio elegido. La vista lo llama cuando cambia el Toggle.
    func cambiarSilencio() {
        reproductor.silenciado = silenciado
    }

    /// Salta hacia adelante (positivo) o hacia atrás (negativo).
    /// Por ejemplo, `saltar(segundos: -10)` regresa 10 segundos.
    func saltar(segundos: TimeInterval) {
        reproductor.ir(a: reproductor.tiempoActual + segundos)
    }

    /// Pausa el video y detiene el seguimiento. La vista lo llama al salir.
    /// Si no cancelas la tarea, seguiría corriendo aunque ya no veas la pantalla.
    func terminar() {
        reproductor.pausar()
        seguimiento?.cancel()
    }
}
