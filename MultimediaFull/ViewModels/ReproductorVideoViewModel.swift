import AVFoundation
import SwiftUI

/// ViewModel de la pantalla "Reproductor de video" (capa ViewModel de MVVM).
/// Guarda qué video de internet está elegido y le pide al
/// `ReproductorVideoManager` que lo cargue y lo reproduzca.
/// Los controles (play, pausa, barra) ya los trae `VideoPlayer` en la vista.
///
/// - `@MainActor`: todo corre en el hilo principal, donde vive la interfaz.
/// - `@Observable`: SwiftUI redibuja la vista cuando cambia alguna propiedad.
@MainActor
@Observable
final class ReproductorVideoViewModel {
    // MARK: - Estado

    /// Los videos que se pueden elegir (direcciones públicas de prueba).
    let fuentes = FuenteVideo.todas
    /// El video elegido en el Picker. Es `var` normal porque la vista
    /// la cambia directamente con un binding (`$`). Empieza con el primero.
    var seleccionada = FuenteVideo.todas[0]

    /// El manager que controla el video. `@ObservationIgnored`: SwiftUI no lo
    /// vigila porque es una herramienta interna, no algo que se dibuje.
    @ObservationIgnored private let reproductor = ReproductorVideoManager()

    /// El AVPlayer que muestra VideoPlayer en la vista.
    /// Propiedad calculada: devuelve el player del manager cada vez que la lees.
    var player: AVPlayer { reproductor.player }

    // MARK: - Acciones

    /// Carga el video elegido y lo empieza a reproducir.
    func cambiar(a fuente: FuenteVideo) {
        reproductor.cargar(fuente.url)
        reproductor.reproducir()
    }

    /// Pausa el video. La vista lo llama al salir para que no siga sonando.
    func pausar() {
        reproductor.pausar()
    }
}
