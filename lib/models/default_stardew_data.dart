import 'crop_model.dart';

class DefaultStardewData {
  static List<CropModel> get defaultCrops => [
    // Primavera (Spring)
    CropModel(id: 'parsnip', name: 'Chirivía (Parsnip)', season: 'Primavera', seedCost: 20, baseSellPrice: 35, daysToGrow: 4),
    CropModel(id: 'cauliflower', name: 'Coliflor (Cauliflower)', season: 'Primavera', seedCost: 80, baseSellPrice: 175, daysToGrow: 12),
    CropModel(id: 'potato', name: 'Patata (Potato)', season: 'Primavera', seedCost: 50, baseSellPrice: 80, daysToGrow: 6),
    CropModel(id: 'strawberry', name: 'Fresa (Strawberry)', season: 'Primavera', seedCost: 100, baseSellPrice: 120, daysToGrow: 8, regrowDays: 4),
    CropModel(id: 'rhubarb', name: 'Ruibarbo (Rhubarb)', season: 'Primavera', seedCost: 100, baseSellPrice: 220, daysToGrow: 13),
    CropModel(id: 'kale', name: 'Col rizada (Kale)', season: 'Primavera', seedCost: 70, baseSellPrice: 110, daysToGrow: 6),
    CropModel(id: 'green_bean', name: 'Judía verde (Green Bean)', season: 'Primavera', seedCost: 60, baseSellPrice: 40, daysToGrow: 10, regrowDays: 3),

    // Verano (Summer)
    CropModel(id: 'starfruit', name: 'Fruta Estelar (Starfruit)', season: 'Verano', seedCost: 400, baseSellPrice: 750, daysToGrow: 13),
    CropModel(id: 'blueberry', name: 'Arándano (Blueberry)', season: 'Verano', seedCost: 80, baseSellPrice: 50, daysToGrow: 13, regrowDays: 4),
    CropModel(id: 'melon', name: 'Melón (Melon)', season: 'Verano', seedCost: 80, baseSellPrice: 250, daysToGrow: 12),
    CropModel(id: 'hops', name: 'Lúpulo (Hops)', season: 'Verano', seedCost: 60, baseSellPrice: 25, daysToGrow: 11, regrowDays: 1),
    CropModel(id: 'red_cabbage', name: 'Lombarda (Red Cabbage)', season: 'Verano', seedCost: 100, baseSellPrice: 260, daysToGrow: 9),
    CropModel(id: 'tomato', name: 'Tomate (Tomato)', season: 'Verano', seedCost: 50, baseSellPrice: 60, daysToGrow: 11, regrowDays: 4),

    // Otoño (Fall)
    CropModel(id: 'pumpkin', name: 'Calabaza (Pumpkin)', season: 'Otoño', seedCost: 100, baseSellPrice: 320, daysToGrow: 13),
    CropModel(id: 'cranberries', name: 'Arándanos rojos (Cranberries)', season: 'Otoño', seedCost: 240, baseSellPrice: 75, daysToGrow: 7, regrowDays: 5),
    CropModel(id: 'sweet_gem_berry', name: 'Baya Dulce de Gema', season: 'Otoño', seedCost: 1000, baseSellPrice: 3000, daysToGrow: 24),
    CropModel(id: 'ancient_fruit', name: 'Fruta Antigua (Ancient Fruit)', season: 'Invernadero', seedCost: 500, baseSellPrice: 550, daysToGrow: 28, regrowDays: 7),
    CropModel(id: 'grape', name: 'Uva (Grape)', season: 'Otoño', seedCost: 60, baseSellPrice: 80, daysToGrow: 10, regrowDays: 3),

    // Mods populares (Ridgeside Village / SVE)
    CropModel(id: 'rsv_ridge_cherry', name: 'Cereza de la Cresta (RSV)', season: 'Primavera', seedCost: 150, baseSellPrice: 280, daysToGrow: 8, regrowDays: 3, sourceMod: 'Ridgeside Village'),
    CropModel(id: 'rsv_highland_berry', name: 'Baya de la Montaña (RSV)', season: 'Verano', seedCost: 200, baseSellPrice: 420, daysToGrow: 10, regrowDays: 4, sourceMod: 'Ridgeside Village'),
    CropModel(id: 'sve_salvia', name: 'Salvia Silvestre (SVE)', season: 'Otoño', seedCost: 120, baseSellPrice: 310, daysToGrow: 9, sourceMod: 'Stardew Valley Expanded'),
  ];

  // Cumpleaños y eventos por estación (28 días)
  static Map<String, List<Map<String, String>>> getSeasonEvents(String season) {
    switch (season.toLowerCase()) {
      case 'primavera':
      case 'spring':
        return {
          '1': [{'type': 'system', 'title': '¡Primer día de Primavera!'}],
          '4': [{'type': 'birthday', 'title': 'Cumpleaños de Kent'}],
          '7': [{'type': 'birthday', 'title': 'Cumpleaños de Lewis'}],
          '10': [{'type': 'birthday', 'title': 'Cumpleaños de Vincent'}],
          '13': [{'type': 'festival', 'title': 'Festival del Huevo (Egg Festival)'}],
          '14': [{'type': 'birthday', 'title': 'Cumpleaños de Haley'}],
          '18': [{'type': 'birthday', 'title': 'Cumpleaños de Pam'}],
          '20': [{'type': 'birthday', 'title': 'Cumpleaños de Shane'}],
          '24': [{'type': 'festival', 'title': 'Danza de las Medusas de San Juan'}],
          '26': [{'type': 'birthday', 'title': 'Cumpleaños de Pierre'}],
          '27': [{'type': 'birthday', 'title': 'Cumpleaños de Emily'}],
        };
      case 'verano':
      case 'summer':
        return {
          '4': [{'type': 'birthday', 'title': 'Cumpleaños de Jas'}],
          '8': [{'type': 'birthday', 'title': 'Cumpleaños de Gus'}],
          '11': [{'type': 'festival', 'title': 'Luau de la Playa'}],
          '13': [{'type': 'birthday', 'title': 'Cumpleaños de Maru'}],
          '17': [{'type': 'birthday', 'title': 'Cumpleaños de Sam'}],
          '28': [{'type': 'festival', 'title': 'Danza de las Medusas Luciosas'}],
        };
      case 'otoño':
      case 'fall':
        return {
          '5': [{'type': 'birthday', 'title': 'Cumpleaños de Elliott'}],
          '16': [{'type': 'festival', 'title': 'Feria de Stardew Valley'}],
          '27': [{'type': 'festival', 'title': 'Víspera de los Espíritus'}],
        };
      default:
        return {
          '8': [{'type': 'festival', 'title': 'Festival del Hielo'}],
          '25': [{'type': 'festival', 'title': 'Fiesta de la Estrellas de Invierno'}],
        };
    }
  }
}
