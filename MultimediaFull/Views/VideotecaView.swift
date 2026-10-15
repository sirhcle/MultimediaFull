import SwiftUI
import PhotosUI

/// Pantalla del ejemplo "Videoteca" (capa View de MVVM).
/// Muestra en cuadrícula los videos guardados en la app, deja agregar más
/// desde la galería y abre el que toques a pantalla completa.
/// Solo dibuja y le avisa a `VideotecaViewModel` lo que hace el usuario.
struct VideotecaView: View {
    /// `@State`: la vista es dueña del ViewModel y lo conserva entre redibujos.
    @State private var viewModel = VideotecaViewModel()

    /// Columnas de la cuadrícula. `.adaptive(minimum: 100)` mete tantas columnas
    /// de al menos 100 puntos como quepan; así se ajusta solo a iPhone y iPad.
    private let columnas = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    /// `some View`: devuelve algún tipo de vista; Swift averigua cuál.
    var body: some View {
        // `@Bindable` te deja crear bindings (`$viewModel.algo`) hacia un objeto @Observable.
        // Los usan el PhotosPicker y el `.fullScreenCover` de abajo.
        @Bindable var viewModel = viewModel

        ScrollView {
            // Si no hay videos, un aviso amable; si hay, la cuadrícula.
            if viewModel.videos.isEmpty {
                ContentUnavailableView(
                    "Sin videos",
                    systemImage: "film.stack",
                    description: Text("Agrega videos con el botón de arriba.")
                )
            } else {
                // `LazyVGrid` es una cuadrícula vertical. "Lazy" (perezosa) significa que
                // solo crea las celdas que se ven en pantalla, para no gastar memoria.
                LazyVGrid(columns: columnas, spacing: 8) {
                    ForEach(viewModel.videos) { video in
                        // Al tocar una miniatura, la guardas en `videoAbierto`
                        // y eso abre el reproductor a pantalla completa.
                        // Si la mantienes presionada, `.contextMenu` muestra "Eliminar".
                        MiniaturaVideoView(video: video, viewModel: viewModel)
                            .onTapGesture { viewModel.videoAbierto = video }
                            .contextMenu {
                                Button("Eliminar", systemImage: "trash", role: .destructive) {
                                    viewModel.eliminar(video)
                                }
                            }
                    }
                }
                .padding()
            }
        }
        // `.safeAreaInset(edge: .bottom)` pega una vista abajo, sin tapar la cuadrícula.
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
        .navigationTitle("Videoteca")
        // `.toolbar` agrega botones a la barra de navegación (arriba).
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // `PhotosPicker` abre la galería del sistema. `matching: .videos` filtra solo videos.
                // Lo que eliges se guarda en `viewModel.seleccion` gracias al binding.
                // No necesita permiso de fotos: el usuario elige y solo esos llegan a la app.
                PhotosPicker(selection: $viewModel.seleccion, matching: .videos) {
                    Label("Agregar", systemImage: "video.badge.plus")
                }
            }
        }
        // Cuando cambia la selección, copias los videos elegidos.
        // `.onChange` no acepta `await`, por eso se abre un `Task { ... }`.
        // Al final, `guardar` vacía la selección; eso vuelve a disparar este bloque,
        // pero `guardar` sale de inmediato porque la lista llega vacía.
        .onChange(of: viewModel.seleccion) { _, items in
            Task { await viewModel.guardar(items) }
        }
        // `.fullScreenCover(item:)` cubre toda la pantalla mientras `videoAbierto` tenga valor.
        // Al cerrarlo, SwiftUI regresa `videoAbierto` a nil. (`.sheet` sería parecido, pero como tarjeta.)
        .fullScreenCover(item: $viewModel.videoAbierto) { video in
            DetalleVideoView(url: viewModel.url(de: video))
        }
        // `.task` corre al aparecer la vista: lee del disco la lista de videos.
        .task {
            viewModel.cargar()
        }
    }
}
