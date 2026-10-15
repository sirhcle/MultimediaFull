import Foundation

/// Ayudante para mostrar tiempos como en un reloj ("1:15") en los reproductores y la grabadora.
///
/// Capa MVVM: **Service** (un ayudante compartido). Lo usan las vistas para mostrar
/// el tiempo actual y la duración. Es solo formato de texto, no hace trabajo pesado.
///
/// - `extension` agrega funciones o propiedades a un tipo que ya existe, sin modificarlo.
///   Aquí le agregamos `comoReloj` a `TimeInterval`, que es como Swift llama
///   a una cantidad de segundos (en realidad es un `Double`).
/// - El nombre del archivo `Tipo+Algo.swift` es la costumbre para extensiones.
extension TimeInterval {
    /// Convierte segundos en texto de reloj: 75.4 -> "1:15".
    ///
    /// Es una propiedad calculada: no guarda nada, calcula el texto cada vez que la lees.
    /// Se usa así: `tiempoActual.comoReloj`.
    var comoReloj: String {
        // guard: si el valor no es un número normal (por ejemplo, infinito o NaN,
        // que pasa cuando un video aún no sabe su duración) o es negativo,
        // salimos de inmediato devolviendo "0:00".
        // `self` es el propio número de segundos.
        guard isFinite, self >= 0 else { return "0:00" }
        // Int(...) quita los decimales: 75.4 -> 75.
        let total = Int(self)
        // total / 60 da los minutos y total % 60 los segundos que sobran.
        // "%02d" rellena con un cero a la izquierda: 5 -> "05".
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
