import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/crop_calculator_service.dart';
import '../models/crop_model.dart';
import '../providers/app_state_provider.dart';
import '../providers/crop_provider.dart';
import '../providers/mod_provider.dart';
import '../providers/save_provider.dart';
import '../theme/stardew_theme.dart';
import 'crop_calculator/animal_tab.dart';
import 'crop_calculator/calculator_tab.dart';
import 'crop_calculator/day_by_day_tab.dart';
import 'crop_calculator/pipeline_tab.dart';
import 'crop_calculator/planted_crops_tab.dart';

/// ─────────────────────────────────────────────────────────
///  VISTA PRINCIPAL — SIMULADOR DE PRODUCCIÓN AGRÍCOLA
/// ─────────────────────────────────────────────────────────
/// Coordina el estado de los controles y delega la renderización
/// de cada pestaña a sus respectivos widgets especializados:
/// - [CalculatorTab] (Pestaña 1: Configuración, Gráfica y Ranking)
/// - [PipelineTab] (Pestaña 2: Simulación de Barriles/Envases y Gantt)
/// - [DayByDayTab] (Pestaña 3: Flujo de caja día a día)
/// - [PlantedCropsTab] (Pestaña 4: Control individual de parcelas plantadas)
class CropCalculatorView extends StatefulWidget {
  const CropCalculatorView({super.key});

  @override
  State<CropCalculatorView> createState() => _CropCalculatorViewState();
}

