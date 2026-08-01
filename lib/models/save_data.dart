import 'villager_friendship.dart';

// ─────────────────────────────────────────────────────────────
//  ENTIDADES PURAS — solo datos, sin lógica de negocio
//  La lógica de perfección vive en PerfectionService
// ─────────────────────────────────────────────────────────────

/// Snapshot de los datos de la partida guardada del granjero.
class StardewSaveData {
  final String farmerName;
  final String farmName;
  final int currentMoney;
  final int totalEarnings;
  final int gameYear;
  final String gameSeason;
  final int gameDay;
  final double playtimeHours;

  final Map<String, int> cookingRecipes;   // Nombre → veces cocinado
  final Map<String, int> craftingRecipes;  // Nombre → veces fabricado
  final Map<String, int> fishCaught;       // Nombre → cantidad
  final Map<String, int> shippingItems;    // ID/Nombre → cantidad
  final Map<String, VillagerFriendship> friendships; // NPC → amistad
  final Map<String, int> monsterKills;     // Monstruo → cantidad
  final List<String> stardrops;
  final bool hasGoldenClock;
  final int obelisksCount;
  final Set<String> detectedMods;

  const StardewSaveData({
    required this.farmerName,
    required this.farmName,
    required this.currentMoney,
    required this.totalEarnings,
    required this.gameYear,
    required this.gameSeason,
    required this.gameDay,
    required this.playtimeHours,
    required this.cookingRecipes,
    required this.craftingRecipes,
    required this.fishCaught,
    required this.shippingItems,
    required this.friendships,
    required this.monsterKills,
    required this.stardrops,
    required this.hasGoldenClock,
    required this.obelisksCount,
    required this.detectedMods,
  });
}

/// Información de un mod instalado de Stardew Valley.
class StardewModInfo {
  final String name;
  final String version;
  final String author;
  final String description;
  final String uniqueId;
  final String folderPath;

  const StardewModInfo({
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    required this.uniqueId,
    required this.folderPath,
  });
}
