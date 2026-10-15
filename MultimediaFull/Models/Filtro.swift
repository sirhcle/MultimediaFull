/// Los filtros que ofrece el editor de fotos (ejemplo "Filtros", día 1).
///
/// Capa MVVM: **Model**. Es un dato simple; no hace trabajo, solo dice qué filtros existen.
/// El trabajo de aplicar el filtro lo hace `FiltroManager`.
///
/// - `enum` es una lista cerrada de opciones: un filtro solo puede ser uno de estos casos.
/// - `: String` hace que cada caso tenga un texto asociado, llamado `rawValue`.
///   Aquí ese texto es justo lo que ve el usuario en pantalla.
/// - `CaseIterable` te regala `Filtro.allCases`, un arreglo con todos los casos.
///   Así puedes recorrerlos con `ForEach` sin escribirlos a mano.
/// - `Identifiable` obliga a tener una propiedad `id` única.
///   SwiftUI la usa para distinguir cada elemento en listas y `ForEach`.
enum Filtro: String, CaseIterable, Identifiable {
    case original = "Original"
    case sepia = "Sepia"
    case mono = "Mono"
    case noir = "Noir"
    case negativo = "Negativo"

    /// Identificador de cada caso. Usamos su texto porque ya es único.
    /// Esto es una propiedad calculada (computed property): no guarda nada,
    /// calcula su valor cada vez que alguien la lee.
    var id: String { rawValue }
}
