import SwiftUI

/// Pantalla del ejemplo "Imágenes remotas" (día 1, extra).
///
/// Capa MVVM: **View**. Dibuja una cuadrícula de fotos que se descargan de internet.
/// La lista de direcciones (URLs) se la da `ImagenesRemotasViewModel`;
/// la descarga en sí la hace `AsyncImage`, que ya viene en SwiftUI.
///
/// Sirve para ver cómo mostrar imágenes que no están en el teléfono.
/// Necesita conexión a internet.
struct ImagenesRemotasView: View {
    // MARK: - Estado

    /// `@State` hace que la vista sea dueña del ViewModel y lo conserve entre redibujados.
    @State private var viewModel = ImagenesRemotasViewModel()

    /// Columnas de la cuadrícula: tantas como quepan, de al menos 100 puntos cada una.
    private let columnas = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    // MARK: - Cuerpo

    var body: some View {
        // ScrollView permite desplazar la cuadrícula si no cabe en la pantalla.
        ScrollView {
            // LazyVGrid solo crea (y descarga) las celdas que se ven,
            // así no se bajan de golpe imágenes que el usuario no está viendo.
            LazyVGrid(columns: columnas, spacing: 8) {
                // ForEach no necesita `id:` porque ImagenRemota es Identifiable.
                ForEach(viewModel.imagenes) { imagen in
                    CeldaCuadrada {
                        // AsyncImage entrega una "fase": cargando, éxito o fallo.
                        // Descarga la imagen sola, sin congelar la pantalla,
                        // y vuelve a llamar a este closure cada vez que cambia la fase.
                        AsyncImage(url: imagen.url) { fase in
                            // switch elige qué dibujar según la fase.
                            switch fase {
                            // Todavía descargando: ruedita de "cargando".
                            case .empty:
                                ProgressView()
                            // Descarga lista. `let imagenCargada` saca la imagen
                            // que viene "dentro" del caso para poder usarla.
                            case .success(let imagenCargada):
                                imagenCargada
                                    .resizable()
                                    .scaledToFill()
                            // Algo falló (sin internet, URL rota): ícono de aviso.
                            case .failure:
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.secondary)
                            // @unknown default cubre fases que Apple podría agregar
                            // en el futuro. Así el código sigue compilando.
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Imágenes remotas")
        // .task se ejecuta al aparecer la pantalla: aquí se pide la lista de URLs.
        .task {
            viewModel.cargar()
        }
    }
}
