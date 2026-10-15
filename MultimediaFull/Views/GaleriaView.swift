import SwiftUI
// PhotosUI trae PhotosPicker, el selector de fotos del sistema.
import PhotosUI

/// Pantalla del ejemplo "Galería con PhotosPicker" (día 1).
///
/// Capa MVVM: **View**. Dibuja la cuadrícula de fotos y reenvía los eventos
/// (elegir fotos, tocar una) a `GaleriaViewModel`, que es quien carga las imágenes.
///
/// Sirve para aprender a pedirle fotos al usuario con `PhotosPicker`
/// y mostrarlas en una cuadrícula. Las fotos solo viven en memoria:
/// al salir de la pantalla se pierden (para guardarlas, mira "Mi álbum").
struct GaleriaView: View {
    // MARK: - Estado

    /// `@State` hace que la vista sea dueña de este ViewModel y lo conserve
    /// aunque SwiftUI vuelva a dibujar la pantalla muchas veces.
    /// Como el ViewModel es `@Observable`, la vista se redibuja sola
    /// cuando cambia algo que está leyendo (por ejemplo, `fotos`).
    @State private var viewModel = GaleriaViewModel()

    /// Columnas de la cuadrícula.
    /// `GridItem(.adaptive(minimum: 100))` dice: "mete tantas columnas como quepan,
    /// cada una de al menos 100 puntos". Así funciona igual en iPhone y en iPad.
    private let columnas = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    // MARK: - Cuerpo

    var body: some View {
        // Permite usar $viewModel.propiedad para crear bindings.
        // Un binding es un "cable" de ida y vuelta: el PhotosPicker puede
        // leer y también escribir `seleccion` dentro del ViewModel.
        // @State nos da el ViewModel, pero no bindings a sus propiedades;
        // por eso se crea esta copia local con @Bindable.
        @Bindable var viewModel = viewModel

        // ScrollView permite desplazar el contenido si no cabe en la pantalla.
        ScrollView {
            if viewModel.fotos.isEmpty {
                // ContentUnavailableView es la pantalla estándar de iOS para "no hay nada".
                // \(...) dentro de un texto inserta el valor de una variable.
                ContentUnavailableView(
                    "Sin fotos",
                    systemImage: "photo",
                    description: Text("Toca el botón para elegir hasta \(viewModel.maximoFotos) fotos.")
                )
            } else {
                // LazyVGrid acomoda las vistas en filas y columnas.
                // "Lazy" significa que solo crea las celdas que se ven en pantalla,
                // lo que ahorra memoria cuando hay muchas fotos.
                LazyVGrid(columns: columnas, spacing: 8) {
                    // ForEach no necesita `id:` porque Foto es Identifiable.
                    ForEach(viewModel.fotos) { foto in
                        // CeldaCuadrada recibe lo que va dentro entre llaves (trailing closure).
                        // scaledToFill llena todo el cuadro; lo que sobra se recorta.
                        CeldaCuadrada {
                            Image(uiImage: foto.imagen)
                                .resizable()
                                .scaledToFill()
                        }
                        // Al tocar una celda, se guarda cuál foto ampliar.
                        // Eso dispara el .fullScreenCover de abajo.
                        .onTapGesture { viewModel.fotoAmpliada = foto }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Galería")
        // .toolbar agrega botones a la barra de navegación.
        // .primaryAction los pone en el lugar principal (arriba a la derecha en iPhone).
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // PhotosPicker abre el selector de fotos del sistema.
                // La app no necesita pedir permiso a la fototeca: el usuario
                // solo comparte las fotos que elige.
                // - selection: dónde se guarda lo elegido (por eso el $ del binding).
                // - maxSelectionCount: cuántas fotos se pueden elegir como máximo.
                // - matching: .images para que solo muestre fotos, no videos.
                PhotosPicker(
                    selection: $viewModel.seleccion,
                    maxSelectionCount: viewModel.maximoFotos,
                    matching: .images
                ) {
                    Label("Elegir fotos", systemImage: "photo.badge.plus")
                }
            }
        }
        // .onChange se ejecuta cada vez que cambia el valor observado.
        // El closure recibe el valor viejo y el nuevo; `_` ignora el viejo.
        // Cargar las imágenes tarda, así que se hace con `await` dentro de un Task:
        // Task arranca trabajo asíncrono sin congelar la pantalla.
        .onChange(of: viewModel.seleccion) { _, nuevos in
            Task { await viewModel.cargar(nuevos) }
        }
        // .fullScreenCover(item:) abre una pantalla completa cuando `fotoAmpliada`
        // deja de ser nil, y la cierra cuando vuelve a ser nil.
        // Necesita que Foto sea Identifiable para saber qué foto se abrió.
        .fullScreenCover(item: $viewModel.fotoAmpliada) { foto in
            DetalleFotoView(foto: foto)
        }
    }
}
