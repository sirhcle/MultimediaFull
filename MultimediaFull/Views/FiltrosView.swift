import SwiftUI
// PhotosUI trae PhotosPicker, el selector de fotos del sistema.
import PhotosUI

/// Pantalla del ejemplo "Editor de filtros" (día 1, extra).
///
/// Capa MVVM: **View**. Muestra la foto, el selector de filtro y el botón de guardar.
/// Todo el trabajo (reducir la foto, aplicar el filtro con Core Image, guardarla)
/// lo hace `FiltrosViewModel` con ayuda de `FiltroManager` y `FotoManager`.
///
/// Sirve para ver cómo se transforma una imagen y cómo se guarda el resultado
/// en "Mi álbum".
struct FiltrosView: View {
    // MARK: - Estado

    /// `@State` hace que la vista sea dueña del ViewModel y lo conserve
    /// entre redibujados. Al cambiar algo que la vista lee, se redibuja sola.
    @State private var viewModel = FiltrosViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // @Bindable permite escribir $viewModel.filtro y $viewModel.seleccion,
        // los bindings que necesitan el Picker y el PhotosPicker.
        @Bindable var viewModel = viewModel

        // VStack acomoda las vistas una debajo de otra, con 16 puntos de separación.
        VStack(spacing: 16) {
            // La foto con el filtro aplicado, o un aviso si todavía no hay foto.
            // `if let` saca la imagen del opcional solo si existe.
            if let resultado = viewModel.resultado {
                Image(uiImage: resultado)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ContentUnavailableView(
                    "Sin foto",
                    systemImage: "photo",
                    description: Text("Elige una foto con el botón de arriba.")
                )
            }

            // Picker deja elegir una opción de una lista.
            // - selection: el binding donde se guarda la opción elegida.
            // - ForEach recorre Filtro.allCases (gracias a CaseIterable).
            // - .tag(opcion) le dice al Picker qué valor representa cada texto.
            // .segmented lo dibuja como botones pegados, uno junto al otro.
            // .disabled lo apaga mientras no haya foto, porque no habría nada que filtrar.
            Picker("Filtro", selection: $viewModel.filtro) {
                ForEach(Filtro.allCases) { opcion in
                    Text(opcion.rawValue).tag(opcion)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!viewModel.hayFoto)

            // Guarda la foto filtrada en Documents/Fotos (la verás en "Mi álbum").
            // .borderedProminent es el estilo de botón relleno, el más llamativo.
            Button("Guardar en Mi álbum") {
                viewModel.guardar()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.hayFoto)

            // Mensaje para el usuario ("Guardada en Mi álbum." o un error).
            Text(viewModel.mensaje)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Filtros")
        // Botón para elegir la foto, en la barra de navegación.
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // Aquí `seleccion` es un solo elemento (no un arreglo),
                // así que el usuario solo puede elegir una foto.
                PhotosPicker(selection: $viewModel.seleccion, matching: .images) {
                    Label("Elegir foto", systemImage: "photo.badge.plus")
                }
            }
        }
        // .onChange avisa cuando cambia un valor. Recibe el valor viejo y el nuevo;
        // con `_` ignoras el que no necesitas.
        // Al elegir una foto nueva, se carga (tarda, por eso va con Task + await).
        .onChange(of: viewModel.seleccion) { _, item in
            Task { await viewModel.cargar(item) }
        }
        // Al cambiar de filtro en el Picker, se vuelve a aplicar sobre la foto original.
        .onChange(of: viewModel.filtro) { _, _ in
            viewModel.aplicarFiltro()
        }
    }
}