class _CropCalculatorViewState extends State<CropCalculatorView>
    with SingleTickerProviderStateMixin {
  // ── Estado de controles ─────────────────────────────────
  String _selectedSeason = 'Primavera';
  Fertilizer _selectedFertilizer = Fertilizer.none;
  ProcessingMethod _selectedMethod = ProcessingMethod.keg;
  bool _isAgriculturist = false;
  bool _isTiller = false;
  bool _isArtisan = true;
  int _plantDay = 1;
  int _cropQuantity = 10;
  bool _alreadyPlanted = false;
  int _daysUntilFirstHarvest = 5;

  // ── Pipeline ────────────────────────────────────────────
  int _equipmentCount = 10;

  // ── Cultivo seleccionado para graficar ──────────────────
  CropModel? _selectedCrop;

  // ── Tab controller ─────────────────────────────────────
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────
  String get _processingLabel {
    switch (_selectedMethod) {
      case ProcessingMethod.raw:
        return 'Venta Directa';
      case ProcessingMethod.jar:
        return 'Envases / Conservas';
      case ProcessingMethod.keg:
        return 'Barriles (Vino/Jugo)';
      case ProcessingMethod.dehydrator:
        return 'Deshidratadora';
    }
  }

  String get _equipmentName {
    switch (_selectedMethod) {
      case ProcessingMethod.jar:
        return 'Envases';
      case ProcessingMethod.keg:
        return 'Barriles';
      case ProcessingMethod.dehydrator:
        return 'Deshidratadoras';
      default:
        return 'Equipos';
    }
  }
  List<CropModel> _getSeasonCrops(AppStateProvider provider) {
    final cropProvider = Provider.of<CropProvider>(context);
    final modProvider = Provider.of<ModProvider>(context);
    final saveProvider = Provider.of<SaveProvider>(context);
    final isModsEnabled = modProvider.isModsEnabledForFarm(saveProvider.activeFarmKey);

    final availableCrops = cropProvider.getCropsForFarm(includeModCrops: isModsEnabled);

    final crops = availableCrops.where((c) {
      if (_selectedSeason == 'Invernadero') return true;
      return c.season.toLowerCase() == _selectedSeason.toLowerCase() ||
          c.season == 'Invernadero';
    }).toList();

    // Pase único O(N) de cálculo de ganancia diaria para evitar simulaciones redundantes
    final profits = <String, double>{};
    for (final c in crops) {
      profits[c.id] = CropCalculatorService.calculateDailyProfit(
        c,
        plantDay: _plantDay,
        fertilizer: _selectedFertilizer,
        isAgriculturist: _isAgriculturist,
        isTiller: _isTiller,
        isArtisan: _isArtisan,
        method: _selectedMethod,
        cropQuantity: _cropQuantity,
        alreadyPlanted: _alreadyPlanted,
        daysUntilFirstHarvest: _daysUntilFirstHarvest,
      );
    }

    // Ordenación ultra rápida usando mapa precalculado
    crops.sort((a, b) => (profits[b.id] ?? 0).compareTo(profits[a.id] ?? 0));
    return crops;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final seasonCrops = _getSeasonCrops(provider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    // Selecciona el primer cultivo por defecto si no hay ninguno seleccionado
    if (_selectedCrop == null && seasonCrops.isNotEmpty) {
      _selectedCrop = seasonCrops.first;
    }

    return Column(
      children: [
        // Encabezado + Tabs
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          color: StardewColors.cardBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌾 Simulador de Producción Agrícola',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: isMobile ? 16 : 22,
                      color: StardewColors.primaryGold,
                    ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Calcula rentabilidad, simula pipeline de procesamiento y gestiona tus lotes plantados.',
                style: TextStyle(color: StardewColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                labelColor: StardewColors.primaryGold,
                unselectedLabelColor: StardewColors.textMuted,
                indicatorColor: StardewColors.primaryGold,
                tabs: const [
                  Tab(text: '📊 Cultivos'),
                  Tab(text: '🐮 Ganadería'),
                  Tab(text: '🛢️ Pipeline'),
                  Tab(text: '📅 Día a Día'),
                  Tab(text: '🌱 Mis Parcelas'),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              CalculatorTab(
                seasonCrops: seasonCrops,
                selectedCrop: _selectedCrop,
                selectedSeason: _selectedSeason,
                selectedFertilizer: _selectedFertilizer,
                selectedMethod: _selectedMethod,
                isAgriculturist: _isAgriculturist,
                isTiller: _isTiller,
                isArtisan: _isArtisan,
                plantDay: _plantDay,
                cropQuantity: _cropQuantity,
                alreadyPlanted: _alreadyPlanted,
                daysUntilFirstHarvest: _daysUntilFirstHarvest,
                processingLabel: _processingLabel,
                provider: provider,
                onCropSelected: (c) => setState(() => _selectedCrop = c),
                onSeasonChanged: (s) => setState(() => _selectedSeason = s),
                onFertilizerChanged: (f) => setState(() => _selectedFertilizer = f),
                onMethodChanged: (m) => setState(() => _selectedMethod = m),
                onAgriculturistChanged: (v) => setState(() => _isAgriculturist = v),
                onTillerChanged: (v) => setState(() => _isTiller = v),
                onArtisanChanged: (v) => setState(() => _isArtisan = v),
                onPlantDayChanged: (d) => setState(() => _plantDay = d),
                onCropQuantityChanged: (q) => setState(() => _cropQuantity = q),
                onAlreadyPlantedChanged: (v) => setState(() => _alreadyPlanted = v),
                onDaysUntilFirstHarvestChanged: (d) => setState(() => _daysUntilFirstHarvest = d),
              ),
              const AnimalTab(),
              PipelineTab(
                selectedCrop: _selectedCrop,
                plantDay: _plantDay,
                selectedFertilizer: _selectedFertilizer,
                isAgriculturist: _isAgriculturist,
                isTiller: _isTiller,
                isArtisan: _isArtisan,
                selectedMethod: _selectedMethod,
                cropQuantity: _cropQuantity,
                equipmentCount: _equipmentCount,
                alreadyPlanted: _alreadyPlanted,
                daysUntilFirstHarvest: _daysUntilFirstHarvest,
                equipmentName: _equipmentName,
                onEquipmentCountChanged: (c) => setState(() => _equipmentCount = c),
                onGoToCalculator: () => _tabController.animateTo(0),
              ),
              DayByDayTab(
                selectedCrop: _selectedCrop,
                plantDay: _plantDay,
                selectedFertilizer: _selectedFertilizer,
                isAgriculturist: _isAgriculturist,
                isTiller: _isTiller,
                isArtisan: _isArtisan,
                selectedMethod: _selectedMethod,
                cropQuantity: _cropQuantity,
                alreadyPlanted: _alreadyPlanted,
                daysUntilFirstHarvest: _daysUntilFirstHarvest,
              ),
              const PlantedCropsTab(),
            ],
          ),
        ),
      ],
    );
  }
}
