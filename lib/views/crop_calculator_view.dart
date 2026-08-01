import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/crop_model.dart';
import '../providers/app_state_provider.dart';
import '../theme/stardew_theme.dart';

class CropCalculatorView extends StatefulWidget {
  const CropCalculatorView({super.key});

  @override
  State<CropCalculatorView> createState() => _CropCalculatorViewState();
}

class _CropCalculatorViewState extends State<CropCalculatorView> {
  String selectedSeason = 'Primavera';
  Fertilizer selectedFertilizer = Fertilizer.none;
  ProcessingMethod selectedMethod = ProcessingMethod.keg;
  bool isAgriculturist = false;
  bool isTiller = false;
  bool isArtisan = true;
  int plantDay = 1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);
    final isMobile = MediaQuery.of(context).size.width < 700;

    final seasonCrops = provider.allCrops.where((c) {
      if (selectedSeason == 'Invernadero') return true;
      return c.season.toLowerCase() == selectedSeason.toLowerCase() || c.season == 'Invernadero';
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titulo de Calculadora
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calculadora de Rentabilidad', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: isMobile ? 18 : 22, color: StardewColors.primaryGold)),
              const SizedBox(height: 4),
              const Text('Optimiza tus cosechas, fertilizantes, barriles y conservas para maximizar ingresos.', style: TextStyle(color: StardewColors.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),

          // Filtros y Controles Adaptativos
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
              child: Column(
                children: [
                  Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    children: [
                      // Estación
                      Expanded(
                        flex: isMobile ? 0 : 1,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedSeason,
                          decoration: const InputDecoration(labelText: 'Estación de Siembra', border: OutlineInputBorder()),
                          items: ['Primavera', 'Verano', 'Otoño', 'Invernadero']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() => selectedSeason = v!),
                        ),
                      ),
                      SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 12 : 0),
                      // Fertilizante
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
                          onChanged: (v) => setState(() => selectedFertilizer = v!),
                        ),
                      ),
                      SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 12 : 0),
                      // Método de Procesamiento
                      Expanded(
                        flex: isMobile ? 0 : 1,
                        child: DropdownButtonFormField<ProcessingMethod>(
                          initialValue: selectedMethod,
                          decoration: const InputDecoration(labelText: 'Procesamiento', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: ProcessingMethod.raw, child: Text('Venta Directa')),
                            DropdownMenuItem(value: ProcessingMethod.jar, child: Text('Jarra de Conservas')),
                            DropdownMenuItem(value: ProcessingMethod.keg, child: Text('Barril (Vino)')),
                            DropdownMenuItem(value: ProcessingMethod.dehydrator, child: Text('Deshidratador')),
                          ],
                          onChanged: (v) => setState(() => selectedMethod = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Toggles de Profesión
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Agricultor (+10%)'),
                          selected: isAgriculturist,
                          onSelected: (v) => setState(() => isAgriculturist = v),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Labrador (+10%)'),
                          selected: isTiller,
                          onSelected: (v) => setState(() => isTiller = v),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Artesano (+40%)'),
                          selected: isArtisan,
                          onSelected: (v) => setState(() => isArtisan = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tabla de Cultivos y Rentabilidad
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ranking de Rentabilidad (${seasonCrops.length} cultivos)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: seasonCrops.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final crop = seasonCrops[index];
                      final effectiveDays = crop.getEffectiveGrowthDays(fertilizer: selectedFertilizer, isAgriculturist: isAgriculturist);
                      final totalHarvests = crop.totalHarvestsInSeason(plantDay: plantDay, fertilizer: selectedFertilizer, isAgriculturist: isAgriculturist);
                      final dailyProfit = crop.calculateDailyProfit(
                        plantDay: plantDay,
                        fertilizer: selectedFertilizer,
                        isAgriculturist: isAgriculturist,
                        isTiller: isTiller,
                        isArtisan: isArtisan,
                        method: selectedMethod,
                      );
                      final harvestDays = crop.getHarvestDays(plantDay: plantDay, fertilizer: selectedFertilizer, isAgriculturist: isAgriculturist);

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 12, vertical: 4),
                        leading: CircleAvatar(
                          radius: isMobile ? 16 : 20,
                          backgroundColor: StardewColors.cardBorder,
                          child: Text('${index + 1}', style: const TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        title: Text(crop.name, style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright, fontSize: isMobile ? 14 : 16)),
                        subtitle: Text(
                          '${effectiveDays}d (${totalHarvests} harvest)',
                          style: const TextStyle(color: StardewColors.textMuted, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${currencyFormatter.format(dailyProfit)}/d', style: TextStyle(color: StardewColors.emeraldGreen, fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16)),
                            IconButton(
                              icon: const Icon(Icons.calendar_month, color: StardewColors.primaryGold, size: 20),
                              onPressed: () {
                                for (var day in harvestDays) {
                                  provider.addTask(
                                    title: '🌾 Cosecha: ${crop.name}',
                                    season: selectedSeason,
                                    day: day,
                                    category: 'Cosecha',
                                  );
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('¡Se agendaron cosechas para ${crop.name}!'),
                                    backgroundColor: StardewColors.emeraldGreen,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
