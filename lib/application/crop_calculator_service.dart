import '../models/crop_model.dart';

/// Servicio de cálculo de rentabilidad agrícola.
///
/// Contiene toda la lógica de negocio relacionada con cultivos:
/// crecimiento, cosechas, precios, curvas de ganancias y simulación
/// de pipeline de procesamiento.
///
/// Extrae esta lógica de [CropModel] para que el modelo sea una
/// entidad pura (solo datos), siguiendo el principio de responsabilidad única.
class CropCalculatorService {
  CropCalculatorService._(); // no instanciable

  // ────────────────────────────────────────────────────────────
  //  CRECIMIENTO
  // ────────────────────────────────────────────────────────────

  /// Días de crecimiento efectivos considerando fertilizante y profesión Agricultor.
  static int getEffectiveGrowthDays(
    CropModel crop, {
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
  }) {
    double speedBonus = 0.0;
    if (fertilizer == Fertilizer.basicSpeedGro) speedBonus += 0.10;
    if (fertilizer == Fertilizer.deluxeSpeedGro) speedBonus += 0.15;
    if (fertilizer == Fertilizer.hyperSpeedGro) speedBonus += 0.25;
    if (isAgriculturist) speedBonus += 0.10;

    final reduced = (crop.daysToGrow * (1.0 - speedBonus)).floor();
    return reduced < 1 ? 1 : reduced;
  }

  // ────────────────────────────────────────────────────────────
  //  COSECHAS
  // ────────────────────────────────────────────────────────────

  /// Número total de cosechas posibles en una estación de 28 días.
  static int totalHarvestsInSeason(
    CropModel crop, {
    int plantDay = 1,
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
    bool alreadyPlanted = false,
    int daysUntilFirstHarvest = 0,
    int? exactFirstHarvestDay,
  }) {
    final effectiveGrowth = getEffectiveGrowthDays(
      crop,
      fertilizer: fertilizer,
      isAgriculturist: isAgriculturist,
    );

    int firstHarvestDay;
    if (exactFirstHarvestDay != null && exactFirstHarvestDay > 0) {
      firstHarvestDay = exactFirstHarvestDay;
    } else if (alreadyPlanted && daysUntilFirstHarvest > 0) {
      firstHarvestDay = plantDay + daysUntilFirstHarvest;
    } else {
      firstHarvestDay = plantDay + effectiveGrowth;
    }

    if (firstHarvestDay > 28) return 0;

    if (crop.regrowDays <= 0) {
      final remainingAfterFirst = 28 - firstHarvestDay;
      if (remainingAfterFirst < 0) return 0;
      return 1 + (remainingAfterFirst / effectiveGrowth).floor();
    } else {
      int harvests = 1;
      final daysLeft = 28 - firstHarvestDay;
      harvests += (daysLeft / crop.regrowDays).floor();
      return harvests;
    }
  }

  /// Fechas exactas (días 1-28) en que se produce cada cosecha.
  static List<int> getHarvestDays(
    CropModel crop, {
    int plantDay = 1,
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
    bool alreadyPlanted = false,
    int daysUntilFirstHarvest = 0,
    int? exactFirstHarvestDay,
  }) {
    final harvestDays = <int>[];
    final effectiveGrowth = getEffectiveGrowthDays(
      crop,
      fertilizer: fertilizer,
      isAgriculturist: isAgriculturist,
    );

    int currentDay;
    if (exactFirstHarvestDay != null && exactFirstHarvestDay > 0) {
      currentDay = exactFirstHarvestDay;
    } else if (alreadyPlanted && daysUntilFirstHarvest > 0) {
      currentDay = plantDay + daysUntilFirstHarvest;
    } else {
      currentDay = plantDay + effectiveGrowth;
    }

    while (currentDay <= 28) {
      harvestDays.add(currentDay);
      currentDay +=
          crop.regrowDays > 0 ? crop.regrowDays : effectiveGrowth;
    }
    return harvestDays;
  }

  // ────────────────────────────────────────────────────────────
  //  PRECIOS
  // ────────────────────────────────────────────────────────────

  /// Precio de venta unitario según método de procesamiento y profesiones.
  static double getSellPrice(
    CropModel crop, {
    ProcessingMethod method = ProcessingMethod.raw,
    bool isTiller = false,
    bool isArtisan = false,
  }) {
    double price = crop.baseSellPrice;
    switch (method) {
      case ProcessingMethod.raw:
        if (isTiller) price *= 1.10;
        break;
      case ProcessingMethod.jar:
        price = (2 * crop.baseSellPrice) + 50;
        if (isArtisan) price *= 1.40;
        break;
      case ProcessingMethod.keg:
        price = crop.baseSellPrice * 3.0;
        if (isArtisan) price *= 1.40;
        break;
      case ProcessingMethod.dehydrator:
        price = (1.5 * crop.baseSellPrice * 5) + 5;
        if (isArtisan) price *= 1.40;
        break;
    }
    return price;
  }

