import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../application/crop_calculator_service.dart';
import '../../models/crop_model.dart';
import '../../theme/stardew_theme.dart';

/// Tab 3 del Simulador: tabla de flujo de caja día a día.
class DayByDayTab extends StatelessWidget {
  final CropModel? selectedCrop;
  final int plantDay;
  final Fertilizer selectedFertilizer;
  final bool isAgriculturist;
  final bool isTiller;
  final bool isArtisan;
  final ProcessingMethod selectedMethod;
  final int cropQuantity;
  final bool alreadyPlanted;
  final int daysUntilFirstHarvest;

  const DayByDayTab({
    super.key,
    required this.selectedCrop,
    required this.plantDay,
    required this.selectedFertilizer,
    required this.isAgriculturist,
    required this.isTiller,
    required this.isArtisan,
    required this.selectedMethod,
    required this.cropQuantity,
    required this.alreadyPlanted,
    required this.daysUntilFirstHarvest,
  });

  @override
  Widget build(BuildContext context) {
    final crop = selectedCrop;
    if (crop == null) {
      return const Center(
        child: Text('Selecciona un cultivo en la pestaña Calculadora.',
            style: TextStyle(color: StardewColors.textMuted)),
      );
    }

    final fmt = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);
    final curve = CropCalculatorService.getDailyEarningsCurve(crop,
      plantDay: plantDay,
      fertilizer: selectedFertilizer,
      isAgriculturist: isAgriculturist,
      isTiller: isTiller,
      isArtisan: isArtisan,
      method: selectedMethod,
      cropQuantity: cropQuantity,
      alreadyPlanted: alreadyPlanted,
      daysUntilFirstHarvest: daysUntilFirstHarvest,
    );

    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.table_chart, color: StardewColors.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Flujo de Caja — ${crop.name} · $cropQuantity parcelas',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: StardewColors.textBright),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cabecera de tabla
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: StardewColors.primaryGold.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 50, child: Text('Día', style: TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(child: Text('Evento', style: TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12))),
                    SizedBox(width: 85, child: Text('Ingreso', style: TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
                    SizedBox(width: 95, child: Text('Acumulado', style: TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
                  ],
                ),
              ),

              // Filas
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: curve.length,
                itemBuilder: (_, index) {
                  final point = curve[index];
                  final isHarvest = point.isHarvestDay;
                  final isBreakEven =
                      point.cumulative >= 0 && (index == 0 || curve[index - 1].cumulative < 0);
                  final isPlantDay = point.day == plantDay && !alreadyPlanted;

                  return Container(
                    decoration: BoxDecoration(
                      color: isHarvest
                          ? StardewColors.primaryGold.withAlpha(20)
                          : isBreakEven
                              ? StardewColors.emeraldGreen.withAlpha(15)
                              : index % 2 == 0
                                  ? Colors.transparent
                                  : StardewColors.background.withAlpha(80),
                      border: isBreakEven
                          ? Border(bottom: BorderSide(color: StardewColors.emeraldGreen.withAlpha(120), width: 1))
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text('Día ${point.day}',
                                style: TextStyle(
                                    color: isHarvest ? StardewColors.primaryGold : StardewColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: isHarvest ? FontWeight.bold : FontWeight.normal)),
                          ),
                          Expanded(
                            child: Text(
                              isHarvest
                                  ? '🌾 Cosecha'
                                  : isPlantDay
                                      ? '🌱 Siembra'
                                      : isBreakEven
                                          ? '✅ Break-even'
                                          : '—',
                              style: TextStyle(
                                  color: isHarvest
                                      ? StardewColors.primaryGold
                                      : isBreakEven
                                          ? StardewColors.emeraldGreen
                                          : StardewColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: isHarvest || isBreakEven ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                          SizedBox(
                            width: 85,
                            child: Text(
                              point.earned > 0 ? '+${fmt.format(point.earned)}' : '—',
                              style: TextStyle(
                                  color: point.earned > 0 ? StardewColors.emeraldGreen : StardewColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: point.earned > 0 ? FontWeight.bold : FontWeight.normal),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(
                            width: 95,
                            child: Text(
                              fmt.format(point.cumulative),
                              style: TextStyle(
                                  color: point.cumulative >= 0 ? StardewColors.emeraldGreen : Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
