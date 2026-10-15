import SwiftUI

/// Pantalla del ejemplo "Grabadora de voz" (día 2).
///
/// Capa MVVM: **View**. Muestra el reloj, el botón de grabar y la lista de grabaciones.
/// Todo el trabajo (pedir permiso del micrófono, grabar, reproducir, borrar)
/// lo hace `GrabadoraViewModel` con `GrabadoraManager`, `ReproductorAudioManager`
/// y `AudioManager`.
///
/// Las grabaciones se guardan en Documents/Audios; también las verás en "Mis audios".
struct GrabadoraView: View {
    // MARK: - Estado

    /// `@State` hace que la vista sea dueña del ViewModel y lo conserve entre redibujados.
    /// Aquí no hace falta `@Bindable` porque ningún control escribe directo en el ViewModel:
    /// los botones llaman a funciones.
    @State private var viewModel = GrabadoraViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // VStack acomoda la zona de grabar arriba y la lista abajo.
        // spacing: 0 para que la lista quede pegada a la zona de grabar.
        VStack(spacing: 0) {
            // Zona de grabación: reloj, botón y textos de ayuda.
            VStack(spacing: 12) {
                // Tiempo grabado, con formato de reloj ("1:05").
                // `comoReloj` es una extensión propia de TimeInterval (ver Services).
                // .monospaced hace que todos los números midan lo mismo de ancho,
                // así el texto no "baila" mientras avanza el tiempo.
                Text(viewModel.tiempoGrabacion.comoReloj)
                    .font(.system(size: 44, weight: .light, design: .monospaced))

                // Botón grande para grabar o detener.
                // Va con Task + await porque la primera vez hay que esperar
                // a que el usuario conteste el permiso del micrófono.
                Button {
                    Task { await viewModel.alternarGrabacion() }
                } label: {
                    // Operador ternario: `condición ? siSí : siNo`.
                    // Cambia el ícono según si se está grabando o no.
                    Image(systemName: viewModel.grabando ? "stop.circle.fill" : "record.circle")
                        .font(.system(size: 72))
                        .foregroundStyle(.red)
                }
                // .borderless quita el fondo del botón; solo se ve el ícono.
                .buttonStyle(.borderless)

                Text(viewModel.grabando ? "Grabando… toca para detener" : "Toca para grabar")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                // Mensaje de error (por ejemplo, sin permiso de micrófono).
                // Solo se dibuja si hay algo que decir.
                if !viewModel.mensaje.isEmpty {
                    Text(viewModel.mensaje)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()

            // Lista de grabaciones, o un aviso si todavía no hay ninguna.
            if viewModel.grabaciones.isEmpty {
                ContentUnavailableView(
                    "Sin grabaciones",
                    systemImage: "waveform",
                    description: Text("Graba tu primera nota de voz.")
                )
            } else {
                // List dibuja las filas con desplazamiento.
                // ForEach no necesita `id:` porque Grabacion es Identifiable.
                List {
                    ForEach(viewModel.grabaciones) { grabacion in
                        // Cada fila es un botón: tocarla reproduce o detiene esa grabación.
                        Button {
                            viewModel.reproducir(grabacion)
                        } label: {
                            // HStack acomoda el ícono y la fecha uno junto al otro.
                            // Comparar con == funciona porque Grabacion es Hashable.
                            // .frame(width: 24) da al ícono un ancho fijo para que
                            // las fechas queden alineadas en todas las filas.
                            HStack {
                                Image(systemName: viewModel.reproduciendo == grabacion ? "stop.fill" : "play.fill")
                                    .frame(width: 24)
                                Text(grabacion.fecha.formatted(date: .abbreviated, time: .standard))
                            }
                        }
                        // .swipeActions agrega botones al deslizar la fila hacia la izquierda.
                        .swipeActions {
                            Button("Eliminar", systemImage: "trash", role: .destructive) {
                                viewModel.eliminar(grabacion)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Grabadora de voz")
        // .task se ejecuta al aparecer la pantalla: lee las grabaciones del disco.
        .task {
            viewModel.cargar()
        }
        // .onDisappear se ejecuta al salir de la pantalla.
        // Sin esto, la grabación o el audio seguirían activos aunque regreses al menú.
        .onDisappear {
            viewModel.detenerTodo()
        }
    }
}
