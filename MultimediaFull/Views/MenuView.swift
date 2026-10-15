// SwiftUI es el framework de Apple para dibujar pantallas describiendo
// "qué quieres ver" en lugar de "cómo dibujarlo paso a paso".
import SwiftUI

/// Pantalla de inicio: lista de ejemplos agrupados por día.
///
/// Capa MVVM: **View**. Solo dibuja el menú y decide a qué pantalla ir.
/// No tiene ViewModel porque no guarda estado: los datos salen del enum `Ejemplo`.
///
/// Es el **único** `NavigationStack` de la app; las pantallas de ejemplo no crean el suyo.
/// Si cada pantalla tuviera su propio `NavigationStack`, verías barras de navegación
/// dobles y el botón de "atrás" se comportaría raro.
///
/// - `struct MenuView: View` declara una vista. En SwiftUI las vistas son `struct`
///   (tipos de valor, ligeros) y cumplen el protocolo `View`.
/// - `View` solo pide una cosa: la propiedad `body`, que describe lo que se dibuja.
struct MenuView: View {
    // MARK: - Cuerpo

    /// `some View` significa "alguna vista concreta que Swift deduce solo".
    /// Así no tienes que escribir el tipo exacto, que sería larguísimo.
    var body: some View {
        // NavigationStack permite ir de una pantalla a otra y volver con "atrás".
        // Guarda una "pila" de pantallas: entras apilando, regresas quitando.
        NavigationStack {
            // List dibuja una lista con desplazamiento, al estilo de Ajustes.
            List {
                // ForEach repite su contenido por cada elemento.
                // Seccion.allCases existe gracias a CaseIterable (ver Ejemplo.swift).
                // Lo que va entre llaves es un closure: recibe cada `seccion`
                // y devuelve la vista que le corresponde.
                ForEach(Seccion.allCases) { seccion in
                    // Section agrupa filas bajo un encabezado ("Día 1 · Imágenes").
                    // rawValue es el texto que le dimos a cada caso del enum.
                    Section(seccion.rawValue) {
                        ForEach(seccion.ejemplos) { ejemplo in
                            // NavigationLink(value:) no crea la pantalla destino aquí.
                            // Solo dice "al tocar, navega con este valor".
                            // Quién se dibuja lo decide .navigationDestination más abajo.
                            NavigationLink(value: ejemplo) {
                                // Label junta un texto y un ícono SF Symbol en una fila.
                                Label(ejemplo.titulo, systemImage: ejemplo.icono)
                            }
                        }
                    }
                }
            }
            // Título grande en la barra de arriba.
            .navigationTitle("Multimedia")
            // navigationDestination conecta un tipo de valor con una pantalla.
            // Cuando un NavigationLink manda un `Ejemplo`, aquí se recibe
            // y se construye la vista que toca. Por eso `Ejemplo` debe ser Hashable.
            .navigationDestination(for: Ejemplo.self) { ejemplo in
                destino(para: ejemplo)
            }
        }
    }

    // MARK: - Ayudantes

    /// Construye la pantalla de cada ejemplo. Cada vista crea su propio ViewModel.
    ///
    /// - `@ViewBuilder` deja que la función devuelva vistas de tipos distintos
    ///   según el caso del `switch` (una `GaleriaView`, una `AlbumView`...).
    ///   Sin él, Swift exigiría que todas las ramas devolvieran el mismo tipo.
    /// - `private` significa que solo se usa dentro de `MenuView`.
    @ViewBuilder
    private func destino(para ejemplo: Ejemplo) -> some View {
        // switch revisa en qué caso está `ejemplo` y ejecuta solo esa rama.
        // Swift te obliga a cubrir todos los casos: si agregas uno nuevo al enum
        // y olvidas ponerlo aquí, el proyecto no compila. Así no se te pasa ninguno.
        switch ejemplo {
        // Día 1: imágenes
        case .galeria:
            GaleriaView()
        case .album:
            AlbumView()
        case .filtros:
            FiltrosView()
        case .imagenesRemotas:
            ImagenesRemotasView()
        // Día 2: audio
        case .reproductorAudio:
            ReproductorAudioView()
        case .grabadora:
            GrabadoraView()
        case .textoAVoz:
            VozView()
        case .misAudios:
            MisAudiosView()
        // Día 3: video y cámara
        case .reproductorVideo:
            ReproductorVideoView()
        case .videoteca:
            VideotecaView()
        case .controlesVideo:
            ControlesVideoView()
        case .camara:
            CamaraView()
        }
    }
}
