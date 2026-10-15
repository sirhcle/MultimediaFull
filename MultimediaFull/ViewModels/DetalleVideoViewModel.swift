import AVFoundation
import SwiftUI

/// ViewModel de la pantalla que reproduce un video guardado a pantalla completa
/// (capa ViewModel de MVVM). La usa `DetalleVideoView`, que se abre desde la Videoteca.
///
/// Es el ViewModel más sencillo de la app: solo le pasa las órdenes
/// (abrir, reproducir, pausar) al `ReproductorVideoManager`.
///
/// - `@MainActor`: todo corre en el hilo principal, donde vive la interfaz.
/// - `@Observable`: SwiftUI redibuja la vista cuando cambia alguna propiedad.
@MainActor
@Observable
final class DetalleVideoViewModel {
    // MARK: - Estado

    /// El manager que controla el video. Es un recurso vivo, por eso se crea aquí.
    /// `@ObservationIgnored`: SwiftUI no lo vigila porque es una herramienta interna.
    @ObservationIgnored private let reproductor = ReproductorVideoManager()

    /// El AVPlayer que muestra `VideoPlayer` en la vista.
    /// Propiedad calculada: devuelve el player del manager cada vez que la lees.
    var player: AVPlayer { reproductor.player }

    // MARK: - Acciones

    /// Carga el video y lo empieza a reproducir. La vista lo llama al aparecer.
    func abrir(_ url: URL) {
        reproductor.cargar(url)
        reproductor.reproducir()
    }

    /// Pausa el video. La vista lo llama al cerrarse para que no siga sonando.
    func cerrar() {
        reproductor.pausar()
    }
}
