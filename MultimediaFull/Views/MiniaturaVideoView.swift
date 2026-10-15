import SwiftUI

/// Miniatura de un video guardado. El cuadro se genera con .task, fuera del body.
/// Capa View de MVVM: es una vista auxiliar que usa `VideotecaView` para cada
/// celda de la cuadrícula. Muestra un cuadro del video con un ícono de play encima.
///
/// ¿Por qué fuera del `body`? El `body` debe ser rápido porque SwiftUI lo llama
/// muchas veces. Sacar un cuadro de un video tarda, así que se hace aparte con `.task`.
struct MiniaturaVideoView: View {
    /// El video que representa esta celda.
    let video: VideoGuardado
    /// El ViewModel de la videoteca. Es `let` (sin `@Bindable`) porque aquí
    /// solo le pides la miniatura; no necesitas bindings.
    let viewModel: VideotecaViewModel

    /// La imagen de la miniatura. Empieza en nil mientras se genera.
    /// `@State` porque es un dato propio de esta vista que cambia con el tiempo.
    @State private var imagen: UIImage?

    /// `some View`: devuelve algún tipo de vista; Swift averigua cuál.
    var body: some View {
        // `CeldaCuadrada` es una vista del proyecto que da a cada celda forma de cuadro.
        CeldaCuadrada {
            // `if let imagen`: si ya hay imagen, la muestras; si no, un indicador de carga.
            if let imagen {
                Image(uiImage: imagen)
                    .resizable()
                    .scaledToFill()
                    // Ícono de play encima para que se note que es un video y no una foto.
                    .overlay {
                        Image(systemName: "play.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 4)
                    }
            } else {
                ProgressView()
            }
        }
        // `.task` corre trabajo `async` al aparecer la celda y lo cancela si desaparece.
        // `await` espera la miniatura sin congelar el desplazamiento de la cuadrícula.
        .task {
            imagen = await viewModel.miniatura(para: video)
        }
    }
}
