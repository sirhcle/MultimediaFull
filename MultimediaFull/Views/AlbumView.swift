import SwiftUI
// PhotosUI trae PhotosPicker, el selector de fotos del sistema.
import PhotosUI

/// Pantalla del ejemplo "Mi álbum con FileManager" (día 1).
///
/// Capa MVVM: **View**. Dibuja la cuadrícula del álbum y reenvía los eventos
/// (agregar, eliminar) a `AlbumViewModel`, que a su vez usa `FotoManager`
/// para guardar y leer los archivos.
///
/// A diferencia de "Galería", aquí las fotos se guardan en disco
/// (carpeta Documents/Fotos), así que siguen ahí aunque cierres la app.
struct AlbumView: View {
    // MARK: - Estado

    /// `@State` hace que la vista sea dueña del ViewModel y lo conserve
    /// entre redibujados. Si cambia algo que la vista lee, se vuelve a dibujar sola.
    @State private var viewModel = AlbumViewModel()

    /// Columnas de la cuadrícula: tantas como quepan, de al menos 100 puntos cada una.
    private let columnas = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    // MARK: - Cuerpo

    var body: some View {
        // @Bindable crea una copia local que permite escribir $viewModel.seleccion.
        // El PhotosPicker necesita ese binding para guardar lo que eligió el usuario.
        @Bindable var viewModel = viewModel

        // ScrollView permite desplazar la cuadrícula cuando hay muchas fotos.
        ScrollView {
            if viewModel.archivos.isEmpty {
                // Pantalla estándar de iOS para "todavía no hay nada".
                ContentUnavailableView(
                    "Álbum vacío",
                    systemImage: "photo.on.rectangle",
                    description: Text("Agrega fotos con el botón de arriba.")
                )
            } else {
                // LazyVGrid solo crea las celdas visibles, así no carga todas las fotos de golpe.
                LazyVGrid(columns: columnas, spacing: 8) {
                    // `archivos` es un arreglo de String (nombres de archivo), que no es Identifiable.
                    // `id: \.self` le dice a ForEach: "usa el propio texto como identificador".
                    // Funciona porque en una carpeta no puede haber dos archivos con el mismo nombre.
                    ForEach(viewModel.archivos, id: \.self) { nombre in
                        // Cada miniatura lee su propia imagen del disco (ver MiniaturaView).
                        MiniaturaView(nombre: nombre, viewModel: viewModel)
                            // .contextMenu aparece al mantener presionada la miniatura.
                            // role: .destructive pinta el botón en rojo, porque borra algo.
                            .contextMenu {
                                Button("Eliminar", systemImage: "trash", role: .destructive) {
                                    viewModel.eliminar(nombre)
                                }
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Mi álbum")
        // .toolbar agrega el botón para elegir fotos en la barra de navegación.
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // Sin maxSelectionCount, el usuario puede elegir varias fotos sin límite.
                PhotosPicker(selection: $viewModel.seleccion, matching: .images) {
                    Label("Agregar", systemImage: "photo.badge.plus")
                }
            }
        }
        // Cuando cambia la selección, se guardan las fotos en disco.
        // Guardar tarda, por eso se usa Task + await: no congela la pantalla.
        .onChange(of: viewModel.seleccion) { _, items in
            Task { await viewModel.guardar(items) }
        }
        // .task se ejecuta cuando la pantalla aparece.
        // Aquí se lee la lista de archivos guardados.
        // Se hace aquí y no en el init del ViewModel para que crearlo sea rápido.
        .task {
            viewModel.cargarArchivos()
        }
    }
}
