// import trae a este archivo las herramientas de un framework de Apple.
// SwiftUI es el framework con el que dibujamos toda la interfaz.
import SwiftUI

/// Punto de entrada de la app: es lo primero que se ejecuta al abrirla.
///
/// No pertenece a ninguna capa de MVVM en particular; solo arranca la app
/// y muestra la primera pantalla, `MenuView`, desde donde se llega a todos los ejemplos.
///
/// - `@main` le dice a Swift: "aquí empieza la app". Solo puede haber uno en todo el proyecto.
/// - `struct` es un tipo de dato propio. En SwiftUI casi todo se escribe como struct.
/// - `: App` significa que este struct cumple el protocolo `App`, o sea,
///   que sabe describir una app completa.
@main
struct MultimediaApp: App {
    // body describe qué contiene la app.
    // "some Scene" quiere decir: "devuelvo algún tipo de escena; Swift sabe cuál".
    var body: some Scene {
        // WindowGroup es la ventana principal. En iPhone ocupa toda la pantalla.
        // Lo que pongas dentro es la primera vista que ve el usuario.
        WindowGroup {
            MenuView()
        }
    }
}
