import '../models/save_data.dart';

/// Calcula el porcentaje de perfección del granjero según los 8 criterios del juego.
///
/// Extraído de [StardewSaveData] para que el modelo sea una entidad pura
/// y la lógica de puntuación sea testeable de forma independiente.
class PerfectionService {
  PerfectionService._(); // no instanciable

  /// Calcula el porcentaje de perfección (0–100) para los datos de partida dados.
  ///
  /// Categorías y pesos:
  /// - Reloj de Oro: 10%
  /// - Obeliscos (4 tipos): 10%
  /// - Recetas cocinadas: 15%
  /// - Objetos fabricados: 15%
  /// - Peces atrapados: 15%
  /// - Amistad (≥8 corazones): 15%
  /// - Objetos enviados: 15%
  /// - Stardrops: 5%
  static double calculate(StardewSaveData data) {
    // 1. Reloj de Oro (10%)
    final goldenClockScore = data.hasGoldenClock ? 10.0 : 0.0;

    // 2. Obeliscos (10% — 4 obeliscos)
    final obeliskScore = (data.obelisksCount / 4.0).clamp(0.0, 1.0) * 10.0;

    // 3. Recetas Cocinadas (15%)
    final cookedCount =
        data.cookingRecipes.values.where((c) => c > 0).length;
    final cookingScore = data.cookingRecipes.isEmpty
        ? 0.0
        : (cookedCount / data.cookingRecipes.length).clamp(0.0, 1.0) * 15.0;

    // 4. Objetos Fabricados (15%)
    final craftedCount =
        data.craftingRecipes.values.where((c) => c > 0).length;
    final craftingScore = data.craftingRecipes.isEmpty
        ? 0.0
        : (craftedCount / data.craftingRecipes.length).clamp(0.0, 1.0) * 15.0;

    // 5. Peces Atrapados (15%)
    final fishCount = data.fishCaught.values.where((c) => c > 0).length;
    final fishingScore = data.fishCaught.isEmpty
        ? 0.0
        : (fishCount / data.fishCaught.length).clamp(0.0, 1.0) * 15.0;

    // 6. Amistad con Aldeanos (15% — ≥8 corazones)
    final maxHeartVillagers =
        data.friendships.values.where((f) => f.hearts >= 8).length;
    final friendshipScore = data.friendships.isEmpty
        ? 0.0
        : (maxHeartVillagers / data.friendships.length).clamp(0.0, 1.0) * 15.0;

    // 7. Objetos Enviados (15%)
    final shippedCount =
        data.shippingItems.values.where((c) => c > 0).length;
    final shippingScore =
        (shippedCount / 100.0).clamp(0.0, 1.0) * 15.0;

    // 8. Stardrops (5%)
    final stardropScore = (data.stardrops.length / 7.0).clamp(0.0, 1.0) * 5.0;

    final total = goldenClockScore +
        obeliskScore +
        cookingScore +
        craftingScore +
        fishingScore +
        friendshipScore +
        shippingScore +
        stardropScore;

    return total.round().toDouble().clamp(0.0, 100.0);
  }
}
