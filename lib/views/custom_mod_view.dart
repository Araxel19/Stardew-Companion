import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/stardew_theme.dart';

class CustomModView extends StatefulWidget {
  const CustomModView({super.key});

  @override
  State<CustomModView> createState() => _CustomModViewState();
}

class _CustomModViewState extends State<CustomModView> {
  final _nameController = TextEditingController();
  final _seedCostController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _growthDaysController = TextEditingController();
  final _regrowDaysController = TextEditingController();
  final _modNameController = TextEditingController(text: 'Ridgeside Village');

  String _selectedSeason = 'Primavera';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final customCrops = provider.allCrops.where((c) => c.sourceMod != 'Vanilla').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestor de Contenido & Cultivos de Mods', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, color: StardewColors.primaryGold)),
                  const SizedBox(height: 4),
                  const Text('Agrega cultivos, objetos y recetas de tus mods (SVE, Ridgeside, East Scarp, etc.) para incluirlos en los cálculos.', style: TextStyle(color: StardewColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddModCropDialog(context, provider),
                icon: const Icon(Icons.extension),
                label: const Text('Agregar Cultivo de Mod'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StardewColors.oceanBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Mod Crops List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cultivos de Mods Registrados (${customCrops.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                  const SizedBox(height: 16),
                  if (customCrops.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No hay cultivos de mods registrados. ¡Haz clic en Agregar Cultivo de Mod!')),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: customCrops.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final crop = customCrops[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: StardewColors.oceanBlue.withOpacity(0.2),
                            child: const Icon(Icons.nature, color: StardewColors.oceanBlue),
                          ),
                          title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                          subtitle: Text('Mod: ${crop.sourceMod} • Estación: ${crop.season} • Crecimiento: ${crop.daysToGrow}d'),
                          trailing: Text(
                            'Semilla: ${crop.seedCost.toInt()}g | Venta: ${crop.baseSellPrice.toInt()}g',
                            style: const TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold),
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

  void _showAddModCropDialog(BuildContext context, AppStateProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: StardewColors.cardBackground,
          title: const Text('Agregar Nuevo Cultivo de Mod', style: TextStyle(color: StardewColors.primaryGold)),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Cultivo (ej. Cereza de la Cresta)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modNameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Mod (ej. Ridgeside Village)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedSeason,
                    decoration: const InputDecoration(labelText: 'Estación'),
                    items: ['Primavera', 'Verano', 'Otoño', 'Invernadero'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _selectedSeason = v!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _seedCostController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio Semilla (g)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _sellPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio Venta Base (g)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _growthDaysController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Días Crecimiento'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _regrowDaysController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Días Re-cosecha (0 si no re-crece)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final modName = _modNameController.text.trim();
                final seedCost = double.tryParse(_seedCostController.text.trim()) ?? 0;
                final sellPrice = double.tryParse(_sellPriceController.text.trim()) ?? 0;
                final daysToGrow = int.tryParse(_growthDaysController.text.trim()) ?? 1;
                final regrowDays = int.tryParse(_regrowDaysController.text.trim()) ?? 0;

                if (name.isNotEmpty && seedCost > 0 && sellPrice > 0) {
                  provider.addCustomCrop(
                    name: name,
                    season: _selectedSeason,
                    seedCost: seedCost,
                    sellPrice: sellPrice,
                    daysToGrow: daysToGrow,
                    regrowDays: regrowDays,
                    sourceMod: modName.isEmpty ? 'Custom Mod' : modName,
                  );
                  _nameController.clear();
                  _seedCostController.clear();
                  _sellPriceController.clear();
                  _growthDaysController.clear();
                  _regrowDaysController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: StardewColors.oceanBlue, foregroundColor: Colors.white),
              child: const Text('Guardar Cultivo'),
            ),
          ],
        );
      },
    );
  }
}
