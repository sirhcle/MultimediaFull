import SwiftUI

/// Celda cuadrada con esquinas redondeadas para mostrar una miniatura.
///
/// Capa MVVM: **View** auxiliar. No tiene estado ni ViewModel; solo da forma.
/// La usan la galería, el álbum (a través de `MiniaturaView`) y las imágenes remotas,
/// para que todas las cuadrículas se vean iguales sin repetir código.
///
/// El fondo gris fija el tamaño; el contenido se dibuja encima y se recorta.
///
/// - `<Contenido: View>` es un genérico: "Contenido" es un hueco para
///   **cualquier** tipo de vista. Quien usa la celda decide qué poner dentro
///   (una `Image`, un `AsyncImage`, un `ProgressView`...).
///   Es lo mismo que hacen `VStack` o `Button` con lo que les pasas entre llaves.
struct CeldaCuadrada<Contenido: View>: View {
    /// La vista que va dentro de la celda.
    ///
    /// - Es un closure `() -> Contenido`: una función sin parámetros que devuelve la vista.
    /// - `@ViewBuilder` permite escribir dentro varias vistas, `if` o `switch`,
    ///   igual que en un `body`.
    /// - Gracias a esto puedes escribir `CeldaCuadrada { Image(...) }` con llaves al final,
    ///   lo que se llama "trailing closure".
    @ViewBuilder let contenido: () -> Contenido

    var body: some View {
        // 1. Un color de fondo que, con aspectRatio(1), siempre mide lo mismo de ancho que de alto.
        //    Es el que manda en el tamaño, así todas las celdas quedan cuadradas.
        Color.gray.opacity(0.15)
            .aspectRatio(1, contentMode: .fit)
            // 2. overlay pone el contenido encima del fondo, ocupando su mismo espacio.
            //    Si una foto es más grande (por ejemplo con scaledToFill), se sale del cuadro...
            .overlay { contenido() }
            // 3. ...y clipShape recorta todo lo que sobresale, con esquinas redondeadas.
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
