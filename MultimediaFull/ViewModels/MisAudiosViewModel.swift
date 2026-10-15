import SwiftUI

/// ViewModel de la pantalla "Mis audios" (capa ViewModel de MVVM).
/// Deja importar audios desde la app Archivos, los copia a Documents/Audios
/// y permite escucharlos o borrarlos. Los archivos los maneja el singleton
/// `AudioManager.shared` y el sonido un `ReproductorAudioManager` propio.
///
/// - `@MainActor`: todo corre en el hilo principal, donde vive la interfaz.
/// - `@Observable`: SwiftUI redibuja la vista cuando cambia alguna propiedad.
@MainActor
@Observable
final class MisAudiosViewModel {
    // MARK: - Estado

    /// Controla si se muestra el selector de archivos del sistema.
    /// Es `var` normal porque la vista la cambia (botón) y el selector la regresa a false al cerrarse.
    var mostrandoImportador = false

    // `private(set)`: la vista puede leerlas, pero solo el ViewModel las cambia.

    /// Los audios guardados en la app. Se reutiliza el modelo `Grabacion` (solo es un nombre de archivo).
    private(set) var audios: [Grabacion] = []
    /// Audio que suena en este momento; nil = ninguno.
    private(set) var reproduciendo: Grabacion?
    /// Texto para el usuario cuando algo sale mal. Vacío = sin errores.
    private(set) var mensaje = ""

    /// El reproductor de audio. `@ObservationIgnored`: SwiftUI no lo vigila
    /// porque es una herramienta interna, no algo que se dibuje.
    @ObservationIgnored private let reproductor = ReproductorAudioManager()

    /// Solo conecta el aviso de "terminó el audio"; la lista se carga cuando aparece la vista.
    init() {
        // Closure que el reproductor ejecuta al terminar el audio.
        // `[weak self]` evita que el reproductor retenga al ViewModel en memoria,
        // y `Task { @MainActor in ... }` regresa al hilo principal antes de tocar el estado.
        reproductor.alTerminar = { [weak self] in
            Task { @MainActor in self?.reproduciendo = nil }
        }
    }

    // MARK: - Lista e importación

    /// Lee del disco la lista de audios. La vista lo llama al aparecer.
    func cargar() {
        audios = AudioManager.shared.listar()
    }

    /// Recibe el resultado del selector de archivos y copia cada audio a Documents/Audios.
    /// `Result` es un enum con dos casos: `.success` (trae las URLs elegidas)
    /// o `.failure` (trae un error).
    func importar(_ resultado: Result<[URL], Error>) {
        // `guard case .success(let urls)`: si el resultado es éxito, saca
        // las URLs en la constante `urls`; si no, muestra el aviso y sale.
        guard case .success(let urls) = resultado else {
            mensaje = "No se pudo abrir el archivo."
            return
        }
        // Cuentas cuántos audios no se pudieron copiar para avisarle al usuario al final.
        var fallidos = 0
        for url in urls {
            // Los archivos de fuera de la app piden "abrir el candado" mientras se leen.
            // iOS protege los archivos de otras apps; sin este permiso no podrías copiarlos.
            let acceso = url.startAccessingSecurityScopedResource()
            // `defer` se ejecuta al final de cada vuelta del ciclo, pase lo que pase.
            // Así nunca se te olvida "cerrar el candado".
            defer {
                if acceso { url.stopAccessingSecurityScopedResource() }
            }
            // Si la copia falla, sumas uno a `fallidos` y sigues con el siguiente archivo.
            do {
                _ = try AudioManager.shared.importar(desde: url)
            } catch {
                fallidos += 1
            }
        }
        // Si todo salió bien, el mensaje queda vacío; si no, dices cuántos fallaron.
        mensaje = fallidos == 0 ? "" : "No se pudieron importar \(fallidos) audio(s)."
        cargar()
    }

    // MARK: - Reproducir y borrar

    /// Toca un audio; si ya estaba sonando, lo detiene.
    func reproducir(_ audio: Grabacion) {
        if reproduciendo == audio {
            detenerReproduccion()
            return
        }
        // `do-catch`: si cargar el archivo falla, conviertes el error en un mensaje.
        do {
            try reproductor.cargar(AudioManager.shared.url(de: audio.nombre))
            reproductor.reproducir()
            reproduciendo = audio
            mensaje = ""
        } catch {
            mensaje = "No se pudo reproducir este audio."
        }
    }

    /// Borra un audio del disco. Si estaba sonando, primero lo detiene.
    func eliminar(_ audio: Grabacion) {
        if reproduciendo == audio {
            detenerReproduccion()
        }
        AudioManager.shared.borrar(audio.nombre)
        cargar()
    }

    /// Calla el audio. No es `private` porque la vista lo llama al salir de la pantalla.
    func detenerReproduccion() {
        reproductor.detener()
        reproduciendo = nil
    }
}
