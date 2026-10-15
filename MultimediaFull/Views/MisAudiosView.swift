import SwiftUI
// UniformTypeIdentifiers trae los "tipos de archivo" (UTType), como `.audio`,
// que usa .fileImporter para saber qué archivos dejar elegir.
import UniformTypeIdentifiers

/// Pantalla del ejemplo "Mis audios e importar" (día 2, extra).
///
/// Capa MVVM: **View**. Muestra los audios de Documents/Audios y el botón para importar
/// archivos desde la app Archivos. El trabajo (copiar, reproducir, borrar)
/// lo hace `MisAudiosViewModel` con `AudioManager` y `ReproductorAudioManager`.
///
/// Aquí aparecen tanto los audios importados como los que grabaste en la "Grabadora",
/// porque las dos pantallas usan la misma carpeta.
struct MisAudiosView: View {
    // MARK: - Estado

    /// `@State` hace que la vista sea dueña del ViewModel y lo conserve entre redibujados.
    @State private var viewModel = MisAudiosViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // @Bindable permite escribir $viewModel.mostrandoImportador,
        // el binding que necesita .fileImporter para abrirse y cerrarse.
        @Bindable var viewModel = viewModel

        // Group junta vistas sin agregar nada visible.
        // Sirve para aplicar los modificadores de abajo (.navigationTitle, .toolbar...)
        // tanto al aviso de "vacío" como a la lista, sin repetirlos.
        Group {
            if viewModel.audios.isEmpty {
                ContentUnavailableView(
                    "Sin audios",
                    systemImage: "music.note.list",
                    description: Text("Importa un audio con el botón de arriba o graba uno en la grabadora.")
                )
            } else {
                // Lista de audios. ForEach no necesita `id:` porque Grabacion es Identifiable.
                List {
                    ForEach(viewModel.audios) { audio in
                        // Cada fila es un botón: tocarla reproduce o detiene ese audio.
                        Button {
                            viewModel.reproducir(audio)
                        } label: {
                            // Ícono a la izquierda; a la derecha, nombre y fecha uno sobre otro.
                            HStack {
                                Image(systemName: viewModel.reproduciendo == audio ? "stop.fill" : "play.fill")
                                    .frame(width: 24)
                                // alignment: .leading alinea los textos a la izquierda.
                                // .lineLimit(1) corta los nombres largos en una sola línea.
                                VStack(alignment: .leading) {
                                    Text(audio.nombre)
                                        .lineLimit(1)
                                    Text(audio.fecha.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        // Deslizar la fila a la izquierda muestra el botón de eliminar.
                        .swipeActions {
                            Button("Eliminar", systemImage: "trash", role: .destructive) {
                                viewModel.eliminar(audio)
                            }
                        }
                    }
                }
            }
        }
        // `.safeAreaInset(edge: .bottom)` pega una vista abajo, sin tapar la lista.
        // Aquí muestras el mensaje de error, solo si hay uno.
        .safeAreaInset(edge: .bottom) {
            if !viewModel.mensaje.isEmpty {
                Text(viewModel.mensaje)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.bar)
            }
        }
        .navigationTitle("Mis audios")
        // Botón "Importar" en la barra. No abre nada por sí mismo:
        // solo cambia `mostrandoImportador` a true y eso abre el .fileImporter de abajo.
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Importar", systemImage: "square.and.arrow.down") {
                    viewModel.mostrandoImportador = true
                }
            }
        }
        // .fileImporter abre el selector de la app Archivos.
        // - isPresented: binding que lo muestra (true) o lo oculta (false). Al cerrarse,
        //   SwiftUI lo regresa a false solo.
        // - allowedContentTypes: [.audio] para que solo deje elegir audios.
        // - allowsMultipleSelection: se pueden elegir varios a la vez.
        // El closure recibe un Result: o la lista de URLs elegidas, o un error.
        .fileImporter(
            isPresented: $viewModel.mostrandoImportador,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true
        ) { resultado in
            viewModel.importar(resultado)
        }
        // Al aparecer la pantalla, se lee la lista de audios del disco.
        .task {
            viewModel.cargar()
        }
        // Al salir de la pantalla, se detiene el audio para que no siga sonando.
        .onDisappear {
            viewModel.detenerReproduccion()
        }
    }
}
