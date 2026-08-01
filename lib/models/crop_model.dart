// Enums de dominio agrícola
enum Fertilizer { none, basicSpeedGro, deluxeSpeedGro, hyperSpeedGro }
enum Profession { none, agriculturist, tiller, artisan }
enum ProcessingMethod { raw, jar, keg, dehydrator }

// ─────────────────────────────────────────────────────────────
//  Value objects de resultado (usados por CropCalculatorService)
// ─────────────────────────────────────────────────────────────

/// Un punto de datos para la curva de ganancias acumuladas (estilo Bitcoin).
class DailyEarning {
  final int day;
  final double earned;      // ganancia ese día (0 si no hay cosecha)
  final double cumulative;  // ganancia acumulada hasta ese día
  final bool isHarvestDay;

  const DailyEarning({
    required this.day,
    required this.earned,
    required this.cumulative,
    required this.isHarvestDay,
  });
}

/// Resultado del simulador de pipeline de procesamiento.
class PipelineResult {
  final int totalCrops;          // cultivos cosechados en la estación
  final int totalProcessed;      // cuántos se alcanzaron a procesar
  final int daysToProcessAll;    // días totales hasta procesar todos
  final int recommendedEquipment; // equipos óptimos para no tener cuello de botella
  final bool hasBottleneck;
  final String bottleneckMessage;
  final double totalRevenue;     // ingreso bruto procesado
  final double seedCost;
  final double netProfit;
  /// Lotes para el diagrama de Gantt: {equipment, startDay, endDay, batch}
  final List<Map<String, dynamic>> batches;

  const PipelineResult({
    required this.totalCrops,
    required this.totalProcessed,
    required this.daysToProcessAll,
    required this.recommendedEquipment,
    required this.hasBottleneck,
    required this.bottleneckMessage,
    required this.totalRevenue,
    required this.seedCost,
    required this.netProfit,
    required this.batches,
  });
}

// ─────────────────────────────────────────────────────────────
//  ENTIDAD PURA — solo describe un cultivo
//  La lógica de cálculo vive en CropCalculatorService
// ─────────────────────────────────────────────────────────────

/// Representa un cultivo con sus atributos básicos.
///
/// Esta clase es una **entidad de dominio pura** — solo contiene datos.
/// Toda lógica de cálculo (crecimiento, cosechas, rentabilidad, pipeline)
/// se encuentra en [CropCalculatorService].
class CropModel {
  final String id;
  final String name;
  final String season; // Primavera | Verano | Otoño | Invierno | Invernadero
  final double seedCost;
  final double baseSellPrice;
  final int daysToGrow;
  final int regrowDays; // 0 = cosecha única
  final String sourceMod; // 'Vanilla' | 'Ridgeside Village' | etc.

  const CropModel({
    required this.id,
    required this.name,
    required this.season,
    required this.seedCost,
    required this.baseSellPrice,
    required this.daysToGrow,
    this.regrowDays = 0,
    this.sourceMod = 'Vanilla',
  });
}
