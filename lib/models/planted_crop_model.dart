import '../models/crop_model.dart';

/// Modelo de un lote de cultivo plantado individualmente en la granja.
class PlantedCropBatch {
  final int? id;
  final String cropId;
  final String cropName;
  final String season;
  final int quantity;
  final int plantDay;
  final bool alreadyPlanted;
  final int daysUntilFirstHarvest;
  final int? exactFirstHarvestDay;
  final Fertilizer fertilizer;
  final ProcessingMethod processingMethod;
  final String notes;
  final String farmKey;

  const PlantedCropBatch({
    this.id,
    required this.cropId,
    required this.cropName,
    required this.season,
    required this.quantity,
    required this.plantDay,
    this.alreadyPlanted = false,
    this.daysUntilFirstHarvest = 0,
    this.exactFirstHarvestDay,
    this.fertilizer = Fertilizer.none,
    this.processingMethod = ProcessingMethod.keg,
    this.notes = '',
    this.farmKey = 'global',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cropId': cropId,
      'cropName': cropName,
      'season': season,
      'quantity': quantity,
      'plantDay': plantDay,
      'alreadyPlanted': alreadyPlanted ? 1 : 0,
      'daysUntilFirstHarvest': daysUntilFirstHarvest,
      'exactFirstHarvestDay': exactFirstHarvestDay,
      'fertilizer': fertilizer.name,
      'processingMethod': processingMethod.name,
      'notes': notes,
      'farmKey': farmKey,
    };
  }

  factory PlantedCropBatch.fromMap(Map<String, dynamic> map) {
    return PlantedCropBatch(
      id: map['id'] as int?,
      cropId: map['cropId'] as String? ?? '',
      cropName: map['cropName'] as String? ?? 'Cultivo',
      season: map['season'] as String? ?? 'Primavera',
      quantity: map['quantity'] as int? ?? 10,
      plantDay: map['plantDay'] as int? ?? 1,
      alreadyPlanted: (map['alreadyPlanted'] as int? ?? 0) == 1,
      daysUntilFirstHarvest: map['daysUntilFirstHarvest'] as int? ?? 0,
      exactFirstHarvestDay: map['exactFirstHarvestDay'] as int?,
      fertilizer: Fertilizer.values.firstWhere(
        (e) => e.name == map['fertilizer'],
        orElse: () => Fertilizer.none,
      ),
      processingMethod: ProcessingMethod.values.firstWhere(
        (e) => e.name == map['processingMethod'],
        orElse: () => ProcessingMethod.keg,
      ),
      notes: map['notes'] as String? ?? '',
      farmKey: map['farmKey'] as String? ?? 'global',
    );
  }

  PlantedCropBatch copyWith({
    int? id,
    String? cropId,
    String? cropName,
    String? season,
    int? quantity,
    int? plantDay,
    bool? alreadyPlanted,
    int? daysUntilFirstHarvest,
    int? exactFirstHarvestDay,
    Fertilizer? fertilizer,
    ProcessingMethod? processingMethod,
    String? notes,
    String? farmKey,
  }) {
    return PlantedCropBatch(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      season: season ?? this.season,
      quantity: quantity ?? this.quantity,
      plantDay: plantDay ?? this.plantDay,
      alreadyPlanted: alreadyPlanted ?? this.alreadyPlanted,
      daysUntilFirstHarvest: daysUntilFirstHarvest ?? this.daysUntilFirstHarvest,
      exactFirstHarvestDay: exactFirstHarvestDay ?? this.exactFirstHarvestDay,
      fertilizer: fertilizer ?? this.fertilizer,
      processingMethod: processingMethod ?? this.processingMethod,
      notes: notes ?? this.notes,
      farmKey: farmKey ?? this.farmKey,
    );
  }
}
