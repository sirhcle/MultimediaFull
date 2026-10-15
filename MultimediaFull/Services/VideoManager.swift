// AVFoundation es el framework de Apple para audio y video.
import AVFoundation
// UIKit nos da UIImage, para devolver la miniatura.
import UIKit

/// Guarda, lista y borra los videos en la carpeta Documents/Videos, y saca sus miniaturas.
///
/// Capa MVVM: **Service** (un "Manager"). Hace el trabajo con archivos para el
/// ViewModel del ejemplo "Videoteca". Las vistas nunca lo llaman directo.
///
/// Como no guarda estado propio (solo trabaja con archivos), se usa como singleton:
/// una única instancia compartida, `VideoManager.shared`.
struct VideoManager {
    // MARK: - Instancia compartida

    /// `static let shared` crea una sola instancia que vive mientras la app esté abierta.
    static let shared = VideoManager()

    // MARK: - Configuración

    /// Extensiones de video que la app reconoce. Los demás archivos se ignoran al listar.
    private let extensiones = ["mov", "mp4", "m4v"]
    /// Carpeta Documents/Videos dentro del sandbox (el espacio privado de tu app).
    private let carpeta = URL.documentsDirectory.appending(path: "Videos", directoryHint: .isDirectory)

    /// `private init()` impide crear otro `VideoManager()` desde fuera: solo existe `shared`.
    private init() {
        // Crea la carpeta si no existe. `try?` ignora el error si ya estaba creada.
        try? FileManager.default.createDirectory(at: carpeta, withIntermediateDirectories: true)
        // Solo mientras pruebas en Xcode: imprime en la consola dónde quedan los videos.
        #if DEBUG
        print("Videos guardados en: \(carpeta.path())")
        #endif
    }

    // MARK: - Archivos

    /// Copia un video a Documents/Videos y devuelve su nombre (nunca la ruta completa).
    ///
    /// Solo devolvemos el nombre porque la ruta de Documents cambia entre instalaciones.
    /// `throws` avisa que puede fallar (por ejemplo, sin espacio): quien llama usa `try`.
    func guardar(desde origen: URL) throws -> String {
        // Si el archivo no trae extensión, usamos "mov" para que luego aparezca en la lista.
        let extensionArchivo = origen.pathExtension.isEmpty ? "mov" : origen.pathExtension.lowercased()
        // Nombre único: segundos actuales + 8 letras al azar del UUID.
        let nombre = "\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString.prefix(8)).\(extensionArchivo)"
        try FileManager.default.copyItem(at: origen, to: carpeta.appending(path: nombre))
        return nombre
    }

    /// Dirección completa a partir del nombre guardado.
    /// La ruta se arma en el momento, así siempre apunta a la carpeta correcta.
    func url(de nombre: String) -> URL {
        carpeta.appending(path: nombre)
    }

    /// Nombres de los videos guardados, del más antiguo al más reciente.
    func listar() -> [String] {
        // Si no se puede leer la carpeta, `?? []` usa un arreglo vacío.
        let archivos = (try? FileManager.default.contentsOfDirectory(atPath: carpeta.path())) ?? []
        // filter se queda solo con los videos; sorted ordena por nombre,
        // que como empieza con los segundos, equivale a ordenar por fecha.
        return archivos
            .filter { extensiones.contains(URL(filePath: $0).pathExtension.lowercased()) }
            .sorted()
    }

    /// Borra el video con ese nombre. Si no existe, no pasa nada (`try?`).
    func borrar(_ nombre: String) {
        try? FileManager.default.removeItem(at: url(de: nombre))
    }

    // MARK: - Miniaturas

    /// Saca un cuadro del inicio del video para usarlo como miniatura.
    ///
    /// `async` significa que la función puede tardar y no bloquea la pantalla mientras trabaja.
    /// Quien la llama escribe `await` para esperar el resultado.
    /// Devuelve nil si no se pudo sacar la imagen.
    func miniatura(de nombre: String) async -> UIImage? {
        // AVURLAsset representa el video guardado; el generador saca imágenes de él.
        let asset = AVURLAsset(url: url(de: nombre))
        let generador = AVAssetImageGenerator(asset: asset)
        // Respeta la orientación con que se grabó; si no, un video vertical saldría acostado.
        generador.appliesPreferredTrackTransform = true
        // Una miniatura no necesita resolución completa: así ahorras memoria y tiempo.
        generador.maximumSize = CGSize(width: 400, height: 400)

        // .zero es el segundo 0 del video. Si falla, `try?` da nil y guard sale devolviendo nil.
        guard let resultado = try? await generador.image(at: .zero) else { return nil }
        // El generador entrega un CGImage (formato de bajo nivel); lo convertimos a UIImage.
        return UIImage(cgImage: resultado.image)
    }
}
