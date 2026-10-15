import SwiftUI

/// ViewModel de la pantalla "Grabadora" (capa ViewModel de MVVM).
/// Graba audio con el micrófono, lista las grabaciones guardadas en
/// Documents/Audios y deja escucharlas o borrarlas.
/// Usa dos managers con recursos vivos (grabadora y reproductor) y el
/// singleton `AudioManager.shared` para los archivos.
///
/// - `@MainActor`: todo corre en el hilo principal, donde vive la interfaz.
/// - `@Observable`: SwiftUI redibuja la vista cuando cambia alguna propiedad.
@MainActor
@Observable
final class GrabadoraViewModel {
    // MARK: - Estado

    // `private(set)`: la vista puede leerlas, pero solo el ViewModel las cambia.

    /// Las grabaciones que hay en disco, para mostrarlas en la lista.
    private(set) var grabaciones: [Grabacion] = []
    /// true mientras el micrófono está grabando.
    private(set) var grabando = false
    /// Segundos que lleva la grabación actual (para el reloj en pantalla).
    private(set) var tiempoGrabacion: TimeInterval = 0

    /// Grabación que suena en este momento; nil = ninguna.
    private(set) var reproduciendo: Grabacion?
    /// Texto para el usuario cuando algo sale mal. Vacío = sin errores.
    private(set) var mensaje = ""

    // `@ObservationIgnored`: SwiftUI no vigila estas propiedades porque
    // son herramientas internas, no algo que se dibuje.

    /// Graba con el micrófono.
    @ObservationIgnored private let grabadora = GrabadoraManager()
    /// Reproduce las grabaciones.
    @ObservationIgnored private let reproductor = ReproductorAudioManager()
    /// Tarea que actualiza el reloj mientras grabas. Se guarda para poder cancelarla.
    @ObservationIgnored private var seguimiento: Task<Void, Never>?

    /// El `init` solo conecta el aviso de "terminó el audio"; no hace trabajo pesado.
    /// La lista se carga después, cuando la vista aparece.
    init() {
        // `alTerminar` es un closure: un bloque de código que el reproductor
        // guarda y ejecuta cuando el audio llega al final.
        // `[weak self]` evita que el reproductor "amarre" al ViewModel en memoria.
        reproductor.alTerminar = { [weak self] in
            // El aviso llega desde AVFoundation; vuelves al hilo principal antes de tocar el estado.
            Task { @MainActor in self?.reproduciendo = nil }
        }
    }

    // MARK: - Lista

    /// Lee del disco la lista de grabaciones. La vista lo llama al aparecer.
    func cargar() {
        grabaciones = AudioManager.shared.listar()
    }

    // MARK: - Grabar

    /// Botón de grabar: empieza si estaba detenido, termina si estaba grabando.
    /// Es `async` porque empezar puede esperar a que el usuario dé permiso del micrófono.
    func alternarGrabacion() async {
        if grabando {
            detenerGrabacion()
        } else {
            await empezarGrabacion()
        }
    }

    private func empezarGrabacion() async {
        // No se puede grabar y reproducir a la vez, así que primero callas lo que suene.
        detenerReproduccion()

        // `guard`: si no hay permiso, muestras el aviso y sales de la función.
        guard await grabadora.pedirPermiso() else {
            mensaje = "Sin permiso de micrófono. Actívalo en Ajustes."
            return
        }
        // `do-catch`: intentas algo que puede fallar (`try`). Si falla,
        // el código salta al `catch` y ahí conviertes el error en un mensaje.
        do {
            try grabadora.empezar(en: AudioManager.shared.nuevaURL())
            grabando = true
            tiempoGrabacion = 0
            mensaje = ""
            iniciarSeguimiento()
        } catch {
            mensaje = "No se pudo empezar a grabar."
        }
    }

    private func detenerGrabacion() {
        grabadora.detener()
        grabando = false
        seguimiento?.cancel()
        // Vuelves a leer el disco para que la grabación nueva aparezca en la lista.
        cargar()
    }

    // MARK: - Reproducir y borrar

    /// Toca una grabación; si ya estaba sonando, la detiene.
    func reproducir(_ grabacion: Grabacion) {
        // Puedes comparar con `==` porque `Grabacion` es `Hashable`.
        if reproduciendo == grabacion {
            detenerReproduccion()
            return
        }
        do {
            // Solo se guarda el nombre del archivo; la ruta completa se arma cada vez,
            // porque la carpeta de la app cambia entre instalaciones.
            try reproductor.cargar(AudioManager.shared.url(de: grabacion.nombre))
            reproductor.reproducir()
            reproduciendo = grabacion
        } catch {
            mensaje = "No se pudo reproducir la grabación."
        }
    }

    /// Borra una grabación del disco. Si estaba sonando, primero la detiene.
    func eliminar(_ grabacion: Grabacion) {
        if reproduciendo == grabacion {
            detenerReproduccion()
        }
        AudioManager.shared.borrar(grabacion.nombre)
        cargar()
    }

    /// La vista lo llama al salir de la pantalla.
    /// Así no se queda grabando ni sonando cuando ya no la ves.
    func detenerTodo() {
        if grabando {
            detenerGrabacion()
        }
        detenerReproduccion()
    }

    // MARK: - Ayudantes

    private func detenerReproduccion() {
        reproductor.detener()
        reproduciendo = nil
    }

    /// Cada 0.2 segundos copia el tiempo de la grabadora para que el reloj avance.
    private func iniciarSeguimiento() {
        // Cancelas la tarea anterior (si había) para no tener dos a la vez.
        seguimiento?.cancel()
        // `Task { ... }` corre este ciclo sin congelar la pantalla.
        // Sigue hasta que llamas a `seguimiento?.cancel()`.
        seguimiento = Task {
            while !Task.isCancelled {
                tiempoGrabacion = grabadora.tiempo
                // `await` pausa sin bloquear; `try?` ignora el error de cancelación.
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }
}
