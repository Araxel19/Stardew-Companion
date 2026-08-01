import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../application/crop_calculator_service.dart';
import '../../models/crop_model.dart';
import '../../theme/stardew_theme.dart';

/// Tab 2 del Simulador de Producción: Pipeline de procesamiento.
///
/// Muestra métricas de pipeline, detección de cuellos de botella y
/// el diagrama de Gantt de ocupación de equipos.
class PipelineTab extends StatelessWidget {
  final CropModel? selectedCrop;
  final int plantDay;
  final Fertilizer selectedFertilizer;
  final bool isAgriculturist;
  final bool isTiller;
  final bool isArtisan;
  final ProcessingMethod selectedMethod;
  final int cropQuantity;
  final int equipmentCount;
  final bool alreadyPlanted;
  final int daysUntilFirstHarvest;
  final String equipmentName;
  final ValueChanged<int> onEquipmentCountChanged;
  final VoidCallback onGoToCalculator;

  const PipelineTab({
    super.key,
    required this.selectedCrop,
    required this.plantDay,
    required this.selectedFertilizer,
    required this.isAgriculturist,
    required this.isTiller,
    required this.isArtisan,
    required this.selectedMethod,
    required this.cropQuantity,
    required this.equipmentCount,
    required this.alreadyPlanted,
    required this.daysUntilFirstHarvest,
    required this.equipmentName,
    required this.onEquipmentCountChanged,
    required this.onGoToCalculator,
  });

  @override
  Widget build(BuildContext context) {
    final crop = selectedCrop;
    final fmt = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);

    if (crop == null) {
      return const Center(
        child: Text('Selecciona un cultivo en la pestaña Calculadora.',
            style: TextStyle(color: StardewColors.textMuted)),
      );
    }

