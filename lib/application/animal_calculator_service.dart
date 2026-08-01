/// Modelo de datos de un animal de granja de Stardew Valley.
class AnimalModel {
  final String id;
  final String name;
  final String building; // Gallinero / Establo
  final double cost;
  final String baseProduct;
  final double baseProductPrice;
  final String processedProduct;
  final double processedProductPrice;
  final int daysToProduce;

  const AnimalModel({
    required this.id,
    required this.name,
    required this.building,
    required this.cost,
    required this.baseProduct,
    required this.baseProductPrice,
    required this.processedProduct,
    required this.processedProductPrice,
    required this.daysToProduce,
  });
}

/// Servicio de cálculo de rentabilidad para ganadería y productos artesanales de animales.
class AnimalCalculatorService {
  static const List<AnimalModel> defaultAnimals = [
    AnimalModel(
      id: 'chicken',
      name: 'Gallina',
      building: 'Gallinero',
      cost: 800,
      baseProduct: 'Huevo',
      baseProductPrice: 50,
      processedProduct: 'Mayonesa',
      processedProductPrice: 190,
      daysToProduce: 1,
    ),
    AnimalModel(
      id: 'duck',
      name: 'Pato',
      building: 'Gallinero grande',
      cost: 1200,
      baseProduct: 'Huevo de pato',
      baseProductPrice: 95,
      processedProduct: 'Mayonesa de pato',
      processedProductPrice: 375,
      daysToProduce: 2,
    ),
    AnimalModel(
      id: 'cow',
      name: 'Vaca',
      building: 'Establo',
      cost: 1500,
      baseProduct: 'Leche',
      baseProductPrice: 125,
      processedProduct: 'Queso',
      processedProductPrice: 230,
      daysToProduce: 1,
    ),
    AnimalModel(
      id: 'goat',
      name: 'Cabra',
      building: 'Establo grande',
      cost: 4000,
      baseProduct: 'Leche de cabra',
      baseProductPrice: 225,
      processedProduct: 'Queso de cabra',
      processedProductPrice: 400,
      daysToProduce: 2,
    ),
    AnimalModel(
      id: 'pig',
      name: 'Cerdo',
      building: 'Establo de lujo',
      cost: 16000,
      baseProduct: 'Trufa',
      baseProductPrice: 625,
      processedProduct: 'Aceite de Trufa',
      processedProductPrice: 1065,
      daysToProduce: 1,
    ),
    AnimalModel(
      id: 'rabbit',
      name: 'Conejo',
      building: 'Gallinero de lujo',
      cost: 8000,
      baseProduct: 'Lana',
      baseProductPrice: 340,
      processedProduct: 'Tela',
      processedProductPrice: 470,
      daysToProduce: 4,
    ),
    AnimalModel(
      id: 'dinosaur',
      name: 'Dinosaurio',
      building: 'Gallinero de lujo',
      cost: 0,
      baseProduct: 'Huevo de dinosaurio',
      baseProductPrice: 350,
      processedProduct: 'Mayonesa de dinosaurio',
      processedProductPrice: 800,
      daysToProduce: 7,
    ),
    AnimalModel(
      id: 'ostrich',
      name: 'Avestruz',
      building: 'Establo de lujo',
      cost: 0,
      baseProduct: 'Huevo de avestruz',
      baseProductPrice: 600,
      processedProduct: 'Mayonesa (x10)',
      processedProductPrice: 1900,
      daysToProduce: 7,
    ),
  ];

  /// Calcula la ganancia diaria por animal según el número de animales, profesiones y procesamiento.
  static double calculateDailyProfit({
    required AnimalModel animal,
    required int count,
    required bool isRancher, // +20% a productos animales crudos
    required bool isArtisan, // +40% a productos procesados
    required bool isGatherer, // +20% a trufas (recolección)
    required bool processProducts, // Si transforma en queso, mayonesa, etc.
  }) {
    final seasonDays = 28;
    double unitPrice = processProducts ? animal.processedProductPrice : animal.baseProductPrice;

    if (processProducts && isArtisan) {
      unitPrice *= 1.40;
    } else if (!processProducts && isRancher && animal.id != 'pig') {
      unitPrice *= 1.20;
    } else if (!processProducts && isGatherer && animal.id == 'pig') {
      unitPrice *= 1.20;
    }

    final totalItemsPerSeason = (seasonDays / animal.daysToProduce).floor() * count;
    final totalRevenue = totalItemsPerSeason * unitPrice;
    return totalRevenue / seasonDays;
  }
}
