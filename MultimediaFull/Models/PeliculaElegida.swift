import SwiftUI
// UniformTypeIdentifiers define tipos de archivo como .movie, .image o .audio.
import UniformTypeIdentifiers

/// Lo que entrega `PhotosPicker` cuando el usuario elige un video (ejemplo "Videoteca", día 3).
///
/// Capa MVVM: **Model**. Solo guarda la dirección del video ya copiado;
/// después `VideoManager` lo guarda en Documents/Videos.
///
/// ¿Por qué no se carga como `Data`, igual que una foto? Porque un video pesa mucho
/// y llenaría la memoria. En lugar de eso se copia a un archivo temporal y solo
/// pasamos su dirección.
///
/// - `Transferable` es el protocolo que le explica a SwiftUI cómo convertir
///   algo que viene de fuera (galería, arrastrar y soltar, compartir) en este tipo.
struct PeliculaElegida: Transferable {
    /// Dirección de la copia temporal del video.
    let url: URL

    /// Aquí le dices a SwiftUI cómo transferir un video.
    /// `static` porque la regla es la misma para todos los videos, no para uno en particular.
    /// `some TransferRepresentation` significa "devuelvo alguna forma de transferir; Swift sabe cuál".
    static var transferRepresentation: some TransferRepresentation {
        // FileRepresentation: el video llega como archivo, no como bytes en memoria.
        // contentType: .movie indica que solo aceptamos videos.
        // Recibe dos closures (bloques de código que se pasan como valor):
        // el primero dice cómo exportar y el que va después de "importing:" cómo importar.
        FileRepresentation(contentType: .movie) { pelicula in
            SentTransferredFile(pelicula.url)
        } importing: { recibido in
            // El archivo que nos da el sistema se borra pronto, así que hay que copiarlo.
            // Si el archivo no trae extensión, usamos "mov" para que el reproductor lo reconozca.
            // La forma "condición ? valorSiSí : valorSiNo" es un if corto (operador ternario).
            let extensionArchivo = recibido.file.pathExtension.isEmpty ? "mov" : recibido.file.pathExtension
            // UUID da un nombre único para que dos videos nunca choquen.
            let copia = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).\(extensionArchivo)")
            // try: copiar puede fallar (por ejemplo, sin espacio). Si falla, el error sube
            // hacia PhotosPicker y quien pidió el video se entera.
            try FileManager.default.copyItem(at: recibido.file, to: copia)
            return PeliculaElegida(url: copia)
        }
    }
}
