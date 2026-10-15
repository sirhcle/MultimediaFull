import SwiftUI

/// Pantalla del ejemplo "Texto a voz" (día 2, extra).
///
/// Capa MVVM: **View**. Muestra el idioma, el texto y los botones de hablar y detener.
/// Quien habla es `VozViewModel`, con ayuda de `VozManager` (AVSpeechSynthesizer).
///
/// Sirve para ver cómo el teléfono puede leer en voz alta cualquier texto,
/// en varios idiomas.
struct VozView: View {
    // MARK: - Estado

    /// `@State` hace que la vista sea dueña del ViewModel y lo conserve entre redibujados.
    @State private var viewModel = VozViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // @Bindable permite escribir $viewModel.idioma y $viewModel.texto,
        // los bindings que necesitan el Picker y el TextEditor.
        @Bindable var viewModel = viewModel

        // Form es una lista pensada para formularios (como la app Ajustes).
        // Cada Section es un bloque con su encabezado.
        Form {
            // Selector de idioma. Recorre IdiomaVoz.allCases (gracias a CaseIterable)
            // y .tag(idioma) dice qué valor representa cada opción.
            Section("Idioma") {
                Picker("Idioma", selection: $viewModel.idioma) {
                    ForEach(IdiomaVoz.allCases) { idioma in
                        Text(idioma.rawValue).tag(idioma)
                    }
                }
                .pickerStyle(.segmented)
            }

            // TextEditor es un cuadro de texto de varias líneas.
            // Con el binding, lo que escribe el usuario se guarda en el ViewModel.
            // minHeight le da un alto mínimo para que no se vea diminuto.
            Section("Texto") {
                TextEditor(text: $viewModel.texto)
                    .frame(minHeight: 120)
            }

            // Botones de acción. role: .destructive pinta "Detener" en rojo.
            Section {
                Button("Hablar", systemImage: "speaker.wave.2.fill") {
                    viewModel.hablar()
                }
                Button("Detener", systemImage: "stop.fill", role: .destructive) {
                    viewModel.detener()
                }
            }
        }
        .navigationTitle("Texto a voz")
        // .onChange avisa cuando cambia el idioma (los dos `_` ignoran el valor viejo y el nuevo).
        // El ViewModel detiene la voz y pone una frase de ejemplo en el idioma nuevo.
        .onChange(of: viewModel.idioma) { _, _ in
            viewModel.cambiarIdioma()
        }
        // Al salir de la pantalla, se calla la voz para que no siga hablando en el menú.
        .onDisappear {
            viewModel.detener()
        }
    }
}
