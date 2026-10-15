import SwiftUI
import AVKit

/// Pantalla del ejemplo "Reproductor de video" (capa View de MVVM).
/// Reproduce videos de internet con los controles que ya trae el sistema
/// y deja elegir entre varios videos. Solo dibuja y le avisa a
/// `ReproductorVideoViewModel` lo que hace el usuario.
struct ReproductorVideoView: View {
    /// `@State`: la vista es dueña del ViewModel y lo conserva entre redibujos.
    @State private var viewModel = ReproductorVideoViewModel()

    /// `some View`: devuelve algún tipo de vista; Swift averigua cuál.
    var body: some View {
        // `@Bindable` te deja crear bindings (`$viewModel.algo`) hacia un objeto @Observable,
        // para que el Picker pueda leer y cambiar `seleccionada`.
        @Bindable var viewModel = viewModel

        VStack(spacing: 16) {
            // VideoPlayer ya trae play, pausa, barra de avance, volumen y pantalla completa.
            // Viene de AVKit (por eso el `import AVKit`) y recibe un AVPlayer.
            VideoPlayer(player: viewModel.player)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Selector de video. `ForEach` no necesita `id:` porque `FuenteVideo`
            // es `Identifiable`. Cada opción lleva su `.tag` para saber cuál elegiste.
            Picker("Video", selection: $viewModel.seleccionada) {
                ForEach(viewModel.fuentes) { fuente in
                    Text(fuente.titulo).tag(fuente)
                }
            }
            .pickerStyle(.segmented)

            // Aviso para el usuario: los videos vienen de internet.
            Text("Necesita internet. Las direcciones son de pruebas públicas.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Reproductor de video")
        // `.onChange(of:)` corre cada vez que cambia el valor vigilado.
        // Te da el valor viejo (`_`, no se usa) y el nuevo: con él cargas el video elegido.
        .onChange(of: viewModel.seleccionada) { _, nueva in
            viewModel.cambiar(a: nueva)
        }
        // `.task` corre al aparecer la vista: carga y reproduce el video inicial.
        .task {
            viewModel.cambiar(a: viewModel.seleccionada)
        }
        // `.onDisappear` corre al salir: pausas para que el video no siga sonando.
        .onDisappear {
            viewModel.pausar()
        }
    }
}
