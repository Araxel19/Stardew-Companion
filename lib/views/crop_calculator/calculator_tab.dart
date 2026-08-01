import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../application/crop_calculator_service.dart';
import '../../models/crop_model.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/planted_crop_provider.dart';
import '../../theme/stardew_theme.dart';
import '../../widgets/stardew_avatars.dart';
import 'planted_crops_tab.dart';

/// Tab 1 del Simulador: panel de controles + gráfica de rentabilidad + ranking.
class CalculatorTab extends StatelessWidget {
  final List<CropModel> seasonCrops;
  final CropModel? selectedCrop;
  final String selectedSeason;
  final Fertilizer selectedFertilizer;
  final ProcessingMethod selectedMethod;
  final bool isAgriculturist;
  final bool isTiller;
  final bool isArtisan;
  final int plantDay;
  final int cropQuantity;
  final bool alreadyPlanted;
  final int daysUntilFirstHarvest;
  final String processingLabel;
  final AppStateProvider provider;
  final ValueChanged<CropModel> onCropSelected;
  final ValueChanged<String> onSeasonChanged;
  final ValueChanged<Fertilizer> onFertilizerChanged;
  final ValueChanged<ProcessingMethod> onMethodChanged;
  final ValueChanged<bool> onAgriculturistChanged;
  final ValueChanged<bool> onTillerChanged;
  final ValueChanged<bool> onArtisanChanged;
  final ValueChanged<int> onPlantDayChanged;
  final ValueChanged<int> onCropQuantityChanged;
  final ValueChanged<bool> onAlreadyPlantedChanged;
  final ValueChanged<int> onDaysUntilFirstHarvestChanged;

