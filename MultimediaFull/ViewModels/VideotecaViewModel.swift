import SwiftUI
import PhotosUI

/// ViewModel de la pantalla "Videoteca" (capa ViewModel de MVVM).
/// Deja elegir videos de la galería del teléfono, los copia a Documents/Videos,
/// los lista con su miniatura y abre el que toques a pantalla completa.
/// Los archivos los maneja el singleton `VideoManager.shared`.
///
/// - `@MainActor`: todo corre en el hilo principal, donde vive la interfaz.
/// - `@Observable`: SwiftUI redibuja la vista cuando cambia alguna propiedad.
@MainActor
@Observable
final class VideotecaViewModel {
    // MARK: - Estado

    /// Los videos que el usuario marcó en el `PhotosPicker`.
    /// `PhotosPickerItem` todavía no es el video: es una "promesa" que luego se carga.
    /// Es `var` normal porque el selector la llena a través de un binding (`$`).
    var seleccion: [PhotosPickerItem] = []

    /// Video que se reproduce en pantalla completa; nil = ninguno.
    /// Cuando le das un valor, la vista abre el `.fullScreenCover`; al cerrarlo vuelve a nil.
    var videoAbierto: VideoGuardado?

    /// Los videos guardados en la app. `private(set)`: la vista solo los lee.
    private(set) var videos: [VideoGuardado] = []
    /// Texto para el usuario cuando algo sale mal. Vacío = sin errores.
    private(set) var mensaje = ""

    // MARK: - Acciones

    /// Lee del disco la lista de videos. La vista lo llama al aparecer.
    func cargar() {
        // `listar()` devuelve nombres de archivo; `map` convierte cada nombre
        // (`$0`) en un `VideoGuardado`.
        videos = VideoManager.shared.listar().map { VideoGuardado(nombre: $0) }
    }

    /// Copia a Documents/Videos cada video elegido y actualiza la lista.
    /// Es `async` porque sacar un video de la galería tarda; con `await` esperas sin congelar la app.
    func guardar(_ items: [PhotosPickerItem]) async {
        // Si no hay nada que guardar, sales. Pasa justo después de vaciar
        // `seleccion` al final de esta función.
        guard !items.isEmpty else { return }

        // Cuentas cuántos videos no se pudieron guardar para avisarle al usuario al final.
        var fallidos = 0
        for item in items {
            // `loadTransferable` pide el video como `PeliculaElegida` (un archivo temporal).
            // `guard let` + `try?`: si no se pudo cargar, lo cuentas como fallido
            // y `continue` salta al siguiente video.
            guard let pelicula = try? await item.loadTransferable(type: PeliculaElegida.self) else {
                fallidos += 1
                continue
            }
            do {
                _ = try VideoManager.shared.guardar(desde: pelicula.url)
            } catch {
                fallidos += 1
            }
            // La copia temporal ya no hace falta, se haya guardado o no.
            // Borrarla evita que los videos ocupen el doble de espacio.
            try? FileManager.default.removeItem(at: pelicula.url)
        }
        // Si todo salió bien, el mensaje queda vacío; si no, dices cuántos fallaron.
        mensaje = fallidos == 0 ? "" : "No se pudieron guardar \(fallidos) video(s)."
        cargar()
        // Vacías la selección para que el selector quede limpio la próxima vez.
        seleccion = []
    }

    /// Genera la imagen de vista previa de un video. Es `async` porque
    /// leer un cuadro del video toma tiempo. Devuelve nil si no se pudo.
    func miniatura(para video: VideoGuardado) async -> UIImage? {
        await VideoManager.shared.miniatura(de: video.nombre)
    }

    /// Arma la ruta completa del video a partir de su nombre.
    /// Solo se guarda el nombre porque la carpeta de la app cambia entre instalaciones.
    func url(de video: VideoGuardado) -> URL {
        VideoManager.shared.url(de: video.nombre)
    }

    /// Borra un video del disco y actualiza la lista.
    func eliminar(_ video: VideoGuardado) {
        VideoManager.shared.borrar(video.nombre)
        cargar()
    }
}
