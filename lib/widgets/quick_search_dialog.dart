import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crop_model.dart';
import '../providers/crop_provider.dart';
import '../providers/mod_provider.dart';
import '../providers/save_provider.dart';
import '../providers/task_provider.dart';
import '../providers/planted_crop_provider.dart';
import '../views/crop_calculator/planted_crops_tab.dart';
import 'villager_gifts_dialog.dart';
import '../theme/stardew_theme.dart';
import 'stardew_avatars.dart';

class QuickSearchDialog extends StatefulWidget {
  const QuickSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const QuickSearchDialog(),
    );
  }

  @override
  State<QuickSearchDialog> createState() => _QuickSearchDialogState();
}

class _QuickSearchDialogState extends State<QuickSearchDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  static final List<Map<String, dynamic>> _villagers = [
    {'name': 'Abigail', 'birthday': 'Otoño 13', 'loved': 'Amatista, Pastel de Mora, Calabaza, Anguila Picante'},
    {'name': 'Alex', 'birthday': 'Verano 13', 'loved': 'Cena de Salmón, Plato Completo'},
    {'name': 'Elliott', 'birthday': 'Otoño 5', 'loved': 'Cangrejo, Tinta de Calamar, Langosta, Sopa de Tomate'},
    {'name': 'Emily', 'birthday': 'Primavera 27', 'loved': 'Amatista, Esmeralda, Rubí, Topacio, Tela, Hamburguesa de Sobras'},
    {'name': 'Haley', 'birthday': 'Primavera 14', 'loved': 'Girasol, Pastel Rosa, Coco, Ensalada de Frutas'},
    {'name': 'Harvey', 'birthday': 'Invierno 14', 'loved': 'Café, Vino, Aceite de Trufa, Ensalada, Súper Comida'},
    {'name': 'Leah', 'birthday': 'Invierno 23', 'loved': 'Ensalada, Vino, Salteado de Verduras, Queso de Cabra'},
    {'name': 'Maru', 'birthday': 'Verano 10', 'loved': 'Lingote de Iridio, Queso de Cabra, Fresa, Pastel de Ruibarbo'},
    {'name': 'Penny', 'birthday': 'Otoño 2', 'loved': 'Esmeralda, Melón, Amapola, Sopa de Tomate, Diamante'},
    {'name': 'Sam', 'birthday': 'Verano 17', 'loved': 'Pizza, Fruta de Cacto, Ojo de Tigre'},
    {'name': 'Sebastian', 'birthday': 'Invierno 10', 'loved': 'Lágrima Helada, Sashimi, Sopa de Calabaza, Obsidiana'},
    {'name': 'Shane', 'birthday': 'Primavera 20', 'loved': 'Pizza, Cerveza, Pimienta Caliente, Pimiento Relleno'},
  ];

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropProvider>(context);
    final modProvider = Provider.of<ModProvider>(context);
    final saveProvider = Provider.of<SaveProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    final isModsEnabled = modProvider.isModsEnabledForFarm(saveProvider.activeFarmKey);
    final crops = cropProvider.getCropsForFarm(includeModCrops: isModsEnabled);

    // Filtrar resultados
    final matchingCrops = _query.isEmpty
        ? <CropModel>[]
        : crops
            .where((c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()) ||
                c.sourceMod.toLowerCase().contains(_query.toLowerCase()))
            .take(6)
            .toList();

    final matchingVillagers = _query.isEmpty
        ? <Map<String, dynamic>>[]
        : _villagers
            .where((v) =>
                (v['name'] as String).toLowerCase().contains(_query.toLowerCase()) ||
                (v['loved'] as String).toLowerCase().contains(_query.toLowerCase()))
            .take(6)
            .toList();

    final matchingTasks = _query.isEmpty
        ? <Map<String, dynamic>>[]
        : taskProvider.tasks
            .where((t) => (t['title'] as String).toLowerCase().contains(_query.toLowerCase()))
            .take(6)
            .toList();

    return Dialog(
      backgroundColor: StardewColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: StardewColors.primaryGold, width: 2),
      ),
      child: Container(
        width: 600,
        height: 550,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: StardewColors.primaryGold, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Buscador Universal de Stardew',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: StardewColors.primaryGold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: StardewColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: StardewColors.textBright),
              decoration: InputDecoration(
                hintText: 'Escribe un cultivo, aldeano, regalo o tarea...',
                hintStyle: const TextStyle(color: StardewColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: StardewColors.oceanBlue),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: StardewColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: StardewColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: StardewColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: StardewColors.primaryGold, width: 1.5),
                ),
              ),
              onChanged: (val) => setState(() => _query = val.trim()),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.manage_search, size: 48, color: StardewColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'Busca cultivos (Fresa, Carambola...), regalos de aldeanos o tareas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: StardewColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        if (matchingCrops.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Text(
                              '🌱 Cultivos',
                              style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.emeraldGreen),
                            ),
                          ),
                          ...matchingCrops.map((c) => Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    final plantedProvider = Provider.of<PlantedCropProvider>(context, listen: false);
                                    PlantedCropsTab.showBatchFormModal(
                                      context,
                                      allCrops: crops,
                                      plantedProvider: plantedProvider,
                                      initialCropName: c.name,
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: StardewColors.emeraldGreen.withAlpha(40),
                                    child: const Text('🌾', style: TextStyle(fontSize: 18)),
                                  ),
                                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                                  subtitle: Text('${c.season} • Compra: ${c.seedCost.toInt()}g • Venta: ${c.baseSellPrice.toInt()}g (${c.sourceMod})', style: const TextStyle(color: StardewColors.textMuted, fontSize: 12)),
                                  trailing: Text('${c.daysToGrow} días', style: const TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold)),
                                ),
                              )),
                        ],
                        if (matchingVillagers.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Text(
                              '❤️ Aldeanos & Regalos Favoritos',
                              style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.iridiumPurple),
                            ),
                          ),
                          ...matchingVillagers.map((v) => Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => const VillagerGiftsDialog(),
                                    );
                                  },
                                  leading: VillagerAvatar(name: v['name'] as String, size: 36),
                                  title: Text(v['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                                  subtitle: Text('Cumpleaños: ${v['birthday']}\nRegalos: ${v['loved']}', style: const TextStyle(color: StardewColors.textMuted, fontSize: 12)),
                                  isThreeLine: true,
                                ),
                              )),
                        ],
                        if (matchingTasks.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Text(
                              '📅 Tareas del Calendario',
                              style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.oceanBlue),
                            ),
                          ),
                          ...matchingTasks.map((t) => Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('📅 Tarea: ${t['title']} (${t['season']} Día ${t['day']})'),
                                        backgroundColor: StardewColors.oceanBlue,
                                      ),
                                    );
                                  },
                                  leading: const Icon(Icons.check_box_outlined, color: StardewColors.oceanBlue),
                                  title: Text(t['title'] as String, style: const TextStyle(color: StardewColors.textBright)),
                                  subtitle: Text('${t['season']} • Día ${t['day']}', style: const TextStyle(color: StardewColors.textMuted, fontSize: 12)),
                                ),
                              )),
                        ],
                        if (matchingCrops.isEmpty && matchingVillagers.isEmpty && matchingTasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No se encontraron resultados para tu búsqueda.',
                                style: TextStyle(color: StardewColors.textMuted),
                              ),
                            ),
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
