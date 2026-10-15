import AVFoundation

/// Convierte texto en voz hablada (ejemplo "Texto a voz", día 2).
///
/// Capa MVVM: **Service** (manager). Recibe un texto y un idioma y lo lee en voz alta.
/// `VozViewModel` decide qué texto y qué idioma usar.
///
/// Usa `AVSpeechSynthesizer`, el sintetizador de voz de iOS: no necesita internet
/// porque usa las voces que ya trae el sistema.
///
/// Es una `class` porque maneja un recurso vivo (el sintetizador) que se comparte por referencia.
/// No es un singleton: cada pantalla crea el suyo con `VozManager()`, y la voz se apaga
/// cuando la pantalla se cierra.
final class VozManager {

    // MARK: - Estado

    /// El sintetizador que habla. Se crea una vez y se reutiliza para cada frase.
    private let sintetizador = AVSpeechSynthesizer()

    /// true mientras el sintetizador está hablando.
    var estaHablando: Bool { sintetizador.isSpeaking }

    // MARK: - Acciones

    /// Lee `texto` en voz alta con el `idioma` elegido.
    func hablar(_ texto: String, idioma: IdiomaVoz) {
        // Si ya estaba hablando, lo callamos primero; si no, la frase nueva
        // se formaría en la fila y sonaría hasta que acabe la anterior.
        sintetizador.stopSpeaking(at: .immediate)

        // `AVSpeechUtterance` es "una frase para decir": lleva el texto y cómo decirlo.
        // - `voice`: la voz del idioma, a partir de un código como "es-MX".
        // - `rate`: la velocidad; usamos la normal que trae iOS.
        // Al final se la damos al sintetizador para que la diga.
        let frase = AVSpeechUtterance(string: texto)
        frase.voice = AVSpeechSynthesisVoice(language: idioma.codigo)
        frase.rate = AVSpeechUtteranceDefaultSpeechRate
        sintetizador.speak(frase)
    }

    /// Calla la voz en ese mismo instante (`.immediate`), aunque esté a mitad de una palabra.
    func detener() {
        sintetizador.stopSpeaking(at: .immediate)
    }
}
