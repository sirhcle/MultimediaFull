/// Los idiomas que ofrece la pantalla de texto a voz (ejemplo "Texto a voz", día 2).
///
/// Capa MVVM: **Model**. Solo describe opciones; quien habla es `VozManager`.
///
/// - `enum` es una lista cerrada de opciones.
/// - `: String` da a cada caso un texto (`rawValue`); aquí es el que ve el usuario.
/// - `CaseIterable` te da `IdiomaVoz.allCases` para recorrer todos los idiomas,
///   por ejemplo dentro de un `Picker`.
/// - `Identifiable` pide un `id` único para que SwiftUI distinga cada opción.
enum IdiomaVoz: String, CaseIterable, Identifiable {
    case espanol = "Español"
    case ingles = "Inglés"
    case frances = "Francés"

    /// Identificador de cada caso: su propio texto, que ya es único.
    var id: String { rawValue }

    /// Código de idioma y país que entiende el sintetizador de voz ("es-MX" = español de México).
    ///
    /// `switch self` revisa en qué caso estás y devuelve un valor distinto para cada uno.
    /// Swift te obliga a cubrir todos los casos, así que si agregas un idioma
    /// nuevo y olvidas ponerlo aquí, el proyecto no compila. Eso evita errores.
    var codigo: String {
        switch self {
        case .espanol: "es-MX"
        case .ingles: "en-US"
        case .frances: "fr-FR"
        }
    }

    /// Frase de ejemplo en cada idioma, para que el usuario pueda probar la voz rápido.
    var ejemplo: String {
        switch self {
        case .espanol: "Hola, esta es una voz sintética hablando desde tu app."
        case .ingles: "Hello, this is a synthetic voice speaking from your app."
        case .frances: "Bonjour, ceci est une voix synthétique dans votre application."
        }
    }
}