  const CalculatorTab({
    super.key,
    required this.seasonCrops,
    required this.selectedCrop,
    required this.selectedSeason,
    required this.selectedFertilizer,
    required this.selectedMethod,
    required this.isAgriculturist,
    required this.isTiller,
    required this.isArtisan,
    required this.plantDay,
    required this.cropQuantity,
    required this.alreadyPlanted,
    required this.daysUntilFirstHarvest,
    required this.processingLabel,
    required this.provider,
    required this.onCropSelected,
    required this.onSeasonChanged,
    required this.onFertilizerChanged,
    required this.onMethodChanged,
    required this.onAgriculturistChanged,
    required this.onTillerChanged,
    required this.onArtisanChanged,
    required this.onPlantDayChanged,
    required this.onCropQuantityChanged,
    required this.onAlreadyPlantedChanged,
    required this.onDaysUntilFirstHarvestChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);
    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ControlsCard(
            selectedSeason: selectedSeason,
            selectedFertilizer: selectedFertilizer,
            selectedMethod: selectedMethod,
            isAgriculturist: isAgriculturist,
            isTiller: isTiller,
            isArtisan: isArtisan,
            plantDay: plantDay,
            cropQuantity: cropQuantity,
            alreadyPlanted: alreadyPlanted,
            daysUntilFirstHarvest: daysUntilFirstHarvest,
            isMobile: isMobile,
            onSeasonChanged: onSeasonChanged,
            onFertilizerChanged: onFertilizerChanged,
            onMethodChanged: onMethodChanged,
            onAgriculturistChanged: onAgriculturistChanged,
            onTillerChanged: onTillerChanged,
            onArtisanChanged: onArtisanChanged,
            onPlantDayChanged: onPlantDayChanged,
            onCropQuantityChanged: onCropQuantityChanged,
            onAlreadyPlantedChanged: onAlreadyPlantedChanged,
            onDaysUntilFirstHarvestChanged: onDaysUntilFirstHarvestChanged,
          ),
          const SizedBox(height: 16),

          if (selectedCrop != null) ...[
            _BitcoinChart(
              crop: selectedCrop!,
              plantDay: plantDay,
              selectedFertilizer: selectedFertilizer,
              isAgriculturist: isAgriculturist,
              isTiller: isTiller,
              isArtisan: isArtisan,
              selectedMethod: selectedMethod,
              cropQuantity: cropQuantity,
              alreadyPlanted: alreadyPlanted,
              daysUntilFirstHarvest: daysUntilFirstHarvest,
              selectedSeason: selectedSeason,
              processingLabel: processingLabel,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _InvestmentSummary(
              crop: selectedCrop!,
              plantDay: plantDay,
              selectedFertilizer: selectedFertilizer,
              isAgriculturist: isAgriculturist,
              isTiller: isTiller,
              isArtisan: isArtisan,
              selectedMethod: selectedMethod,
              cropQuantity: cropQuantity,
              alreadyPlanted: alreadyPlanted,
              daysUntilFirstHarvest: daysUntilFirstHarvest,
              fmt: fmt,
            ),
            const SizedBox(height: 16),
          ],

          _RankingCard(
            context: context,
            seasonCrops: seasonCrops,
            selectedCrop: selectedCrop,
            plantDay: plantDay,
            selectedFertilizer: selectedFertilizer,
            isAgriculturist: isAgriculturist,
            isTiller: isTiller,
            isArtisan: isArtisan,
            selectedMethod: selectedMethod,
            cropQuantity: cropQuantity,
            alreadyPlanted: alreadyPlanted,
            daysUntilFirstHarvest: daysUntilFirstHarvest,
            selectedSeason: selectedSeason,
            provider: provider,
            fmt: fmt,
            isMobile: isMobile,
            onCropSelected: onCropSelected,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  PANEL DE CONTROLES
// ──────────────────────────────────────────────────────────────────────────────

class _ControlsCard extends StatelessWidget {
  final String selectedSeason;
  final Fertilizer selectedFertilizer;
  final ProcessingMethod selectedMethod;
  final bool isAgriculturist;
  final bool isTiller;
  final bool isArtisan;
  final int plantDay;
  final int cropQuantity;
  final bool alreadyPlanted;
  final int daysUntilFirstHarvest;
  final bool isMobile;
  final ValueChanged<String> onSeasonChanged;
  final ValueChanged<Fertilizer> onFertilizerChanged;
  final ValueChanged<ProcessingMethod> onMethodChanged;
  final ValueChanged<bool> onAgriculturistChanged;
  final ValueChanged<bool> onTillerChanged;
  final ValueChanged<bool> onArtisanChanged;
  final ValueChanged<int> onPlantDayChanged;
  final ValueChanged<int> onCropQuantityChanged;
  final ValueChanged<bool> onAlreadyPlantedChanged;
  final ValueChanged<int> onDaysUntilFirstHarvestChanged;

  const _ControlsCard({
    required this.selectedSeason, required this.selectedFertilizer,
    required this.selectedMethod, required this.isAgriculturist,
    required this.isTiller, required this.isArtisan, required this.plantDay,
    required this.cropQuantity, required this.alreadyPlanted,
    required this.daysUntilFirstHarvest, required this.isMobile,
    required this.onSeasonChanged, required this.onFertilizerChanged,
    required this.onMethodChanged, required this.onAgriculturistChanged,
    required this.onTillerChanged, required this.onArtisanChanged,
    required this.onPlantDayChanged, required this.onCropQuantityChanged,
    required this.onAlreadyPlantedChanged, required this.onDaysUntilFirstHarvestChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚙️ Configuración de Simulación',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
            const SizedBox(height: 14),

            // Fila 1: Estación + Fertilizante + Método
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSeason,
                    decoration: const InputDecoration(labelText: 'Estación', border: OutlineInputBorder()),
                    items: ['Primavera', 'Verano', 'Otoño', 'Invierno', 'Invernadero']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => onSeasonChanged(v!),
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 10, height: isMobile ? 10 : 0),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: DropdownButtonFormField<Fertilizer>(
                    initialValue: selectedFertilizer,
                    decoration: const InputDecoration(labelText: 'Fertilizante', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: Fertilizer.none, child: Text('Sin Fertilizante')),
                      DropdownMenuItem(value: Fertilizer.basicSpeedGro, child: Text('Speed-Gro (10%)')),
                      DropdownMenuItem(value: Fertilizer.deluxeSpeedGro, child: Text('Deluxe Speed-Gro (15%)')),
                      DropdownMenuItem(value: Fertilizer.hyperSpeedGro, child: Text('Hyper Speed-Gro (25%)')),
                    ],
                    onChanged: (v) => onFertilizerChanged(v!),
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 10, height: isMobile ? 10 : 0),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: DropdownButtonFormField<ProcessingMethod>(
                    initialValue: selectedMethod,
                    decoration: const InputDecoration(labelText: 'Procesamiento', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: ProcessingMethod.raw, child: Text('Venta Directa')),
                      DropdownMenuItem(value: ProcessingMethod.jar, child: Text('Jarra de Conservas')),
                      DropdownMenuItem(value: ProcessingMethod.keg, child: Text('Barril (Vino/Jugo)')),
                      DropdownMenuItem(value: ProcessingMethod.dehydrator, child: Text('Deshidratadora')),
                    ],
                    onChanged: (v) => onMethodChanged(v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Fila 2: Cantidad + Día de siembra
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.grid_on, size: 14, color: StardewColors.primaryGold),
                        const SizedBox(width: 4),
                        Text('Parcelas: $cropQuantity',
                            style: const TextStyle(color: StardewColors.textBright, fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
                      Slider(
                        value: cropQuantity.toDouble(), min: 1, max: 500, divisions: 499,
                        activeColor: StardewColors.primaryGold,
                        onChanged: (v) => onCropQuantityChanged(v.round()),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 8 : 0),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.calendar_today, size: 14, color: StardewColors.primaryGold),
                        const SizedBox(width: 4),
                        Text('Día de siembra: $plantDay',
                            style: const TextStyle(color: StardewColors.textBright, fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
                      Slider(
                        value: plantDay.toDouble(), min: 1, max: 26, divisions: 25,
                        activeColor: StardewColors.oceanBlue,
                        onChanged: (v) => onPlantDayChanged(v.round()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Toggle "Ya plantado"
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: alreadyPlanted ? StardewColors.emeraldGreen.withAlpha(30) : StardewColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: alreadyPlanted ? StardewColors.emeraldGreen.withAlpha(80) : StardewColors.cardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: alreadyPlanted,
                        activeThumbColor: StardewColors.emeraldGreen,
                        onChanged: onAlreadyPlantedChanged,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.eco, color: StardewColors.emeraldGreen, size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text('Ya está plantado — omitir tiempo de crecimiento',
                            style: TextStyle(color: StardewColors.textBright, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                  if (alreadyPlanted) ...[
                    const SizedBox(height: 10),
                    Text('Días restantes para primera cosecha: $daysUntilFirstHarvest',
                        style: const TextStyle(color: StardewColors.textBright, fontSize: 13)),
                    Slider(
                      value: daysUntilFirstHarvest.toDouble(), min: 1, max: 27, divisions: 26,
                      activeColor: StardewColors.emeraldGreen,
                      onChanged: (v) => onDaysUntilFirstHarvestChanged(v.round()),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Profesiones
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Agricultor (+10%)'),
                    selected: isAgriculturist,
                    onSelected: onAgriculturistChanged,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Labrador (+10%)'),
                    selected: isTiller,
                    onSelected: onTillerChanged,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Artesano (+40%)'),
                    selected: isArtisan,
                    onSelected: onArtisanChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  GRÁFICA ESTILO BITCOIN
// ──────────────────────────────────────────────────────────────────────────────

class _BitcoinChart extends StatelessWidget {
  final CropModel crop;
  final int plantDay;
  final Fertilizer selectedFertilizer;
  final bool isAgriculturist;
  final bool isTiller;
  final bool isArtisan;
  final ProcessingMethod selectedMethod;
  final int cropQuantity;
  final bool alreadyPlanted;
  final int daysUntilFirstHarvest;
  final String selectedSeason;
  final String processingLabel;
  final bool isMobile;

  const _BitcoinChart({
    required this.crop, required this.plantDay, required this.selectedFertilizer,
    required this.isAgriculturist, required this.isTiller, required this.isArtisan,
    required this.selectedMethod, required this.cropQuantity, required this.alreadyPlanted,
    required this.daysUntilFirstHarvest, required this.selectedSeason,
    required this.processingLabel, required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CropCalculatorService.getDailyEarningsCurve(crop,
      plantDay: plantDay, fertilizer: selectedFertilizer,
      isAgriculturist: isAgriculturist, isTiller: isTiller, isArtisan: isArtisan,
      method: selectedMethod, cropQuantity: cropQuantity,
      alreadyPlanted: alreadyPlanted, daysUntilFirstHarvest: daysUntilFirstHarvest,
    );

    if (curve.isEmpty) return const SizedBox.shrink();

    final maxY = curve.map((e) => e.cumulative).reduce((a, b) => a > b ? a : b);
    final minY = curve.map((e) => e.cumulative).reduce((a, b) => a < b ? a : b);
    final fmt = NumberFormat.compactCurrency(symbol: 'g ', decimalDigits: 0);
    final spots = curve.map((e) => FlSpot(e.day.toDouble(), e.cumulative)).toList();
    final harvestDays = curve.where((e) => e.isHarvestDay).map((e) => e.day).toSet();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: StardewColors.oceanBlue.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: StardewColors.oceanBlue.withAlpha(70)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lightbulb_outline, color: StardewColors.oceanBlue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔮 Simulación Teórica de Planificación: Esta gráfica proyecta la ganancia si sembraras este cultivo. No son parcelas plantadas aún en tu granja.',
                      style: TextStyle(fontSize: 11, color: StardewColors.textBright),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.show_chart, color: StardewColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Simulación Teórica — ${crop.name} ($cropQuantity parcelas simuladas · $processingLabel)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: StardewColors.textBright),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Estación: $selectedSeason • Puntos dorados 🌕 = días simulados de cosecha',
                style: const TextStyle(color: StardewColors.textMuted, fontSize: 11)),
            const SizedBox(height: 20),
            SizedBox(
              height: isMobile ? 180 : 240,
              child: LineChart(
                LineChartData(
                  minX: 1, maxX: 28,
                  minY: minY < 0 ? minY * 1.15 : minY * 0.85,
                  maxY: maxY * 1.15,
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => FlLine(color: StardewColors.cardBorder.withAlpha(80), strokeWidth: 0.5),
                    getDrawingVerticalLine: (_) => FlLine(color: StardewColors.cardBorder.withAlpha(40), strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 0,
                        color: Colors.redAccent.withAlpha(160),
                        strokeWidth: 1.5,
                        dashArray: [6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => 'Break-even',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => StardewColors.cardBackground.withAlpha(230),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final day = spot.x.toInt();
                          final pt = curve.firstWhere(
                            (e) => e.day == day,
                            orElse: () => DailyEarning(day: day, earned: 0, cumulative: 0, isHarvestDay: false),
                          );
                          return LineTooltipItem(
                            'Día $day${pt.isHarvestDay ? ' 🌾' : ''}\n'
                            '${pt.isHarvestDay ? '+${fmt.format(pt.earned)}\n' : ''}'
                            'Acumulado: ${fmt.format(pt.cumulative)}',
                            TextStyle(color: spot.bar.color ?? StardewColors.emeraldGreen, fontSize: 11),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, reservedSize: 60,
                        getTitlesWidget: (v, _) => Text(fmt.format(v),
                            style: const TextStyle(color: StardewColors.textMuted, fontSize: 9)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, interval: 7,
                        getTitlesWidget: (v, _) => Text('D${v.toInt()}',
                            style: const TextStyle(color: StardewColors.textMuted, fontSize: 9)),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      isStepLineChart: true,
                      color: StardewColors.emeraldGreen,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) {
                          final day = spot.x.toInt();
                          if (harvestDays.contains(day)) {
                            return FlDotCirclePainter(radius: 5, color: StardewColors.primaryGold,
                                strokeColor: Colors.white, strokeWidth: 1.5);
                          }
                          return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [StardewColors.emeraldGreen.withAlpha(80), StardewColors.primaryGold.withAlpha(20)],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(StardewColors.primaryGold, '● Cosecha'),
                const SizedBox(width: 16),
                _legend(Colors.redAccent, '─ Break-even'),
                const SizedBox(width: 16),
                _legend(StardewColors.emeraldGreen, '━ Acumulado'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  RESUMEN DE INVERSIÓN / ROI
// ──────────────────────────────────────────────────────────────────────────────

class _InvestmentSummary extends StatelessWidget {
  final CropModel crop;
  final int plantDay;
  final Fertilizer selectedFertilizer;
  final bool isAgriculturist;
  final bool isTiller;
  final bool isArtisan;
  final ProcessingMethod selectedMethod;
  final int cropQuantity;
  final bool alreadyPlanted;
  final int daysUntilFirstHarvest;
  final NumberFormat fmt;

  const _InvestmentSummary({
    required this.crop, required this.plantDay, required this.selectedFertilizer,
    required this.isAgriculturist, required this.isTiller, required this.isArtisan,
    required this.selectedMethod, required this.cropQuantity, required this.alreadyPlanted,
    required this.daysUntilFirstHarvest, required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final harvests = CropCalculatorService.totalHarvestsInSeason(crop,
      plantDay: plantDay, fertilizer: selectedFertilizer, isAgriculturist: isAgriculturist,
      alreadyPlanted: alreadyPlanted, daysUntilFirstHarvest: daysUntilFirstHarvest,
    );
    final itemPrice = CropCalculatorService.getSellPrice(crop,
        method: selectedMethod, isTiller: isTiller, isArtisan: isArtisan);
    final seedTimes = crop.regrowDays > 0 ? 1 : harvests;
    final seedCost = alreadyPlanted ? 0.0 : crop.seedCost * seedTimes * cropQuantity;
    final grossRevenue = itemPrice * harvests * cropQuantity;
    final netProfit = grossRevenue - seedCost;
    final roi = seedCost > 0 ? (netProfit / seedCost) * 100 : 0.0;

    final curve = CropCalculatorService.getDailyEarningsCurve(crop,
      plantDay: plantDay, fertilizer: selectedFertilizer,
      isAgriculturist: isAgriculturist, isTiller: isTiller, isArtisan: isArtisan,
      method: selectedMethod, cropQuantity: cropQuantity,
      alreadyPlanted: alreadyPlanted, daysUntilFirstHarvest: daysUntilFirstHarvest,
    );
    final breakEvenPoint = curve.where((e) => e.cumulative >= 0);
    final breakEvenDay = breakEvenPoint.isNotEmpty ? breakEvenPoint.first.day : -1;

    return Card(
      color: StardewColors.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: StardewColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Text('Resumen de Inversión — ${crop.name}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _statBox('💰 Inversión', fmt.format(seedCost), StardewColors.primaryGold),
                _statBox('🌾 Cosechas', '$harvests × $cropQuantity', StardewColors.oceanBlue),
                _statBox('📦 Ingreso Bruto', fmt.format(grossRevenue), StardewColors.textBright),
                _statBox('✅ Ganancia Neta', fmt.format(netProfit),
                    netProfit >= 0 ? StardewColors.emeraldGreen : Colors.redAccent),
                _statBox('📈 ROI', '${roi.toStringAsFixed(0)}%', StardewColors.iridiumPurple),
                _statBox('⏱️ Break-even',
                    breakEvenDay > 0 ? 'Día $breakEvenDay' : 'Sin ganancia',
                    breakEvenDay > 0 ? StardewColors.emeraldGreen : Colors.redAccent),
              ],
            ),
            Builder(
              builder: (ctx) {
                final plantedProvider = Provider.of<PlantedCropProvider>(ctx);
                final cropBatches = plantedProvider.batches.where((b) => b.cropName.toLowerCase() == crop.name.toLowerCase()).toList();
                final totalPlanted = cropBatches.fold<int>(0, (sum, b) => sum + b.quantity);

                if (totalPlanted == 0) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StardewColors.emeraldGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: StardewColors.emeraldGreen.withAlpha(90)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.grass, color: StardewColors.emeraldGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '🌱 Tienes $totalPlanted parcelas de ${crop.name} plantadas activas en tu granja.\n'
                          'Puedes gestionarlas o eliminarlas en la pestaña 4 "Mis Parcelas".',
                          style: const TextStyle(fontSize: 12, color: StardewColors.emeraldGreen, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: StardewColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: StardewColors.textMuted)),
          Text(value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  RANKING DE CULTIVOS
// ──────────────────────────────────────────────────────────────────────────────

class _RankingCard extends StatefulWidget {
  final BuildContext context;
  final List<CropModel> seasonCrops;
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
  final String selectedSeason;
  final AppStateProvider provider;
  final NumberFormat fmt;
  final bool isMobile;
  final ValueChanged<CropModel> onCropSelected;

  const _RankingCard({
    required this.context, required this.seasonCrops, required this.selectedCrop,
    required this.plantDay, required this.selectedFertilizer, required this.isAgriculturist,
    required this.isTiller, required this.isArtisan, required this.selectedMethod,
    required this.cropQuantity, required this.alreadyPlanted, required this.daysUntilFirstHarvest,
    required this.selectedSeason, required this.provider, required this.fmt,
    required this.isMobile, required this.onCropSelected,
  });

  @override
  State<_RankingCard> createState() => _RankingCardState();
}

class _RankingCardState extends State<_RankingCard> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final filteredCrops = widget.seasonCrops.where((c) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) || c.sourceMod.toLowerCase().contains(query);
    }).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: StardewColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Ranking de Rentabilidad (${filteredCrops.length} / ${widget.seasonCrops.length} cultivos)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Campo de Búsqueda
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              style: const TextStyle(color: StardewColors.textBright, fontSize: 13),
              decoration: InputDecoration(
                hintText: '🔍 Buscar cultivo o mod...',
                hintStyle: const TextStyle(color: StardewColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: StardewColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredCrops.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx2, index) {
                final crop = filteredCrops[index];
                final isSelected = widget.selectedCrop?.id == crop.id;
                final effectiveDays = CropCalculatorService.getEffectiveGrowthDays(crop,
                  fertilizer: widget.selectedFertilizer, isAgriculturist: widget.isAgriculturist,
                );
                final totalHarvests = CropCalculatorService.totalHarvestsInSeason(crop,
                  plantDay: widget.plantDay, fertilizer: widget.selectedFertilizer, isAgriculturist: widget.isAgriculturist,
                  alreadyPlanted: widget.alreadyPlanted, daysUntilFirstHarvest: widget.daysUntilFirstHarvest,
                );
                final dailyProfit = CropCalculatorService.calculateDailyProfit(crop,
                  plantDay: widget.plantDay, fertilizer: widget.selectedFertilizer, isAgriculturist: widget.isAgriculturist,
                  isTiller: widget.isTiller, isArtisan: widget.isArtisan, method: widget.selectedMethod,
                  cropQuantity: widget.cropQuantity, alreadyPlanted: widget.alreadyPlanted,
                  daysUntilFirstHarvest: widget.daysUntilFirstHarvest,
                );

                final medalColor = index == 0
                    ? const Color(0xFFFFD700)
                    : index == 1
                        ? const Color(0xFFC0C0C0)
                        : index == 2 ? const Color(0xFFCD7F32) : null;

                final plantedProvider = Provider.of<PlantedCropProvider>(ctx2);
                final plantedBatches = plantedProvider.batches.where((b) => b.cropName.toLowerCase() == crop.name.toLowerCase()).toList();
                final totalPlantedPlots = plantedBatches.fold<int>(0, (sum, b) => sum + b.quantity);

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? StardewColors.primaryGold.withAlpha(25) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: StardewColors.primaryGold.withAlpha(80), width: 1)
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        onTap: () {
                          widget.onCropSelected(crop);
                          _showCropDetailsModal(ctx2, crop);
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 6 : 12, vertical: 4),
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CropAvatar(
                            name: crop.name, season: crop.season,
                            isModded: crop.sourceMod != 'Vanilla',
                            size: widget.isMobile ? 36 : 44,
                          ),
                          if (medalColor != null)
                            Positioned(
                              top: -4, right: -4,
                              child: Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle),
                                child: Center(
                                  child: Text('${index + 1}',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(crop.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? StardewColors.primaryGold : StardewColors.textBright,
                                    fontSize: widget.isMobile ? 13 : 15),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (totalPlantedPlots > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: StardewColors.emeraldGreen.withAlpha(40),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: StardewColors.emeraldGreen),
                              ),
                              child: Text(
                                '🌱 $totalPlantedPlots plantadas',
                                style: const TextStyle(fontSize: 10, color: StardewColors.emeraldGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '${effectiveDays}d de crecimiento • $totalHarvests cosecha(s) • ${crop.sourceMod}',
                        style: const TextStyle(color: StardewColors.textMuted, fontSize: 11),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.fmt.format(dailyProfit),
                                style: TextStyle(
                                    color: dailyProfit >= 0 ? StardewColors.emeraldGreen : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: widget.isMobile ? 13 : 15),
                              ),
                              const Text('/día', style: TextStyle(color: StardewColors.textMuted, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 4),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: IconButton(
                              icon: const Icon(Icons.add_task, color: StardewColors.emeraldGreen, size: 22),
                              tooltip: 'Plantar / Registrar Lote en Mis Parcelas',
                              onPressed: () {
                                final plantedProvider = Provider.of<PlantedCropProvider>(ctx2, listen: false);
                                PlantedCropsTab.showBatchFormModal(
                                  ctx2,
                                  allCrops: widget.provider.allCrops,
                                  plantedProvider: plantedProvider,
                                  initialCropName: crop.name,
                                  initialQuantity: widget.cropQuantity,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            ),
          ],
        ),
      ),
    );
  }

  void _showCropDetailsModal(BuildContext ctx, CropModel crop) {
    final fmt2 = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);
    final rawProfit = CropCalculatorService.calculateDailyProfit(crop,
        fertilizer: widget.selectedFertilizer, isAgriculturist: widget.isAgriculturist,
        isTiller: widget.isTiller, isArtisan: widget.isArtisan, method: ProcessingMethod.raw,
        cropQuantity: widget.cropQuantity, alreadyPlanted: widget.alreadyPlanted,
        daysUntilFirstHarvest: widget.daysUntilFirstHarvest);
    final jarProfit = CropCalculatorService.calculateDailyProfit(crop,
        fertilizer: widget.selectedFertilizer, isAgriculturist: widget.isAgriculturist,
        isTiller: widget.isTiller, isArtisan: widget.isArtisan, method: ProcessingMethod.jar,
        cropQuantity: widget.cropQuantity, alreadyPlanted: widget.alreadyPlanted,
        daysUntilFirstHarvest: widget.daysUntilFirstHarvest);
    final kegProfit = CropCalculatorService.calculateDailyProfit(crop,
        fertilizer: widget.selectedFertilizer, isAgriculturist: widget.isAgriculturist,
        isTiller: widget.isTiller, isArtisan: widget.isArtisan, method: ProcessingMethod.keg,
        cropQuantity: widget.cropQuantity, alreadyPlanted: widget.alreadyPlanted,
        daysUntilFirstHarvest: widget.daysUntilFirstHarvest);

    showModalBottomSheet(
      context: ctx,
      backgroundColor: StardewColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (bCtx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: StardewColors.cardBorder, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CropAvatar(name: crop.name, season: crop.season, isModded: crop.sourceMod != 'Vanilla', size: 64),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(crop.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: StardewColors.primaryGold)),
                        Text('${crop.season} • ${crop.sourceMod}', style: const TextStyle(color: StardewColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              GridView.count(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                shrinkWrap: true, childAspectRatio: 2.8,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _modalTile('🌱 Costo Semilla', fmt2.format(crop.seedCost), StardewColors.primaryGold),
                  _modalTile('💰 Venta Base', fmt2.format(crop.baseSellPrice), StardewColors.emeraldGreen),
                  _modalTile('⏱️ Crecimiento', '${crop.daysToGrow} días', StardewColors.oceanBlue),
                  _modalTile('🔄 Re-cosecha', crop.regrowDays > 0 ? '${crop.regrowDays} días' : 'Única vez', StardewColors.iridiumPurple),
                ],
              ),
              const SizedBox(height: 16),
              const Text('📈 Ganancia Diaria por Método:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
              const SizedBox(height: 8),
              _profitRow('Venta Directa', rawProfit, fmt2),
              const Divider(height: 12),
              _profitRow('Jarra de Conservas', jarProfit, fmt2),
              const Divider(height: 12),
              _profitRow('Barril (Vino/Jugo)', kegProfit, fmt2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(bCtx);
                    final plantedProvider = Provider.of<PlantedCropProvider>(ctx, listen: false);
                    PlantedCropsTab.showBatchFormModal(
                      ctx,
                      allCrops: widget.provider.allCrops,
                      plantedProvider: plantedProvider,
                      initialCropName: crop.name,
                      initialQuantity: widget.cropQuantity,
                    );
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('🌱 Plantar / Registrar Lote en Mis Parcelas'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: StardewColors.emeraldGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: StardewColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StardewColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: StardewColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _profitRow(String label, double profit, NumberFormat fmt3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: StardewColors.textBright)),
        Text('${fmt3.format(profit)}/d',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                color: profit >= 0 ? StardewColors.emeraldGreen : Colors.redAccent)),
      ],
    );
  }
}
