import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../application/crop_calculator_service.dart';
import '../../models/crop_model.dart';
import '../../models/planted_crop_model.dart';
import '../../providers/crop_provider.dart';
import '../../providers/planted_crop_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/stardew_theme.dart';
import '../../widgets/stardew_avatars.dart';

/// Pestaña 4 del Simulador: Gestor de Lotes de Cultivos Plantados ("Mis Parcelas").
///
/// Permite el seguimiento individualizado de cada lote sembrado en la granja,
/// con opción de indicar el día exacto de cosecha (según UI Info Suite / mods),
/// parcelas, edición, eliminación y agendamiento al calendario.
class PlantedCropsTab extends StatelessWidget {
  const PlantedCropsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final plantedProvider = Provider.of<PlantedCropProvider>(context);
    final cropProvider = Provider.of<CropProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final batches = plantedProvider.batches;
    final allCrops = cropProvider.allCrops;
    final fmt = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);
    final isMobile = MediaQuery.of(context).size.width < 700;

    // Métricas consolidadas
    int totalPlots = 0;
    double totalSeedInvestment = 0;
    double totalNetProfit = 0;

    for (final batch in batches) {
      totalPlots += batch.quantity;
      final crop = _findCrop(allCrops, batch);
      if (crop != null) {
        final harvests = CropCalculatorService.totalHarvestsInSeason(
          crop,
          plantDay: batch.plantDay,
          fertilizer: batch.fertilizer,
          alreadyPlanted: batch.alreadyPlanted,
          daysUntilFirstHarvest: batch.daysUntilFirstHarvest,
          exactFirstHarvestDay: batch.exactFirstHarvestDay,
        );
        final itemPrice = CropCalculatorService.getSellPrice(
          crop,
          method: batch.processingMethod,
        );
        final seedTimes = crop.regrowDays > 0 ? 1 : harvests;
        final seedCost = (batch.alreadyPlanted || batch.exactFirstHarvestDay != null) ? 0.0 : crop.seedCost * seedTimes * batch.quantity;
        final grossRevenue = itemPrice * harvests * batch.quantity;
        totalSeedInvestment += seedCost;
        totalNetProfit += (grossRevenue - seedCost);
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen Consolidado de la Granja
          Card(
            color: StardewColors.background,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pie_chart, color: StardewColors.primaryGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Resumen Consolidado de Parcelas (${batches.length} lotes activos)',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: StardewColors.textBright),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: isMobile ? 1 : 3,
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isMobile ? 3.5 : 2.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _summaryTile('🌱 Total Parcelas Ocupadas', '$totalPlots parcelas', StardewColors.oceanBlue),
                      _summaryTile('💰 Inversión en Semillas', fmt.format(totalSeedInvestment), StardewColors.primaryGold),
                      _summaryTile('✅ Ganancia Neta Esperada', fmt.format(totalNetProfit),
                          totalNetProfit >= 0 ? StardewColors.emeraldGreen : Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón de acción para agregar nuevo lote + Sincronizar Calendario
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text(
                '🌾 Lotes Plantados en tu Granja',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StardewColors.textBright),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _syncFromCalendar(context, plantedProvider, taskProvider, allCrops),
                    icon: const Icon(Icons.sync, size: 16, color: StardewColors.primaryGold),
                    label: const Text('Importar del Calendario', style: TextStyle(fontSize: 12, color: StardewColors.primaryGold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: StardewColors.primaryGold),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showBatchFormModal(context, allCrops: allCrops, plantedProvider: plantedProvider),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar Lote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StardewColors.emeraldGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista de lotes o estado vacío
          if (batches.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.nature_people, size: 48, color: StardewColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'No tienes lotes plantados registrados aún.',
                        style: TextStyle(color: StardewColors.textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Presiona "Agregar Lote" o importa tus tareas de cosecha existentes desde el calendario.',
                        style: TextStyle(color: StardewColors.textMuted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => _syncFromCalendar(context, plantedProvider, taskProvider, allCrops),
                        icon: const Icon(Icons.sync, size: 16),
                        label: const Text('Importar Cosechas del Calendario'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StardewColors.primaryGold,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: batches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final batch = batches[index];
                final crop = _findCrop(allCrops, batch);
                return _buildBatchCard(context, batch, crop, fmt, plantedProvider, taskProvider, allCrops);
              },
            ),
        ],
      ),
    );
  }

  void _syncFromCalendar(
    BuildContext context,
    PlantedCropProvider plantedProvider,
    TaskProvider taskProvider,
    List<CropModel> allCrops,
  ) {
    final tasks = taskProvider.tasks;
    final harvestTasks = tasks.where((t) => (t['title'] ?? '').toString().contains('Cosecha')).toList();

    if (harvestTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontraron tareas de cosecha en el calendario.')),
      );
      return;
    }

    int importedCount = 0;
    for (final task in harvestTasks) {
      final title = task['title'].toString();
      String cropName = title.replaceFirst('🌾 Cosecha:', '').trim();
      int quantity = 10;
      if (cropName.contains('(')) {
        final match = RegExp(r'\((\d+)\s*parcelas\)').firstMatch(cropName);
        if (match != null) {
          quantity = int.tryParse(match.group(1) ?? '10') ?? 10;
        }
        cropName = cropName.split('(').first.trim();
      }

      final exists = plantedProvider.batches.any((b) => b.cropName.toLowerCase() == cropName.toLowerCase());
      if (!exists) {
        final crop = allCrops.firstWhere(
          (c) => c.name.toLowerCase() == cropName.toLowerCase(),
          orElse: () => allCrops.isNotEmpty ? allCrops.first : const CropModel(id: 'parsnip', name: 'Chirivía', season: 'Primavera', seedCost: 20, baseSellPrice: 35, daysToGrow: 4),
        );

        final day = (task['day'] as int?) ?? 1;
        final season = (task['season'] as String?) ?? crop.season;

        final newBatch = PlantedCropBatch(
          cropId: crop.id,
          cropName: crop.name,
          season: season,
          quantity: quantity,
          plantDay: 1,
          alreadyPlanted: true,
          exactFirstHarvestDay: day,
          fertilizer: Fertilizer.none,
          processingMethod: ProcessingMethod.raw,
        );

        plantedProvider.addBatch(newBatch);
        importedCount++;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(importedCount > 0
            ? '¡Se importaron $importedCount lote(s) desde las tareas del calendario a Mis Parcelas!'
            : 'Tus lotes ya estaban sincronizados con las tareas del calendario.'),
        backgroundColor: StardewColors.emeraldGreen,
      ),
    );
  }

  CropModel? _findCrop(List<CropModel> crops, PlantedCropBatch batch) {
    return crops.firstWhere(
      (c) => c.name.toLowerCase() == batch.cropName.toLowerCase(),
      orElse: () => crops.isNotEmpty ? crops.first : const CropModel(id: '', name: 'Desconocido', season: 'Primavera', seedCost: 0, baseSellPrice: 0, daysToGrow: 1),
    );
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StardewColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: StardewColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildBatchCard(
    BuildContext context,
    PlantedCropBatch batch,
    CropModel? crop,
    NumberFormat fmt,
    PlantedCropProvider plantedProvider,
    TaskProvider taskProvider,
    List<CropModel> allCrops,
  ) {
    final harvests = crop != null
        ? CropCalculatorService.totalHarvestsInSeason(
            crop,
            plantDay: batch.plantDay,
            fertilizer: batch.fertilizer,
            alreadyPlanted: batch.alreadyPlanted,
            daysUntilFirstHarvest: batch.daysUntilFirstHarvest,
            exactFirstHarvestDay: batch.exactFirstHarvestDay,
          )
        : 1;

    final itemPrice = crop != null
        ? CropCalculatorService.getSellPrice(crop, method: batch.processingMethod)
        : 0.0;

    final seedTimes = (crop != null && crop.regrowDays > 0) ? 1 : harvests;
    final seedCost = (batch.alreadyPlanted || batch.exactFirstHarvestDay != null) ? 0.0 : (crop?.seedCost ?? 0) * seedTimes * batch.quantity;
    final grossRevenue = itemPrice * harvests * batch.quantity;
    final netProfit = grossRevenue - seedCost;

    final harvestDays = crop != null
        ? CropCalculatorService.getHarvestDays(
            crop,
            plantDay: batch.plantDay,
            fertilizer: batch.fertilizer,
            alreadyPlanted: batch.alreadyPlanted,
            daysUntilFirstHarvest: batch.daysUntilFirstHarvest,
            exactFirstHarvestDay: batch.exactFirstHarvestDay,
          )
        : <int>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Avatar + Nombre + Badges + Acciones
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CropAvatar(
                  name: batch.cropName,
                  season: batch.season,
                  isModded: false,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${batch.cropName} · ${batch.quantity} parcelas',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: StardewColors.primaryGold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _badge('🌱 ${batch.season}', StardewColors.oceanBlue),
                          if (batch.exactFirstHarvestDay != null && batch.exactFirstHarvestDay! > 0)
                            _badge('🌕 Cosecha Exacta: Día ${batch.exactFirstHarvestDay}', StardewColors.primaryGold)
                          else if (batch.alreadyPlanted)
                            _badge('⚡ En progreso (${batch.daysUntilFirstHarvest}d rest.)', StardewColors.emeraldGreen)
                          else
                            _badge('📅 Siembra: Día ${batch.plantDay}', StardewColors.primaryGold),
                          if (batch.fertilizer != Fertilizer.none)
                            _badge('🧪 ${_fertilizerName(batch.fertilizer)}', StardewColors.iridiumPurple),
                          _badge('⚙️ ${_methodName(batch.processingMethod)}', StardewColors.textMuted),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: StardewColors.primaryGold, size: 20),
                      tooltip: 'Editar lote',
                      onPressed: () => showBatchFormModal(
                        context,
                        allCrops: allCrops,
                        plantedProvider: plantedProvider,
                        existingBatch: batch,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      tooltip: 'Eliminar lote',
                      onPressed: () => _confirmDelete(context, plantedProvider, batch, taskProvider),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),

            // Métricas rápidas del lote + Botón Agendar Cosechas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fechas de Cosecha: ${harvestDays.map((d) => "D$d").join(", ")}  ·  $harvests cosechas',
                        style: const TextStyle(fontSize: 12, color: StardewColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ganancia Neta Lote: ${fmt.format(netProfit)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: netProfit >= 0 ? StardewColors.emeraldGreen : Colors.redAccent,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: harvestDays.isEmpty
                      ? null
                      : () {
                          for (var day in harvestDays) {
                            taskProvider.addTask(
                              title: '🌾 Cosecha: ${batch.cropName} (${batch.quantity} parcelas)',
                              season: batch.season,
                              day: day,
                              category: 'Cosecha',
                            );
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('¡Se agendaron ${harvestDays.length} cosecha(s) para ${batch.cropName}!'),
                              backgroundColor: StardewColors.emeraldGreen,
                            ),
                          );
                        },
                  icon: const Icon(Icons.calendar_month, size: 16),
                  label: const Text('Agendar', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StardewColors.primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  String _fertilizerName(Fertilizer f) {
    switch (f) {
      case Fertilizer.none:
        return 'Sin Fertilizante';
      case Fertilizer.basicSpeedGro:
        return 'Speed-Gro (10%)';
      case Fertilizer.deluxeSpeedGro:
        return 'Deluxe Speed-Gro (15%)';
      case Fertilizer.hyperSpeedGro:
        return 'Hyper Speed-Gro (25%)';
    }
  }

  String _methodName(ProcessingMethod m) {
    switch (m) {
      case ProcessingMethod.raw:
        return 'Venta Directa';
      case ProcessingMethod.jar:
        return 'Conservas';
      case ProcessingMethod.keg:
        return 'Barril';
      case ProcessingMethod.dehydrator:
        return 'Deshidratadora';
    }
  }

  void _confirmDelete(
    BuildContext context,
    PlantedCropProvider provider,
    PlantedCropBatch batch,
    TaskProvider taskProvider,
  ) {
    bool deleteCalendarTask = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            backgroundColor: StardewColors.cardBackground,
            title: const Text('Eliminar Lote Plantado', style: TextStyle(color: StardewColors.primaryGold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Deseas eliminar el lote de ${batch.cropName} (${batch.quantity} parcelas)?'),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: CheckboxListTile(
                    title: const Text('Eliminar también del Calendario', style: TextStyle(fontSize: 13, color: StardewColors.textBright)),
                    subtitle: const Text('Evita que vuelva a re-importarse al sincronizar.', style: TextStyle(fontSize: 11, color: StardewColors.textMuted)),
                    value: deleteCalendarTask,
                    activeColor: StardewColors.emeraldGreen,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setStateModal(() => deleteCalendarTask = val ?? true);
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  if (batch.id != null) {
                    provider.deleteBatch(batch.id!);
                  }
                  if (deleteCalendarTask) {
                    final matchingTasks = taskProvider.tasks.where(
                      (t) => (t['title'] ?? '').toString().toLowerCase().contains(batch.cropName.toLowerCase()),
                    ).toList();
                    for (final t in matchingTasks) {
                      if (t['id'] != null) {
                        taskProvider.deleteTask(t['id'] as int);
                      }
                    }
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Eliminar'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showBatchFormModal(
    BuildContext context, {
    required List<CropModel> allCrops,
    required PlantedCropProvider plantedProvider,
    PlantedCropBatch? existingBatch,
    String? initialCropName,
    int? initialQuantity,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StardewColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _BatchFormSheet(
        allCrops: allCrops,
        plantedProvider: plantedProvider,
        existingBatch: existingBatch,
        initialCropName: initialCropName,
        initialQuantity: initialQuantity,
      ),
    );
  }
}

/// Sheet/Modal de Formulario para Crear o Editar un Lote de Cultivo.
class _BatchFormSheet extends StatefulWidget {
  final List<CropModel> allCrops;
  final PlantedCropProvider plantedProvider;
  final PlantedCropBatch? existingBatch;
  final String? initialCropName;
  final int? initialQuantity;

  const _BatchFormSheet({
    required this.allCrops,
    required this.plantedProvider,
    this.existingBatch,
    this.initialCropName,
    this.initialQuantity,
  });

  @override
  State<_BatchFormSheet> createState() => _BatchFormSheetState();
}

class _BatchFormSheetState extends State<_BatchFormSheet> {
  late String _selectedCropName;
  late String _selectedSeason;
  late int _quantity;
  late int _plantDay;
  late int _daysUntilFirstHarvest;
  late int? _exactFirstHarvestDay;
  late int _timingMode; // 0: Día de Siembra, 1: Días Faltantes, 2: Día Exacto de Cosecha (1..28)
  late Fertilizer _fertilizer;
  late ProcessingMethod _method;

  @override
  void initState() {
    super.initState();
    final batch = widget.existingBatch;
    if (batch != null) {
      _selectedCropName = batch.cropName;
      _selectedSeason = batch.season;
      _quantity = batch.quantity;
      _plantDay = batch.plantDay;
      _daysUntilFirstHarvest = batch.daysUntilFirstHarvest;
      _exactFirstHarvestDay = batch.exactFirstHarvestDay;
      _timingMode = batch.exactFirstHarvestDay != null
          ? 2
          : batch.alreadyPlanted
              ? 1
              : 0;
      _fertilizer = batch.fertilizer;
      _method = batch.processingMethod;
    } else {
      final firstCrop = widget.allCrops.isNotEmpty ? widget.allCrops.first : null;
      _selectedCropName = firstCrop?.name ?? 'Chilacayote';
      _selectedSeason = firstCrop?.season ?? 'Primavera';
      _quantity = widget.initialQuantity ?? 20;
      _plantDay = 1;
      _daysUntilFirstHarvest = firstCrop?.daysToGrow ?? 4;
      _exactFirstHarvestDay = null;
      _timingMode = 0;
      _fertilizer = Fertilizer.none;
      _method = ProcessingMethod.keg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBatch != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: StardewColors.cardBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEditing ? '✏️ Editar Lote Plantado' : '🌱 Agregar Nuevo Lote Plantado',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.primaryGold),
            ),
            const SizedBox(height: 16),

            // Selección de Cultivo + Estación
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: widget.allCrops.any((c) => c.name == _selectedCropName)
                        ? _selectedCropName
                        : (widget.allCrops.isNotEmpty ? widget.allCrops.first.name : null),
                    decoration: const InputDecoration(labelText: 'Cultivo', border: OutlineInputBorder()),
                    items: widget.allCrops
                        .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedCropName = v;
                          final found = widget.allCrops.firstWhere((c) => c.name == v);
                          if (found.season != 'Invernadero') {
                            _selectedSeason = found.season;
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSeason,
                    decoration: const InputDecoration(labelText: 'Estación', border: OutlineInputBorder()),
                    items: ['Primavera', 'Verano', 'Otoño', 'Invierno', 'Invernadero']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSeason = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Cantidad de parcelas
            Row(
              children: [
                const Icon(Icons.grid_on, size: 16, color: StardewColors.primaryGold),
                const SizedBox(width: 6),
                Text('Parcelas / Plantas: $_quantity',
                    style: const TextStyle(color: StardewColors.textBright, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _quantity.toDouble(), min: 1, max: 500, divisions: 499,
              activeColor: StardewColors.primaryGold,
              onChanged: (v) => setState(() => _quantity = v.round()),
            ),
            const SizedBox(height: 10),

            // Modo de Fecha de Cosecha / Crecimiento
            const Text('⏱️ Cálculo de Fecha de Cosecha:', style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.primaryGold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StardewColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: StardewColors.cardBorder),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    RadioListTile<int>(
                      title: const Text('Siembra normal (por día de siembra)', style: TextStyle(fontSize: 13, color: StardewColors.textBright)),
                      subtitle: const Text('Calcula días según ciclo de crecimiento del cultivo', style: TextStyle(fontSize: 11, color: StardewColors.textMuted)),
                      value: 0,
                      // ignore: deprecated_member_use
                      groupValue: _timingMode,
                      activeColor: StardewColors.primaryGold,
                      // ignore: deprecated_member_use
                      onChanged: (v) => setState(() {
                        _timingMode = v!;
                        _exactFirstHarvestDay = null;
                      }),
                    ),
                    RadioListTile<int>(
                      title: const Text('En progreso (ingresar días faltantes)', style: TextStyle(fontSize: 13, color: StardewColors.textBright)),
                      subtitle: const Text('Util para cultivos ya sembrados hace días', style: TextStyle(fontSize: 11, color: StardewColors.textMuted)),
                      value: 1,
                      // ignore: deprecated_member_use
                      groupValue: _timingMode,
                      activeColor: StardewColors.emeraldGreen,
                      // ignore: deprecated_member_use
                      onChanged: (v) => setState(() {
                        _timingMode = v!;
                        _exactFirstHarvestDay = null;
                      }),
                    ),
                    RadioListTile<int>(
                      title: const Text('Día exacto de Cosecha en el Juego (1..28)', style: TextStyle(fontSize: 13, color: StardewColors.textBright)),
                      subtitle: const Text('Si ya sabes el día exacto por tu UI/Mod en el juego', style: TextStyle(fontSize: 11, color: StardewColors.textMuted)),
                      value: 2,
                      // ignore: deprecated_member_use
                      groupValue: _timingMode,
                      activeColor: StardewColors.oceanBlue,
                      // ignore: deprecated_member_use
                      onChanged: (v) => setState(() {
                        _timingMode = v!;
                        _exactFirstHarvestDay = _exactFirstHarvestDay ?? 10;
                      }),
                    ),

                    const Divider(height: 16),

                    if (_timingMode == 0) ...[
                      Row(children: [
                        const Icon(Icons.calendar_today, size: 14, color: StardewColors.primaryGold),
                        const SizedBox(width: 6),
                        Text('Día de siembra: $_plantDay', style: const TextStyle(color: StardewColors.textBright, fontSize: 13)),
                      ]),
                      Slider(
                        value: _plantDay.toDouble(), min: 1, max: 26, divisions: 25,
                        activeColor: StardewColors.primaryGold,
                        onChanged: (v) => setState(() => _plantDay = v.round()),
                      ),
                    ] else if (_timingMode == 1) ...[
                      Row(children: [
                        const Icon(Icons.timer, size: 14, color: StardewColors.emeraldGreen),
                        const SizedBox(width: 6),
                        Text('Días restantes para primera cosecha: $_daysUntilFirstHarvest', style: const TextStyle(color: StardewColors.textBright, fontSize: 13)),
                      ]),
                      Slider(
                        value: _daysUntilFirstHarvest.toDouble(), min: 1, max: 27, divisions: 26,
                        activeColor: StardewColors.emeraldGreen,
                        onChanged: (v) => setState(() => _daysUntilFirstHarvest = v.round()),
                      ),
                    ] else if (_timingMode == 2) ...[
                      Row(children: [
                        const Icon(Icons.event_available, size: 14, color: StardewColors.oceanBlue),
                        const SizedBox(width: 6),
                        Text('Día exacto de cosecha: Día ${_exactFirstHarvestDay ?? 10}', style: const TextStyle(color: StardewColors.textBright, fontSize: 13, fontWeight: FontWeight.bold)),
                      ]),
                      Slider(
                        value: (_exactFirstHarvestDay ?? 10).toDouble(), min: 1, max: 28, divisions: 27,
                        activeColor: StardewColors.oceanBlue,
                        onChanged: (v) => setState(() => _exactFirstHarvestDay = v.round()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Fertilizante + Procesamiento
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Fertilizer>(
                    initialValue: _fertilizer,
                    decoration: const InputDecoration(labelText: 'Fertilizante', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: Fertilizer.none, child: Text('Sin Fertilizante')),
                      DropdownMenuItem(value: Fertilizer.basicSpeedGro, child: Text('Speed-Gro (10%)')),
                      DropdownMenuItem(value: Fertilizer.deluxeSpeedGro, child: Text('Deluxe Speed-Gro (15%)')),
                      DropdownMenuItem(value: Fertilizer.hyperSpeedGro, child: Text('Hyper Speed-Gro (25%)')),
                    ],
                    onChanged: (v) => setState(() => _fertilizer = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<ProcessingMethod>(
                    initialValue: _method,
                    decoration: const InputDecoration(labelText: 'Procesamiento', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: ProcessingMethod.raw, child: Text('Venta Directa')),
                      DropdownMenuItem(value: ProcessingMethod.jar, child: Text('Conservas')),
                      DropdownMenuItem(value: ProcessingMethod.keg, child: Text('Barril')),
                      DropdownMenuItem(value: ProcessingMethod.dehydrator, child: Text('Deshidratadora')),
                    ],
                    onChanged: (v) => setState(() => _method = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final foundCrop = widget.allCrops.firstWhere(
                    (c) => c.name == _selectedCropName,
                    orElse: () => widget.allCrops.first,
                  );

                  final batch = PlantedCropBatch(
                    id: widget.existingBatch?.id,
                    cropId: foundCrop.id,
                    cropName: foundCrop.name,
                    season: _selectedSeason,
                    quantity: _quantity,
                    plantDay: _plantDay,
                    alreadyPlanted: _timingMode != 0,
                    daysUntilFirstHarvest: _daysUntilFirstHarvest,
                    exactFirstHarvestDay: _timingMode == 2 ? _exactFirstHarvestDay : null,
                    fertilizer: _fertilizer,
                    processingMethod: _method,
                  );

                  if (isEditing) {
                    widget.plantedProvider.updateBatch(batch);
                  } else {
                    widget.plantedProvider.addBatch(batch);
                  }

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Guardar Cambios' : 'Guardar Lote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StardewColors.emeraldGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