    if (selectedMethod == ProcessingMethod.raw) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: StardewColors.textMuted, size: 48),
              const SizedBox(height: 16),
              const Text(
                'El método "Venta Directa" no requiere equipos de procesamiento.\nCambia el procesamiento en la Calculadora.',
                style: TextStyle(color: StardewColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onGoToCalculator,
                child: const Text('Ir a Calculadora'),
              ),
            ],
          ),
        ),
      );
    }

    final result = CropCalculatorService.simulatePipeline(crop,
      plantDay: plantDay,
      fertilizer: selectedFertilizer,
      isAgriculturist: isAgriculturist,
      isTiller: isTiller,
      isArtisan: isArtisan,
      method: selectedMethod,
      cropQuantity: cropQuantity,
      equipmentCount: equipmentCount,
      alreadyPlanted: alreadyPlanted,
      daysUntilFirstHarvest: daysUntilFirstHarvest,
    );

    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Control de equipos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🛢️ Cantidad de $equipmentName',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$equipmentName: $equipmentCount',
                              style: const TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.w600),
                            ),
                            Slider(
                              value: equipmentCount.toDouble(),
                              min: 1,
                              max: 300,
                              divisions: 299,
                              activeColor: StardewColors.primaryGold,
                              onChanged: (v) => onEquipmentCountChanged(v.round()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: equipmentCount.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            if (parsed != null && parsed > 0 && parsed <= 500) {
                              onEquipmentCountChanged(parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (result.recommendedEquipment != equipmentCount)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => onEquipmentCountChanged(result.recommendedEquipment),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: StardewColors.oceanBlue.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: StardewColors.oceanBlue.withAlpha(80)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_fix_high, size: 14, color: StardewColors.oceanBlue),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Usar recomendado: ${result.recommendedEquipment} ${equipmentName.toLowerCase()}',
                                  style: const TextStyle(color: StardewColors.oceanBlue, fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Alerta de cuello de botella
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.hasBottleneck ? Colors.redAccent.withAlpha(25) : StardewColors.emeraldGreen.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: result.hasBottleneck ? Colors.redAccent.withAlpha(100) : StardewColors.emeraldGreen.withAlpha(100),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  result.hasBottleneck ? Icons.warning_rounded : Icons.check_circle,
                  color: result.hasBottleneck ? Colors.redAccent : StardewColors.emeraldGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.hasBottleneck ? '⚠️ Cuello de Botella Detectado' : '✅ Capacidad Suficiente',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: result.hasBottleneck ? Colors.redAccent : StardewColors.emeraldGreen,
                            fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(result.bottleneckMessage,
                          style: const TextStyle(color: StardewColors.textBright, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Métricas del pipeline
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 Métricas del Pipeline',
                      style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright, fontSize: 14)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: isMobile ? 2 : 3,
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _metric('🌾 Total Cosechado', '${result.totalCrops} und.', StardewColors.primaryGold),
                      _metric('🛢️ Procesados', '${result.totalProcessed}', StardewColors.emeraldGreen),
                      _metric('📅 Días Totales', '${result.daysToProcessAll}d',
                          result.hasBottleneck ? Colors.redAccent : StardewColors.oceanBlue),
                      _metric('🔧 Recomendados', '${result.recommendedEquipment}', StardewColors.iridiumPurple),
                      _metric('💵 Ingreso Bruto', fmt.format(result.totalRevenue), StardewColors.textBright),
                      _metric('✅ Ganancia Neta', fmt.format(result.netProfit),
                          result.netProfit >= 0 ? StardewColors.emeraldGreen : Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Diagrama de Gantt
          if (result.batches.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📅 Diagrama de Ocupación (primeros 10 equipos)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright, fontSize: 14)),
                    const Text('Verde = procesando. Vacío = equipo libre.',
                        style: TextStyle(color: StardewColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 16),
                    _GanttChart(batches: result.batches, equipmentCount: equipmentCount),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: StardewColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: StardewColors.textMuted)),
          Text(value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Diagrama de Gantt de ocupación de equipos.
class _GanttChart extends StatelessWidget {
  final List<Map<String, dynamic>> batches;
  final int equipmentCount;

  const _GanttChart({required this.batches, required this.equipmentCount});

  @override
  Widget build(BuildContext context) {
    const int maxRows = 10;
    final rowCount = equipmentCount.clamp(1, maxRows);
    const double rowH = 28.0;
    const double totalDays = 28.0;

    final colors = [
      StardewColors.emeraldGreen,
      StardewColors.oceanBlue,
      StardewColors.iridiumPurple,
      StardewColors.primaryGold,
      const Color(0xFFE67E22),
      const Color(0xFF1ABC9C),
      const Color(0xFFE74C3C),
      const Color(0xFF9B59B6),
      const Color(0xFF3498DB),
      const Color(0xFF2ECC71),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 64),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(8, (i) {
                  final day = i * 4 + 1;
                  return Text('D$day', style: const TextStyle(color: StardewColors.textMuted, fontSize: 9));
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...List.generate(rowCount, (eqIdx) {
          final eqBatches = batches.where((b) => b['equipment'] == eqIdx).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text('Eq. ${eqIdx + 1}',
                      style: const TextStyle(color: StardewColors.textMuted, fontSize: 10),
                      overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      final w = constraints.maxWidth;
                      return Container(
                        height: rowH,
                        decoration: BoxDecoration(
                          color: StardewColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: StardewColors.cardBorder),
                        ),
                        child: Stack(
                          children: eqBatches.map((b) {
                            final start = ((b['startDay'] as int) - 1).clamp(0, 27);
                            final end = (b['endDay'] as int).clamp(1, 50);
                            final left = (start / totalDays) * w;
                            final barW = ((end - start).clamp(0, 28) / totalDays) * w;
                            return Positioned(
                              left: left.clamp(0.0, w - 4),
                              top: 3,
                              child: Container(
                                width: barW.clamp(4.0, w),
                                height: rowH - 6,
                                decoration: BoxDecoration(
                                  color: colors[eqIdx % colors.length].withAlpha(180),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        if (equipmentCount > maxRows)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('... y ${equipmentCount - maxRows} equipos más.',
                style: const TextStyle(color: StardewColors.textMuted, fontSize: 10)),
          ),
      ],
    );
  }
}
