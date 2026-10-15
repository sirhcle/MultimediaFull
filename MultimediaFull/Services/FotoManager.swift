// UIKit nos da UIImage y la función para convertirla a JPEG.
import UIKit

/// Guarda, carga, lista y borra las fotos como archivos JPEG en la carpeta Documents/Fotos.
///
/// Capa MVVM: **Service** (un "Manager"). Hace el trabajo con archivos para los
/// ViewModels de "Álbum", "Filtros" y "Cámara". Las vistas nunca lo llaman directo.
///
/// Como no guarda estado propio (solo trabaja con archivos), se usa como singleton:
/// una única instancia compartida, `FotoManager.shared`, igual que los managers del módulo 7.
struct FotoManager {
    // MARK: - Instancia compartida

    /// `static let shared` crea una sola instancia que vive mientras la app esté abierta.
    /// La usas así: `FotoManager.shared.guardar(imagen)`.
    static let shared = FotoManager()

    // MARK: - Configuración

    /// Carpeta Documents/Fotos dentro del sandbox (el espacio privado de tu app).
    /// `private` hace que solo se pueda usar dentro de este archivo.
    private let carpeta = URL.documentsDirectory.appending(path: "Fotos", directoryHint: .isDirectory)

    /// `private init()` impide crear otro `FotoManager()` desde fuera: solo existe `shared`.
    private init() {
        // Crea la carpeta si no existe. `try?` ignora el error si ya estaba creada.
        try? FileManager.default.createDirectory(at: carpeta, withIntermediateDirectories: true)
        // Solo mientras pruebas en Xcode: imprime en la consola dónde quedan las fotos.
        #if DEBUG
        print("Fotos guardadas en: \(carpeta.path())")
        #endif
    }

    /// Errores propios de este manager.
    /// Un `enum` que cumple `Error` se puede lanzar con `throw`.
    enum FotoError: Error {
        /// No se pudo convertir la imagen a JPEG.
        case conversionFallida
    }

    // MARK: - Acciones

    /// Guarda la imagen y devuelve el nombre del archivo (nunca la ruta completa).
    ///
    /// Solo devolvemos el nombre porque la ruta de Documents cambia entre instalaciones;
    /// con el nombre siempre puedes volver a armar la ruta correcta.
    ///
    /// `throws` avisa que puede fallar: quien la llama usa `try` dentro de un `do-catch`.
    func guardar(_ imagen: UIImage) throws -> String {
        // guard revisa una condición y, si no se cumple, sale de la función antes de seguir.
        // jpegData devuelve nil si no puede convertir; en ese caso lanzamos nuestro error.
        // 0.8 es la calidad (de 0 a 1): buena imagen y archivo más ligero.
        guard let data = imagen.jpegData(compressionQuality: 0.8) else {
            throw FotoError.conversionFallida
        }
        // Nombre único: segundos actuales + 8 letras al azar del UUID.
        // Empezar con los segundos hace que ordenar por nombre sea ordenar por fecha.
        let nombre = "\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString.prefix(8)).jpg"
        // .atomic escribe primero en un archivo temporal y luego lo mueve.
        // Así nunca queda un archivo a medias si algo falla a la mitad.
        try data.write(to: carpeta.appending(path: nombre), options: .atomic)
        return nombre
    }

    /// Lee una imagen guardada a partir de su nombre.
    /// Devuelve un opcional (`UIImage?`): es nil si el archivo no existe o está dañado.
    func cargar(_ nombre: String) -> UIImage? {
        UIImage(contentsOfFile: carpeta.appending(path: nombre).path())
    }

    /// Nombres de los archivos guardados, del más antiguo al más reciente.
    func listar() -> [String] {
        // Si no se puede leer la carpeta, `?? []` usa un arreglo vacío.
        let archivos = (try? FileManager.default.contentsOfDirectory(atPath: carpeta.path())) ?? []
        // filter se queda solo con los .jpg; sorted los ordena por nombre,
        // que como empieza con los segundos, equivale a ordenar por fecha.
        return archivos.filter { $0.hasSuffix(".jpg") }.sorted()
    }

    /// Borra el archivo con ese nombre. Si no existe, no pasa nada (`try?`).
    func borrar(_ nombre: String) {
        try? FileManager.default.removeItem(at: carpeta.appending(path: nombre))
    }
}
