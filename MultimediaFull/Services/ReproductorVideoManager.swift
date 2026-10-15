import AVFoundation

/// Reproduce video desde una dirección (URL) de internet o de un archivo
/// (ejemplos "Reproductor de video" y "Controles de video", día 3).
///
/// Capa MVVM: **Service** (manager). Envuelve a `AVPlayer` y ofrece acciones
/// con nombres en español (reproducir, pausar, ir a...). El ViewModel lo usa
/// y guarda el estado que dibuja la pantalla.
///
/// Es una `class` porque maneja un recurso vivo (el reproductor) que se comparte por referencia.
/// No es un singleton: cada pantalla crea el suyo con `ReproductorVideoManager()`,
/// así el video se detiene y se libera al cerrar la pantalla.
final class ReproductorVideoManager {

    // MARK: - Estado

    /// El AVPlayer se muestra en pantalla con VideoPlayer(player:).
    /// `AVPlayer` es el reproductor de AVFoundation: carga el video, lo decodifica y lleva el tiempo.
    /// Es `let` porque siempre usamos el mismo reproductor; solo cambiamos el video que tiene dentro.
    let player = AVPlayer()

    // Las duraciones de AVFoundation pueden venir como "indefinidas" (NaN) mientras el video carga.
    // `isFinite` revisa que sea un número normal; si no, devolvemos 0 para no romper la barra.

    /// Duración total del video en segundos (0 si todavía no se sabe).
    var duracion: TimeInterval {
        let segundos = player.currentItem?.duration.seconds ?? 0
        return segundos.isFinite ? segundos : 0
    }

    /// Segundo en el que va el video.
    var tiempoActual: TimeInterval {
        let segundos = player.currentTime().seconds
        return segundos.isFinite ? segundos : 0
    }

    /// `rate` es la velocidad actual: 0 = detenido, 1 = normal. Si no es 0, está reproduciendo.
    var estaReproduciendo: Bool { player.rate != 0 }

    /// Propiedad calculada con `get` y `set`: se puede leer y también asignar.
    /// `get` devuelve el valor; `set` recibe el nuevo valor en `newValue`.
    /// Así el ViewModel escribe `silenciado = true` sin conocer los detalles del AVPlayer.
    var silenciado: Bool {
        get { player.isMuted }
        set { player.isMuted = newValue }
    }

    // MARK: - Acciones

    /// Pone un video nuevo en el reproductor. `AVPlayerItem` representa "un video para reproducir".
    /// El video se descarga poco a poco (streaming); no hace falta bajarlo completo.
    func cargar(_ url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
    }

    /// Empieza o continúa la reproducción.
    func reproducir() {
        player.play()
    }

    /// Pausa sin perder la posición.
    func pausar() {
        player.pause()
    }

    /// Salta a un segundo concreto del video.
    /// AVFoundation mide el tiempo con `CMTime`, no con segundos sueltos.
    /// `preferredTimescale: 600` es la precisión (600 partes por segundo), un valor común en video.
    /// `max(tiempo, 0)` evita pedir un tiempo negativo (por ejemplo, al retroceder 10 s al inicio).
    func ir(a tiempo: TimeInterval) {
        player.seek(to: CMTime(seconds: max(tiempo, 0), preferredTimescale: 600))
    }

    /// Velocidad de reproducción: 1 = normal, 2 = el doble de rápido.
    func cambiarVelocidad(_ velocidad: Float) {
        // defaultRate es la velocidad que usa el botón de play de los controles del sistema.
        // Si el video ya está sonando, cambiamos también `rate` para que se note al instante.
        player.defaultRate = velocidad
        if estaReproduciendo {
            player.rate = velocidad
        }
    }
}