  // ────────────────────────────────────────────────────────────
  //  RENTABILIDAD
  // ────────────────────────────────────────────────────────────

  /// Ganancia neta promedio por día (normalizada a 28 días).
  static double calculateDailyProfit(
    CropModel crop, {
    int plantDay = 1,
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
    bool isTiller = false,
    bool isArtisan = false,
    ProcessingMethod method = ProcessingMethod.raw,
    int cropQuantity = 1,
    bool alreadyPlanted = false,
    int daysUntilFirstHarvest = 0,
    int? exactFirstHarvestDay,
  }) {
    final harvests = totalHarvestsInSeason(
      crop,
      plantDay: plantDay,
      fertilizer: fertilizer,
      isAgriculturist: isAgriculturist,
      alreadyPlanted: alreadyPlanted,
      daysUntilFirstHarvest: daysUntilFirstHarvest,
      exactFirstHarvestDay: exactFirstHarvestDay,
    );
    if (harvests == 0) return 0;

    final itemPrice =
        getSellPrice(crop, method: method, isTiller: isTiller, isArtisan: isArtisan);
    final seedTimes = crop.regrowDays > 0 ? 1 : harvests;
    final totalSeedCost = alreadyPlanted ? 0.0 : crop.seedCost * seedTimes * cropQuantity;
    final totalRevenue = itemPrice * harvests * cropQuantity;
    return (totalRevenue - totalSeedCost) / 28.0;
  }

  // ────────────────────────────────────────────────────────────
  //  CURVA DE GANANCIAS (estilo Bitcoin)
  // ────────────────────────────────────────────────────────────

  /// Genera 28 puntos de datos para la gráfica de rentabilidad acumulada.
  static List<DailyEarning> getDailyEarningsCurve(
    CropModel crop, {
    int plantDay = 1,
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
    bool isTiller = false,
    bool isArtisan = false,
    ProcessingMethod method = ProcessingMethod.raw,
    int cropQuantity = 1,
    bool alreadyPlanted = false,
    int daysUntilFirstHarvest = 0,
    int? exactFirstHarvestDay,
  }) {
    final harvestDaysList = getHarvestDays(
      crop,
      plantDay: plantDay,
      fertilizer: fertilizer,
      isAgriculturist: isAgriculturist,
      alreadyPlanted: alreadyPlanted,
      daysUntilFirstHarvest: daysUntilFirstHarvest,
      exactFirstHarvestDay: exactFirstHarvestDay,
    );

    final itemPrice =
        getSellPrice(crop, method: method, isTiller: isTiller, isArtisan: isArtisan);
    final harvests = harvestDaysList.length;
    final seedTimes = crop.regrowDays > 0 ? 1 : harvests;
    final totalSeedCost =
        alreadyPlanted ? 0.0 : crop.seedCost * seedTimes * cropQuantity;

    double cumulative = -totalSeedCost;
    final harvestSet = harvestDaysList.toSet();
    final curve = <DailyEarning>[];

    for (int day = 1; day <= 28; day++) {
      final isHarvest = harvestSet.contains(day);
      double earned = 0;
      if (isHarvest) {
        earned = itemPrice * cropQuantity;
        cumulative += earned;
      }
      curve.add(DailyEarning(
        day: day,
        earned: earned,
        cumulative: cumulative,
        isHarvestDay: isHarvest,
      ));
    }
    return curve;
  }

  // ────────────────────────────────────────────────────────────
  //  SIMULADOR DE PIPELINE
  // ────────────────────────────────────────────────────────────

