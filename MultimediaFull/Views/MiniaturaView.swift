import SwiftUI

/// Miniatura de un archivo del álbum. La imagen se lee del disco con .task,
/// fuera del body, para no leer el archivo en cada redibujado.
///
/// Capa MVVM: **View** auxiliar del ejemplo "Mi álbum". La usa `AlbumView`
/// para dibujar cada celda de la cuadrícula.
///
/// Recibe el ViewModel del álbum para pedirle la imagen; así la vista
/// nunca habla directo con `FotoManager` (la regla es View → ViewModel → Manager).
struct MiniaturaView: View {
    /// Nombre del archivo (por ejemplo "1760550000-1A2B3C4D.jpg"), no la ruta completa.
    let nombre: String
    /// El mismo ViewModel de `AlbumView`. Es `let` porque aquí solo se usa para leer.
    let viewModel: AlbumViewModel

    /// La imagen ya leída del disco. Empieza en nil (todavía no se carga).
    ///
    /// - `UIImage?` con signo `?` es un opcional: puede tener una imagen o estar vacío (nil).
    /// - `@State` aquí guarda un estado que es solo de esta vista;
    ///   cuando cambia, la miniatura se redibuja y aparece la foto.
    @State private var imagen: UIImage?

    var body: some View {
        CeldaCuadrada {
            // `if let imagen` revisa si el opcional tiene valor.
            // Si lo tiene, dentro de las llaves `imagen` ya es un UIImage normal.
            if let imagen {
                Image(uiImage: imagen)
                    .resizable()
                    .scaledToFill()
            } else {
                // Mientras tanto, una ruedita de "cargando".
                ProgressView()
            }
        }
        // .task corre una sola vez cuando la celda aparece en pantalla.
        // Si la lectura estuviera dentro de body, se repetiría cada vez
        // que SwiftUI redibuja, y eso haría la cuadrícula lenta.
        .task {
            imagen = viewModel.imagen(para: nombre)
        }
    }
}
