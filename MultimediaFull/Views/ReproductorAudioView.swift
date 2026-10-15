import SwiftUI

/// Pantalla del ejemplo "Reproductor de audio" (día 2).
///
/// Capa MVVM: **View**. Muestra la lista de sonidos incluidos en la app
/// (campana, melodía, pulso) y los controles del que está sonando.
/// Quien reproduce es `ReproductorAudioViewModel`, con ayuda de `ReproductorAudioManager`.
///
/// Sirve para aprender a tocar un archivo de audio, pausarlo
/// y moverse por él con una barra (Slider).
struct ReproductorAudioView: View {
    // MARK: - Estado

    /// `@State` hace que la vista sea dueña del ViewModel y lo conserve entre redibujados.
    /// Mientras suena un audio, el ViewModel actualiza `tiempoActual` cada 200 ms
    /// y la vista se redibuja sola para mover la barra.
    @State private var viewModel = ReproductorAudioViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // List con varias Section: cada una es un grupo con su propio encabezado.
        List {
            // Sección 1: los sonidos disponibles.
            Section("Sonidos") {
                // Sonido es Identifiable, por eso ForEach no necesita `id:`.
                ForEach(viewModel.sonidos) { sonido in
                    // Tocar un sonido lo reproduce; si ya era el actual, lo pausa o reanuda.
                    Button {
                        viewModel.tocar(sonido)
                    } label: {
                        // Spacer empuja el ícono de bocina hasta la derecha.
                        // La bocina solo aparece en el sonido que está sonando ahora.
                        // `&&` significa "y": deben cumplirse las dos condiciones.
                        HStack {
                            Label(sonido.titulo, systemImage: sonido.icono)
                            Spacer()
                            if sonido == viewModel.actual && viewModel.reproduciendo {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }

            // Sección 2: controles. Solo aparece cuando ya se eligió un sonido.
            // `if let actual` saca el sonido del opcional; si es nil, no se dibuja nada.
            if let actual = viewModel.actual {
                Section("Ahora suena: \(actual.titulo)") {
                    // Slider es una barra que el usuario puede arrastrar.
                    //
                    // Se arma un Binding a mano con dos closures:
                    // - get: qué valor mostrar (el tiempo actual del audio).
                    // - set: qué hacer cuando el usuario arrastra (`$0` es el nuevo valor).
                    // Se hace así porque `tiempoActual` es private(set): la vista
                    // no puede cambiarlo directo, tiene que pedirle al ViewModel que salte.
                    //
                    // `in:` es el rango de la barra, de 0 a la duración.
                    // max(..., 0.1) evita un rango 0...0 mientras la duración aún no se conoce.
                    //
                    // `onEditingChanged` avisa con true al empezar a arrastrar y con false al soltar.
                    // Así el ViewModel sabe que no debe mover la barra mientras la arrastras.
                    Slider(
                        value: Binding(
                            get: { viewModel.tiempoActual },
                            set: { viewModel.ir(a: $0) }
                        ),
                        in: 0...max(viewModel.duracion, 0.1),
                        onEditingChanged: { editando in
                            viewModel.cambiarArrastre(editando)
                        }
                    )

                    // Tiempo transcurrido a la izquierda y duración total a la derecha.
                    HStack {
                        Text(viewModel.tiempoActual.comoReloj)
                        Spacer()
                        Text(viewModel.duracion.comoReloj)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    // Botones de reproducir/pausar y detener, centrados con dos Spacer.
                    HStack(spacing: 32) {
                        Spacer()
                        Button {
                            viewModel.alternar()
                        } label: {
                            Image(systemName: viewModel.reproduciendo ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 44))
                        }
                        Button {
                            viewModel.detener()
                        } label: {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 44))
                        }
                        Spacer()
                    }
                    // Dentro de una List, una fila con botones normales se comporta
                    // como un solo botón gigante. .borderless hace que cada botón
                    // responda por separado.
                    .buttonStyle(.borderless)
                }
            }

            // Sección 3: mensaje de error (por ejemplo, si falta un archivo .wav).
            if !viewModel.mensaje.isEmpty {
                Section {
                    Text(viewModel.mensaje)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Reproductor de audio")
        // Al salir de la pantalla, se detiene el audio para que no siga sonando en el menú.
        .onDisappear {
            viewModel.detener()
        }
    }
}
