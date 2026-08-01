import '../models/villager_model.dart';

/// Construye el mapa de eventos del calendario para una estación dada.
///
/// Extraído de [DefaultStardewData.getSeasonEvents] para que la clase
/// de datos estáticos solo contenga listas, no lógica de consulta/montaje.
class CalendarService {
  CalendarService._(); // no instanciable

  /// Devuelve un mapa día→lista-de-eventos para los 28 días de la [season] indicada.
  ///
  /// Incluye:
  /// - Cumpleaños de aldeanos (filtrados por estación).
  /// - Festivales vanilla de Stardew Valley 1.6.
  static Map<String, List<Map<String, String>>> getSeasonEvents(
    String season,
    List<VillagerModel> villagers,
  ) {
    final eventsMap = <String, List<Map<String, String>>>{};
    for (int i = 1; i <= 28; i++) {
      eventsMap[i.toString()] = [];
    }

    // Cumpleaños
    for (final v in villagers) {
      if (v.season.toLowerCase() == season.toLowerCase()) {
        eventsMap[v.day.toString()]?.add({
          'type': 'birthday',
          'title': 'Cumpleaños de ${v.name}',
          'villagerId': v.id,
        });
      }
    }

    // Festivales por estación
    switch (season.toLowerCase()) {
      case 'primavera':
      case 'spring':
        eventsMap['13']?.add({'type': 'festival', 'title': 'Festival del Huevo (Egg Festival)'});
        eventsMap['15']?.add({'type': 'festival', 'title': 'Festival del Desierto (Día 1)'});
        eventsMap['16']?.add({'type': 'festival', 'title': 'Festival del Desierto (Día 2)'});
        eventsMap['17']?.add({'type': 'festival', 'title': 'Festival del Desierto (Día 3)'});
        eventsMap['24']?.add({'type': 'festival', 'title': 'Danza de las Flores'});
        break;
      case 'verano':
      case 'summer':
        eventsMap['11']?.add({'type': 'festival', 'title': 'Luau de la Playa'});
        eventsMap['28']?.add({'type': 'festival', 'title': 'Danza de las Medusas Luciosas'});
        break;
      case 'otoño':
      case 'fall':
        eventsMap['16']?.add({'type': 'festival', 'title': 'Feria de Stardew Valley'});
        eventsMap['27']?.add({'type': 'festival', 'title': 'Víspera de los Espíritus'});
        break;
      case 'invierno':
      case 'winter':
        eventsMap['1']?.add({'type': 'festival', 'title': 'SquidFest (Día 1)'});
        eventsMap['2']?.add({'type': 'festival', 'title': 'SquidFest (Día 2)'});
        eventsMap['8']?.add({'type': 'festival', 'title': 'Festival del Hielo'});
        eventsMap['15']?.add({'type': 'festival', 'title': 'Mercado Nocturno (Día 1)'});
        eventsMap['16']?.add({'type': 'festival', 'title': 'Mercado Nocturno (Día 2)'});
        eventsMap['17']?.add({'type': 'festival', 'title': 'Mercado Nocturno (Día 3)'});
        eventsMap['25']?.add({'type': 'festival', 'title': 'Fiesta de la Estrella de Invierno'});
        break;
    }

    return eventsMap;
  }
}
