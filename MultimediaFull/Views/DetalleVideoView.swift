import SwiftUI
import AVKit

/// Reproduce un video guardado a pantalla completa, con un botón para cerrar.
/// Capa View de MVVM. La abre `VideotecaView` con `.fullScreenCover`
/// cuando tocas una miniatura.
///
/// Como todas las pantallas, solo dibuja y le avisa a su ViewModel
/// (`DetalleVideoViewModel`) cuándo abrir y cerrar el video.
struct DetalleVideoView: View {
    /// La dirección del video que se va a reproducir. La pasa la Videoteca.
    let url: URL

    /// `@State`: la vista es dueña del ViewModel y lo conserva entre redibujos.
    @State private var viewModel = DetalleVideoViewModel()
    /// `@Environment(\.dismiss)` te da una acción del sistema para cerrar
    /// esta pantalla (la que la abrió decide cómo: aquí, un fullScreenCover).
    @Environment(\.dismiss) private var dismiss

    /// `some View`: devuelve algún tipo de vista; Swift averigua cuál.
    var body: some View {
        // `VideoPlayer` muestra el video con los controles del sistema.
        VideoPlayer(player: viewModel.player)
            .background(.black)
            .ignoresSafeArea()
            // Botón de cerrar en la esquina superior derecha, encima del video.
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                }
            }
            // `.onAppear` corre al mostrarse la vista: el video arranca solo.
            // `.onDisappear` corre al cerrarla: pausas para que no siga sonando.
            .onAppear { viewModel.abrir(url) }
            .onDisappear { viewModel.cerrar() }
    }
}
