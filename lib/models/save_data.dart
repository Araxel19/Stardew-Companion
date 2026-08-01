class StardewSaveData {
  final String farmerName;
  final String farmName;
  final int currentMoney;
  final int totalEarnings;
  final int gameYear;
  final String gameSeason;
  final int gameDay;
  final double playtimeHours;

  final Map<String, int> cookingRecipes; // Recipe Name -> Times Cooked
  final Map<String, int> craftingRecipes; // Recipe Name -> Times Crafted
  final Map<String, int> fishCaught; // Fish Name -> Count
  final Map<String, int> shippingItems; // Item ID/Name -> Count
  final Map<String, VillagerFriendship> friendships; // Npc Name -> Friendship
  final Map<String, int> monsterKills; // Monster -> Count
  final List<String> stardrops;
  final bool hasGoldenClock;
  final int obelisksCount;

  final Set<String> detectedMods;

  StardewSaveData({
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

  // Cálculo de Porcentaje de Perfección
  double get perfectionPercentage {
    int totalCategoryScore = 0;
    
    // 1. Reloj de Oro (10%)
    double goldenClockScore = hasGoldenClock ? 10.0 : 0.0;
    
    // 2. Obeliscos (10% - 4 obeliscos)
    double obeliskScore = (obelisksCount / 4.0).clamp(0.0, 1.0) * 10.0;

    // 3. Recetas Cocinadas (15%)
    int cookedCount = cookingRecipes.values.where((count) => count > 0).length;
    double cookingScore = (cookingRecipes.isEmpty ? 0 : (cookedCount / cookingRecipes.length)).clamp(0.0, 1.0) * 15.0;

    // 4. Objetos Fabricados (15%)
    int craftedCount = craftingRecipes.values.where((count) => count > 0).length;
    double craftingScore = (craftingRecipes.isEmpty ? 0 : (craftedCount / craftingRecipes.length)).clamp(0.0, 1.0) * 15.0;

    // 5. Peces Atrapados (15%)
    int fishCount = fishCaught.values.where((count) => count > 0).length;
    double fishingScore = (fishCaught.isEmpty ? 0 : (fishCount / fishCaught.length)).clamp(0.0, 1.0) * 15.0;

    // 6. Amistad con Aldeanos (15%)
    int maxHeartVillagers = friendships.values.where((f) => f.hearts >= 8).length;
    double friendshipScore = (friendships.isEmpty ? 0 : (maxHeartVillagers / friendships.length)).clamp(0.0, 1.0) * 15.0;

    // 7. Objetos Enviados (15%)
    int shippedCount = shippingItems.values.where((count) => count > 0).length;
    double shippingScore = (shippingItems.isEmpty ? 0 : (shippedCount / 100.0)).clamp(0.0, 1.0) * 15.0;

    // 8. Stardrops (5%)
    double stardropScore = (stardrops.length / 7.0).clamp(0.0, 1.0) * 5.0;

    totalCategoryScore = (goldenClockScore + obeliskScore + cookingScore + craftingScore + fishingScore + friendshipScore + shippingScore + stardropScore).round();
    return totalCategoryScore.toDouble().clamp(0.0, 100.0);
  }
}

class VillagerFriendship {
  final String name;
  final int points;
  final int hearts; // points / 250
  final bool isModded;

  VillagerFriendship({
    required this.name,
    required this.points,
    required this.hearts,
    this.isModded = false,
  });
}
