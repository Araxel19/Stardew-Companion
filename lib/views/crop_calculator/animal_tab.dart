import 'package:flutter/material.dart';
import '../../application/animal_calculator_service.dart';
import '../../theme/stardew_theme.dart';

/// Pestaña de Simulación y Rentabilidad de Ganadería.
class AnimalTab extends StatefulWidget {
  const AnimalTab({super.key});

  @override
  State<AnimalTab> createState() => _AnimalTabState();
}

class _AnimalTabState extends State<AnimalTab> {
  int _animalCount = 12;
  bool _isRancher = false;
  bool _isArtisan = true;
  bool _processProducts = true;

  @override
  Widget build(BuildContext context) {
    final animals = AnimalCalculatorService.defaultAnimals;

    // Calcular ganancias y ordenar
    final profits = animals.map((a) {
      final profit = AnimalCalculatorService.calculateDailyProfit(
        animal: a,
        count: _animalCount,
        isRancher: _isRancher,
        isArtisan: _isArtisan,
        isGatherer: false,
        processProducts: _processProducts,
      );
      return {'animal': a, 'profit': profit};
    }).toList();

    profits.sort((a, b) => (b['profit'] as double).compareTo(a['profit'] as double));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de controles
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.pets, color: StardewColors.primaryGold),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Simulador de Rentabilidad de Ganadería',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StardewColors.primaryGold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Animales:', style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 70,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: StardewColors.textBright),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: '$_animalCount')..selection = TextSelection.collapsed(offset: '$_animalCount'.length),
                              onChanged: (v) {
                                final val = int.tryParse(v);
                                if (val != null && val > 0) {
                                  setState(() => _animalCount = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      FilterChip(
                        selected: _processProducts,
                        label: const Text('Transformar en Productos Artesanales (Queso, Mayonesa...)'),
                        onSelected: (val) => setState(() => _processProducts = val),
                        selectedColor: StardewColors.oceanBlue.withAlpha(50),
                        checkmarkColor: StardewColors.oceanBlue,
                      ),
                      FilterChip(
                        selected: _isArtisan,
                        label: const Text('Profesión: Artesano (+40%)'),
                        onSelected: (val) => setState(() => _isArtisan = val),
                        selectedColor: StardewColors.primaryGold.withAlpha(50),
                        checkmarkColor: StardewColors.primaryGold,
                      ),
                      FilterChip(
                        selected: _isRancher,
                        label: const Text('Profesión: Ranchero (+20%)'),
                        onSelected: (val) => setState(() => _isRancher = val),
                        selectedColor: StardewColors.emeraldGreen.withAlpha(50),
                        checkmarkColor: StardewColors.emeraldGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ranking de animales
          const Text(
            '🏆 Ranking de Producción Diaria de Animales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StardewColors.textBright),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profits.length,
            itemBuilder: (context, index) {
              final item = profits[index];
              final animal = item['animal'] as AnimalModel;
              final dailyProfit = item['profit'] as double;
              final seasonProfit = dailyProfit * 28;

              final medalColor = index == 0
                  ? const Color(0xFFFFD700)
                  : index == 1
                      ? const Color(0xFFC0C0C0)
                      : index == 2
                          ? const Color(0xFFCD7F32)
                          : StardewColors.cardBorder;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: medalColor, width: index < 3 ? 1.5 : 0.5),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: medalColor.withAlpha(40),
                    child: Text('#${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: medalColor)),
                  ),
                  title: Text(
                    animal.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright),
                  ),
                  subtitle: Text(
                    '${animal.building} • Producción cada ${animal.daysToProduce} día(s)\nProducto: ${_processProducts ? animal.processedProduct : animal.baseProduct}',
                    style: const TextStyle(color: StardewColors.textMuted, fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${dailyProfit.toInt()}g / día',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: StardewColors.emeraldGreen),
                      ),
                      Text(
                        '~${seasonProfit.toInt()}g / estación',
                        style: const TextStyle(fontSize: 11, color: StardewColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
