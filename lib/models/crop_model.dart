enum Fertilizer { none, basicSpeedGro, deluxeSpeedGro, hyperSpeedGro }
enum Profession { none, agriculturist, tiller, artisan }
enum ProcessingMethod { raw, jar, keg, dehydrator }

class CropModel {
  final String id;
  final String name;
  final String season; // Primavera, Verano, Otoño, Invierno, Invernadero
  final double seedCost;
  final double baseSellPrice;
  final int daysToGrow;
  final int regrowDays; // 0 if single harvest
  final String sourceMod; // 'Vanilla', 'Ridgeside Village', 'Stardew Valley Expanded', etc.

  CropModel({
    required this.id,
    required this.name,
    required this.season,
    required this.seedCost,
    required this.baseSellPrice,
    required this.daysToGrow,
    this.regrowDays = 0,
    this.sourceMod = 'Vanilla',
  });

  // Días de crecimiento calculados con fertilizante y profesión
  int getEffectiveGrowthDays({Fertilizer fertilizer = Fertilizer.none, bool isAgriculturist = false}) {
    double speedBonus = 0.0;
    if (fertilizer == Fertilizer.basicSpeedGro) speedBonus += 0.10;
    if (fertilizer == Fertilizer.deluxeSpeedGro) speedBonus += 0.15;
    if (fertilizer == Fertilizer.hyperSpeedGro) speedBonus += 0.25;
    if (isAgriculturist) speedBonus += 0.10;

    int reducedDays = (daysToGrow * (1.0 - speedBonus)).floor();
    return reducedDays < 1 ? 1 : reducedDays;
  }

  // Número total de cosechas en una estación de 28 días
  int totalHarvestsInSeason({
    int plantDay = 1,
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
  }) {
    int effectiveGrowth = getEffectiveGrowthDays(fertilizer: fertilizer, isAgriculturist: isAgriculturist);
    int remainingDays = 28 - plantDay + 1;

    if (remainingDays < effectiveGrowth) return 0;

    if (regrowDays <= 0) {
      // Cosecha única - cuántas veces se puede resembrar
      return (remainingDays / effectiveGrowth).floor();
    } else {
      // Cultivo recurrente
      int harvests = 1;
      int daysLeft = remainingDays - effectiveGrowth;
      harvests += (daysLeft / regrowDays).floor();
      return harvests;
    }
  }

  // Fechas exactas de cosecha en el calendario de 28 días
  List<int> getHarvestDays({
    int plantDay = 1,
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
  }) {
    List<int> harvestDays = [];
    int effectiveGrowth = getEffectiveGrowthDays(fertilizer: fertilizer, isAgriculturist: isAgriculturist);
    int currentDay = plantDay + effectiveGrowth;

    while (currentDay <= 28) {
      harvestDays.add(currentDay);
      if (regrowDays <= 0) {
        currentDay += effectiveGrowth; // Resembrar
      } else {
        currentDay += regrowDays; // Re-cosecha
      }
    }
    return harvestDays;
  }

  // Precios de venta procesados
  double getSellPrice({
    ProcessingMethod method = ProcessingMethod.raw,
    bool isTiller = false,
    bool isArtisan = false,
  }) {
    double price = baseSellPrice;

    switch (method) {
      case ProcessingMethod.raw:
        if (isTiller) price *= 1.10;
        break;
      case ProcessingMethod.jar:
        price = (2 * baseSellPrice) + 50;
        if (isArtisan) price *= 1.40;
        break;
      case ProcessingMethod.keg:
        // Frutas multiplicador 3x, Vegetales multiplicador 2.25x
        price = baseSellPrice * 3.0; 
        if (isArtisan) price *= 1.40;
        break;
      case ProcessingMethod.dehydrator:
        price = (1.5 * baseSellPrice * 5) + 5;
        if (isArtisan) price *= 1.40;
        break;
    }
    return price;
  }

  // Ganancia neta por día
  double calculateDailyProfit({
    int plantDay = 1,
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
    bool isTiller = false,
    bool isArtisan = false,
    ProcessingMethod method = ProcessingMethod.raw,
    int cropQuantity = 1,
  }) {
    int harvests = totalHarvestsInSeason(plantDay: plantDay, fertilizer: fertilizer, isAgriculturist: isAgriculturist);
    if (harvests == 0) return 0;

    double itemPrice = getSellPrice(method: method, isTiller: isTiller, isArtisan: isArtisan);
    int seedTimes = regrowDays > 0 ? 1 : harvests;
    double totalSeedCost = seedCost * seedTimes * cropQuantity;
    double totalRevenue = itemPrice * harvests * cropQuantity;

    double netProfit = totalRevenue - totalSeedCost;
    return netProfit / 28.0;
  }
}
