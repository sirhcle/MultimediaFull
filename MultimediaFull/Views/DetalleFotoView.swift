import SwiftUI

/// Muestra una foto a pantalla completa con un botón para cerrar.
///
/// Capa MVVM: **View** auxiliar del ejemplo "Galería". No tiene ViewModel:
/// recibe la foto ya lista y solo la dibuja.
/// `GaleriaView` la abre con `.fullScreenCover` al tocar una miniatura.
struct DetalleFotoView: View {
    /// La foto que se va a mostrar. Es `let` porque esta vista no la cambia.
    let foto: Foto

    /// `@Environment` lee valores que SwiftUI comparte con todas las vistas.
    /// `\.dismiss` es una acción que cierra la pantalla actual
    /// (aquí, la que se abrió con `.fullScreenCover`).
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // ZStack apila vistas una encima de otra (como capas).
        ZStack {
            // Fondo negro que cubre toda la pantalla, incluso bajo la barra de estado.
            // ignoresSafeArea hace que se salga de las "zonas seguras" (muesca, borde inferior).
            Color.black.ignoresSafeArea()

            // La foto. resizable deja cambiarle el tamaño y scaledToFit
            // la hace caber completa sin deformarla ni recortarla.
            Image(uiImage: foto.imagen)
                .resizable()
                .scaledToFit()
        }
        // Botón de cerrar en la esquina superior derecha, encima de todo.
        .overlay(alignment: .topTrailing) {
            // Este Button usa dos closures: la acción (lo que pasa al tocar)
            // y `label:` (cómo se ve el botón).
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding()
            }
        }
    }
}
