import SwiftUI

/// ViewModel de la pantalla "Reproductor de audio" (capa ViewModel de MVVM).
/// Toca los sonidos incluidos en la app (carpeta Recursos), con pausa,
/// detener y una barra para moverte por el audio. Guarda ese estado
/// y le pasa las órdenes al `ReproductorAudioManager`.
///
/// - `@MainActor`: todo corre en el hilo principal, donde vive la interfaz.
/// - `@Observable`: SwiftUI redibuja la vista cuando cambia alguna propiedad.
@MainActor
@Observable
final class ReproductorAudioViewModel {
    // MARK: - Estado

    /// La lista fija de sonidos que muestra la pantalla.
    let sonidos = Sonido.todos

    // `private(set)`: la vista puede leerlas, pero solo el ViewModel las cambia.

    /// Sonido cargado en el reproductor; nil = ninguno todavía.
    private(set) var actual: Sonido?
    /// true mientras suena; sirve para mostrar el botón de play o de pausa.
    private(set) var reproduciendo = false
    /// Segundo en el que va el audio (para la barra de avance).
    private(set) var tiempoActual: TimeInterval = 0
    /// Duración total del audio, en segundos.
    private(set) var duracion: TimeInterval = 0
    /// Texto para el usuario cuando algo sale mal. Vacío = sin errores.
    private(set) var mensaje = ""

    // `@ObservationIgnored`: SwiftUI no vigila estas propiedades porque
    // son herramientas internas, no algo que se dibuje.

    /// El manager que toca el audio. Es un recurso vivo, por eso se crea aquí.
    @ObservationIgnored private let reproductor = ReproductorAudioManager()
    /// Tarea que actualiza la barra de avance. Se guarda para poder cancelarla.
    @ObservationIgnored private var seguimiento: Task<Void, Never>?
    /// true mientras el usuario arrastra la barra. Mientras tanto, el seguimiento
    /// no toca `tiempoActual` para que la barra no "brinque" bajo el dedo.
    @ObservationIgnored private var arrastrando = false

    init() {
        // El manager avisa cuando el audio termina; saltamos al hilo principal para tocar el estado.
        // `[weak self]` evita que el manager retenga al ViewModel en memoria.
        reproductor.alTerminar = { [weak self] in
            Task { @MainActor in self?.terminoElSonido() }
        }
    }

    // MARK: - Acciones

    /// Toca un sonido. Si ya es el actual, alterna entre pausa y reproducción.
    func tocar(_ sonido: Sonido) {
        if sonido == actual {
            alternar()
            return
        }
        // `guard let`: si `sonido.url` tiene valor, lo guarda en `url`;
        // si es nil (el archivo no está en el proyecto), avisa y sale.
        guard let url = sonido.url else {
            mensaje = "No se encontró \(sonido.archivo).wav. ¿Lo agregaste al proyecto?"
            return
        }
        // `do-catch`: si cargar el audio falla, el error se vuelve un mensaje.
        do {
            try reproductor.cargar(url)
            actual = sonido
            duracion = reproductor.duracion
            mensaje = ""
            reproductor.reproducir()
            reproduciendo = true
            iniciarSeguimiento()
        } catch {
            mensaje = "No se pudo reproducir el sonido."
        }
    }

    /// Botón de play/pausa: si suena, pausa; si está en pausa, reanuda.
    /// Mientras está en pausa no hace falta actualizar la barra, por eso se cancela el seguimiento.
    func alternar() {
        if reproduciendo {
            reproductor.pausar()
            reproduciendo = false
            seguimiento?.cancel()
        } else {
            reproductor.reproducir()
            reproduciendo = true
            iniciarSeguimiento()
        }
    }

    /// Detiene el audio y regresa la barra al inicio.
    func detener() {
        reproductor.detener()
        reproduciendo = false
        seguimiento?.cancel()
        tiempoActual = 0
    }

    /// Mueve el audio a otro punto (la vista lo llama al arrastrar el Slider).
    /// También actualizas `tiempoActual` de inmediato para que la barra no "brinque"
    /// mientras esperas la siguiente lectura del seguimiento.
    func ir(a tiempo: TimeInterval) {
        reproductor.ir(a: tiempo)
        tiempoActual = tiempo
    }

    /// La vista avisa cuando el usuario empieza (true) o termina (false) de arrastrar la barra.
    func cambiarArrastre(_ activo: Bool) {
        arrastrando = activo
    }

    // MARK: - Ayudantes

    /// Se llama cuando el audio llega a su final: deja todo como recién detenido.
    private func terminoElSonido() {
        reproduciendo = false
        seguimiento?.cancel()
        tiempoActual = 0
    }

    /// Cada 0.2 segundos copia el tiempo del reproductor para que la barra avance.
    private func iniciarSeguimiento() {
        // Cancelas la tarea anterior (si había) para no tener dos a la vez.
        seguimiento?.cancel()
        // `Task { ... }` corre este ciclo sin congelar la pantalla. Como la clase
        // es @MainActor, puede cambiar `tiempoActual` con seguridad.
        seguimiento = Task {
            // Se repite hasta que alguien llame a `seguimiento?.cancel()`.
            while !Task.isCancelled {
                // Si el usuario está arrastrando la barra, manda su dedo, no el reproductor.
                if !arrastrando {
                    tiempoActual = reproductor.tiempoActual
                }
                // `await` pausa sin bloquear; `try?` ignora el error de cancelación.
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }
}
