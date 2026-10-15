import SwiftUI

/// Pantalla del ejemplo "Cámara" (capa View de MVVM).
/// Muestra en vivo lo que ve la cámara y un botón redondo para tomar fotos,
/// que se guardan en "Mi álbum". Solo dibuja y le avisa a `CamaraViewModel`
/// lo que hace el usuario. Requiere un iPhone o iPad reales.
struct CamaraView: View {
    /// `@State` hace que la vista sea dueña del ViewModel: se crea una sola vez
    /// y sobrevive aunque SwiftUI vuelva a dibujar la pantalla.
    @State private var viewModel = CamaraViewModel()

    /// `some View` significa "devuelvo algún tipo de vista"; Swift averigua cuál.
    var body: some View {
        // `ZStack` apila vistas una encima de otra: el fondo negro abajo y la cámara arriba.
        ZStack {
            Color.black.ignoresSafeArea()

            // Tres casos: la cámara está lista, se está preparando o algo falló.
            if viewModel.listo {
                VistaPreviaCamara(sesion: viewModel.sesion)
                    .ignoresSafeArea()
            } else if viewModel.mensaje.isEmpty {
                // Mientras `mensaje` esté vacío, la cámara se sigue preparando.
                // `ProgressView` es el indicador de "cargando" que gira.
                ProgressView("Preparando la cámara…")
                    .tint(.white)
                    .foregroundStyle(.white)
            } else {
                // Si hay mensaje, la cámara no se pudo usar y explicas el motivo.
                ContentUnavailableView(
                    "Cámara no disponible",
                    systemImage: "camera.fill",
                    description: Text(viewModel.mensaje)
                )
                .foregroundStyle(.white)
            }
        }
        // `.overlay` dibuja algo encima de la vista; aquí, pegado abajo.
        .overlay(alignment: .bottom) {
            if viewModel.listo {
                VStack(spacing: 12) {
                    // Aviso flotante, por ejemplo "Foto guardada en Mi álbum."
                    if !viewModel.mensaje.isEmpty {
                        Text(viewModel.mensaje)
                            .font(.footnote)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    // Botón de disparo: un círculo blanco con un anillo, como en la app Cámara.
                    Button {
                        viewModel.tomarFoto()
                    } label: {
                        Circle()
                            .fill(.white)
                            .frame(width: 72, height: 72)
                            .overlay(Circle().stroke(.black.opacity(0.2), lineWidth: 4).padding(4))
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Cámara")
        .navigationBarTitleDisplayMode(.inline)
        // `.task` corre trabajo `async` cuando la vista aparece, y lo cancela
        // solo si la vista desaparece. Aquí pide permiso y enciende la cámara.
        .task {
            await viewModel.preparar()
        }
        // `.onDisappear` corre al salir de la pantalla: apagas la cámara para ahorrar batería.
        .onDisappear {
            viewModel.detener()
        }
    }
}
