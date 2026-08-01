import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/save_data.dart';
import '../providers/app_state_provider.dart';
import '../providers/mod_provider.dart';
import '../providers/save_provider.dart';

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
    final installedMods = provider.installedMods;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 750;
              final headerInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestor de Contenido & Cultivos de Mods',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, color: StardewColors.primaryGold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Administra tus mods instalados y agrega cultivos, objetos y recetas personalizadas (SVE, Ridgeside, etc.).',
                    style: TextStyle(color: StardewColors.textMuted),
                  ),
                ],
              );

              final actionButtons = Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      String? selectedDirectory = await FilePicker.getDirectoryPath(
                        dialogTitle: 'Selecciona la carpeta de Mods de Stardew Valley',
                      );
                      if (selectedDirectory != null) {
                        provider.scanInstalledMods(customPath: selectedDirectory);
                      }
                    },
                    icon: const Icon(Icons.folder_open, color: StardewColors.primaryGold),
                    label: const Text('Carpeta de Mods', style: TextStyle(color: StardewColors.primaryGold)),
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
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: headerInfo),
                    const SizedBox(width: 16),
                    actionButtons,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerInfo,
                    const SizedBox(height: 16),
                    actionButtons,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Installed Mods Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (ctx) {
                      final modProvider = Provider.of<ModProvider>(ctx);
                      final saveProvider = Provider.of<SaveProvider>(ctx);
                      final farmKey = saveProvider.activeFarmKey;
                      final isEnabled = modProvider.isModsEnabledForFarm(farmKey);
                      final farmName = saveProvider.activeSaveData?.farmName ?? 'Granja Actual';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isEnabled ? StardewColors.oceanBlue.withAlpha(20) : StardewColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isEnabled ? StardewColors.oceanBlue : StardewColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Switch(
                              value: isEnabled,
                              activeThumbColor: StardewColors.emeraldGreen,
                              onChanged: (val) {
                                modProvider.toggleModsForFarm(farmKey, val);
                              },
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Activar Mods para la partida: "$farmName"',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright, fontSize: 13),
                                  ),
                                  Text(
                                    isEnabled
                                        ? 'Esta granja utiliza contenido de mods (SVE, RSV, etc.).'
                                        : 'Esta granja es Vanilla (los cultivos de mods se ocultarán para esta partida).',
                                    style: const TextStyle(color: StardewColors.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.extension_outlined, color: StardewColors.oceanBlue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Mods Detectados en tu Sistema (${installedMods.length})',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.sync, color: StardewColors.oceanBlue),
                        tooltip: 'Volver a escanear mods',
                        onPressed: () => provider.scanInstalledMods(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (installedMods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No se encontraron mods automáticamente. Haz clic en "Carpeta de Mods" arriba para seleccionar manualmente la carpeta de tus mods.'),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: installedMods.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final mod = installedMods[index];
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                onTap: () => _showModDetailsModal(context, mod),
                                leading: CircleAvatar(
                                  backgroundColor: StardewColors.oceanBlue.withValues(alpha: 0.2),
                                  child: const Icon(Icons.extension, color: StardewColors.oceanBlue, size: 20),
                                ),
                                title: Text(mod.name, style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                                subtitle: Text('Autor: ${mod.author} • ID: ${mod.uniqueId}'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: StardewColors.cardBorder,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('v${mod.version}', style: const TextStyle(color: StardewColors.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
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
                      child: Center(child: Text('No hay cultivos de mods registrados manualmente. ¡Haz clic en Agregar Cultivo de Mod!')),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: customCrops.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final crop = customCrops[index];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: StardewColors.oceanBlue.withValues(alpha: 0.2),
                              child: const Icon(Icons.nature, color: StardewColors.oceanBlue),
                            ),
                            title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                            subtitle: Text('Mod: ${crop.sourceMod} • Estación: ${crop.season} • Crecimiento: ${crop.daysToGrow}d'),
                            trailing: Text(
                              'Semilla: ${crop.seedCost.toInt()}g | Venta: ${crop.baseSellPrice.toInt()}g',
                              style: const TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold),
                            ),
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
                    initialValue: _selectedSeason,
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

  void _showModDetailsModal(BuildContext context, StardewModInfo mod) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StardewColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: StardewColors.oceanBlue.withValues(alpha: 0.2),
                    child: const Icon(Icons.extension, color: StardewColors.oceanBlue, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mod.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: StardewColors.primaryGold)),
                        const SizedBox(height: 4),
                        Text('Versión ${mod.version} • Por ${mod.author}', style: const TextStyle(color: StardewColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text('🆔 ID Único del Mod:', style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: StardewColors.background, borderRadius: BorderRadius.circular(8)),
                child: Text(mod.uniqueId, style: const TextStyle(fontFamily: 'monospace', color: StardewColors.oceanBlue)),
              ),
              const SizedBox(height: 16),
              const Text('📄 Descripción:', style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
              const SizedBox(height: 4),
              Text(mod.description.isNotEmpty ? mod.description : 'Mod de Stardew Valley instalado en la carpeta de Mods del juego.', style: const TextStyle(color: StardewColors.textMuted)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: StardewColors.oceanBlue, foregroundColor: Colors.white),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
