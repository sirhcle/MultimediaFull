import SwiftUI
import AVKit

/// Pantalla del ejemplo "Controles de video" (capa View de MVVM).
/// Reproduce un video de internet y agrega controles propios: velocidad,
/// saltar 10 segundos y silenciar. Solo dibuja y le avisa a
/// `ControlesVideoViewModel` lo que hace el usuario.
struct ControlesVideoView: View {
    /// `@State`: la vista es dueña del ViewModel y lo conserva entre redibujos.
    @State private var viewModel = ControlesVideoViewModel()

    /// `some View`: devuelve algún tipo de vista; Swift averigua cuál.
    var body: some View {
        // `@Bindable` te deja crear bindings (`$viewModel.algo`) hacia un objeto @Observable.
        // Un binding es un "cable" de ida y vuelta: el Picker lee el valor y también lo cambia.
        // Se declara con el mismo nombre para poder escribir `$viewModel` más abajo.
        @Bindable var viewModel = viewModel

        VStack(spacing: 16) {
            // `VideoPlayer` (de AVKit) muestra el AVPlayer con los controles del sistema.
            // Con 16:9 el video conserva su forma de pantalla ancha.
            VideoPlayer(player: viewModel.player)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Reloj "tiempo actual / duración". La fuente monoespaciada
            // evita que los números "bailen" al cambiar.
            Text("\(viewModel.tiempoActual.comoReloj) / \(viewModel.duracion.comoReloj)")
                .font(.system(.title3, design: .monospaced))

            // Selector de velocidad. Cada opción lleva un `.tag` con su valor;
            // al tocarla, ese valor se guarda en `viewModel.velocidad`.
            // `id: \.self` usa el propio número como identificador en el ForEach.
            Picker("Velocidad", selection: $viewModel.velocidad) {
                ForEach(viewModel.velocidades, id: \.self) { valor in
                    Text("\(valor, format: .number)x").tag(valor)
                }
            }
            .pickerStyle(.segmented)

            // Botones para saltar 10 segundos atrás o adelante.
            // `.labelStyle(.iconOnly)` muestra solo el ícono; el texto queda para VoiceOver.
            HStack(spacing: 24) {
                Button("Atrás 10 s", systemImage: "gobackward.10") {
                    viewModel.saltar(segundos: -10)
                }
                Button("Adelante 10 s", systemImage: "goforward.10") {
                    viewModel.saltar(segundos: 10)
                }
            }
            .labelStyle(.iconOnly)
            .font(.largeTitle)

            // Interruptor de silencio, conectado con un binding a `viewModel.silenciado`.
            Toggle("Silenciar", isOn: $viewModel.silenciado)

            Spacer()
        }
        .padding()
        .navigationTitle("Controles de video")
        // `.onChange(of:)` corre el bloque cada vez que cambia el valor vigilado.
        // Recibe el valor viejo y el nuevo; aquí no se usan (`_`), solo te importa que cambió.
        // Así el Picker y el Toggle cambian el estado, y el ViewModel lo aplica al video.
        .onChange(of: viewModel.velocidad) { _, _ in
            viewModel.cambiarVelocidad()
        }
        .onChange(of: viewModel.silenciado) { _, _ in
            viewModel.cambiarSilencio()
        }
        // `.task` corre al aparecer la vista: carga el video y empieza a seguir su tiempo.
        .task {
            viewModel.preparar()
        }
        // Al salir pausas el video y detienes el seguimiento del tiempo.
        .onDisappear {
            viewModel.terminar()
        }
    }
}
