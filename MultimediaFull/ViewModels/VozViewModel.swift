import SwiftUI

/// Estado y acciones de la pantalla "Texto a voz" (ejemplo extra del día 2).
///
/// Capa MVVM: **ViewModel**. Guarda el texto y el idioma que elige el usuario
/// y le pide a `VozManager` que lo lea en voz alta. `VozView` solo dibuja y reenvía los toques.
///
/// - `@MainActor` hace que todo este código corra en el hilo principal,
///   que es el único que puede actualizar la pantalla.
/// - `@Observable` hace que SwiftUI vigile las propiedades: cuando una cambia,
///   la vista que la usa se vuelve a dibujar sola.
/// - Es una `class` porque la vista y el ViewModel deben compartir el mismo objeto (referencia).
@MainActor
@Observable
final class VozViewModel {

    // MARK: - Estado

    // Las dos son `var` normales porque la vista las cambia directamente
    // (el campo de texto y el Picker de idioma).

    /// Texto que se va a leer. Empieza con la frase de ejemplo en español.
    var texto = IdiomaVoz.espanol.ejemplo

    /// Idioma elegido. Al cambiar, la vista llama a `cambiarIdioma()`.
    var idioma: IdiomaVoz = .espanol

    /// El manager que habla. Lo crea este ViewModel porque maneja un recurso vivo (el sintetizador);
    /// así la voz se libera cuando se cierra la pantalla.
    /// `@ObservationIgnored` le dice a SwiftUI que no vigile esta propiedad:
    /// es una herramienta interna, no algo que se dibuje en pantalla.
    @ObservationIgnored private let voz = VozManager()

    // MARK: - Acciones

    /// Lee en voz alta el texto actual con el idioma elegido.
    func hablar() {
        voz.hablar(texto, idioma: idioma)
    }

    /// Calla la voz. La vista también lo llama al salir de la pantalla.
    func detener() {
        voz.detener()
    }

    /// Al cambiar de idioma se carga una frase de ejemplo en ese idioma.
    /// Primero se calla la voz para que no siga hablando en el idioma anterior.
    func cambiarIdioma() {
        voz.detener()
        texto = idioma.ejemplo
    }
}