  /// Simula la cadena de procesamiento de los cultivos cosechados.
  ///
  /// Usa un algoritmo greedy (earliest-free-equipment) para asignar
  /// cada unidad cosechada al equipo disponible más pronto.
  ///
  /// Devuelve métricas de cuello de botella, diagrama de Gantt y ROI.
  static PipelineResult simulatePipeline(
    CropModel crop, {
    int plantDay = 1,
    Fertilizer fertilizer = Fertilizer.none,
    bool isAgriculturist = false,
    bool isTiller = false,
    bool isArtisan = false,
    ProcessingMethod method = ProcessingMethod.keg,
    int cropQuantity = 1,
    int equipmentCount = 10,
    bool alreadyPlanted = false,
    int daysUntilFirstHarvest = 0,
  }) {
    // Días de procesamiento por método
    final processDays = switch (method) {
      ProcessingMethod.keg => 7,
      ProcessingMethod.jar => 4,
      ProcessingMethod.dehydrator => 7,
      ProcessingMethod.raw => 0,
    };

    if (method == ProcessingMethod.raw) {
      final price = getSellPrice(crop,
          method: method, isTiller: isTiller, isArtisan: isArtisan);
      return PipelineResult(
        totalCrops: cropQuantity,
        totalProcessed: cropQuantity,
        daysToProcessAll: 0,
        recommendedEquipment: 0,
        hasBottleneck: false,
        bottleneckMessage: 'Venta directa: no requiere equipos de procesamiento.',
        totalRevenue: price * cropQuantity,
        seedCost: crop.seedCost * cropQuantity,
        netProfit: price * cropQuantity - crop.seedCost * cropQuantity,
        batches: [],
      );
    }

    final harvests = totalHarvestsInSeason(
      crop,
      plantDay: plantDay,
      fertilizer: fertilizer,
      isAgriculturist: isAgriculturist,
      alreadyPlanted: alreadyPlanted,
      daysUntilFirstHarvest: daysUntilFirstHarvest,
    );
    final totalCrops = harvests * cropQuantity;
    final itemPrice =
        getSellPrice(crop, method: method, isTiller: isTiller, isArtisan: isArtisan);

    // Estado de equipos: día en que queda libre cada uno
    final equipmentFreeAt = List.filled(equipmentCount, 1);
    final batches = <Map<String, dynamic>>[];
    int processed = 0;

    final harvestDaysList = getHarvestDays(
      crop,
      plantDay: plantDay,
      fertilizer: fertilizer,
      isAgriculturist: isAgriculturist,
      alreadyPlanted: alreadyPlanted,
      daysUntilFirstHarvest: daysUntilFirstHarvest,
    );

    for (final harvestDay in harvestDaysList) {
      for (int i = 0; i < cropQuantity; i++) {
        // Equipo disponible más pronto
        int minIdx = 0;
        for (int j = 1; j < equipmentCount; j++) {
          if (equipmentFreeAt[j] < equipmentFreeAt[minIdx]) minIdx = j;
        }
        final startDay = equipmentFreeAt[minIdx] < harvestDay
            ? harvestDay
            : equipmentFreeAt[minIdx];
        final endDay = startDay + processDays;
        equipmentFreeAt[minIdx] = endDay;
        processed++;
        batches.add({
          'equipment': minIdx,
          'startDay': startDay,
          'endDay': endDay,
          'batch': processed,
        });
      }
    }

    final maxEndDay = equipmentFreeAt.reduce((a, b) => a > b ? a : b);
    final daysToProcessAll = maxEndDay - 1;

    // Equipos necesarios para terminar dentro de 28 días
    int recommended = equipmentCount;
    if (totalCrops > 0) {
      final processablePerEquipment = 28 / processDays;
      recommended = (totalCrops / processablePerEquipment).ceil();
    }

    final hasBottleneck = daysToProcessAll > 28;
    final equipName = switch (method) {
      ProcessingMethod.keg => 'barriles',
      ProcessingMethod.jar => 'envases',
      ProcessingMethod.dehydrator => 'deshidratadoras',
      ProcessingMethod.raw => 'equipos',
    };
    final msg = hasBottleneck
        ? 'Tus $equipmentCount $equipName tardan ${daysToProcessAll - 28} días extra. '
            'Necesitas $recommended $equipName para procesar todo en 28 días.'
        : '¡Tus $equipmentCount $equipName son suficientes! '
            'Terminas de procesar todo en el día $daysToProcessAll.';

    final seedCostTotal = alreadyPlanted
        ? 0.0
        : crop.seedCost * (crop.regrowDays > 0 ? 1 : harvests) * cropQuantity;

    return PipelineResult(
      totalCrops: totalCrops,
      totalProcessed: processed,
      daysToProcessAll: daysToProcessAll,
      recommendedEquipment: recommended,
      hasBottleneck: hasBottleneck,
      bottleneckMessage: msg,
      totalRevenue: itemPrice * processed,
      seedCost: seedCostTotal,
      netProfit: itemPrice * processed - seedCostTotal,
      batches: batches,
    );
  }
}
