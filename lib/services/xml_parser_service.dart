import 'dart:io';
import 'package:xml/xml.dart';
import '../models/save_data.dart';

class XmlParserService {
  static Future<StardewSaveData> parseSaveFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('El archivo de guardado no existe en la ruta: $filePath');
    }

    final xmlString = await file.readAsString();
    final document = XmlDocument.parse(xmlString);

    // Intentar buscar el nodo principal de Farmer o SaveGame
    final farmerNode = document.findAllElements('Farmer').firstOrNull ??
        document.findAllElements('player').firstOrNull ??
        document.rootElement;

    // 1. Información Básica del Granjero
    final name = farmerNode.findElements('name').firstOrNull?.innerText ?? 'Granjero';
    final farmName = farmerNode.findElements('farmName').firstOrNull?.innerText ?? 'Granja';
    final money = int.tryParse(farmerNode.findElements('money').firstOrNull?.innerText ?? '0') ?? 0;
    final totalEarnings = int.tryParse(farmerNode.findElements('totalMoneyEarned').firstOrNull?.innerText ?? '0') ?? 0;

    final gameYear = int.tryParse(document.findAllElements('year').firstOrNull?.innerText ?? '1') ?? 1;
    final gameSeason = document.findAllElements('currentSeason').firstOrNull?.innerText ?? 'Primavera';
    final gameDay = int.tryParse(document.findAllElements('dayOfMonth').firstOrNull?.innerText ?? '1') ?? 1;
    final milliseconds = double.tryParse(farmerNode.findElements('millisecondsPlayed').firstOrNull?.innerText ?? '0') ?? 0;
    final playtimeHours = milliseconds / (1000 * 60 * 60);

    // 2. Recetas de Cocina
    final Map<String, int> cookingRecipes = {};
    final cookingNode = farmerNode.findElements('cookingRecipes').firstOrNull;
    if (cookingNode != null) {
      for (var item in cookingNode.findElements('item')) {
        final key = item.findElements('key').firstOrNull?.innerText ?? '';
        final val = int.tryParse(item.findElements('value').firstOrNull?.innerText ?? '0') ?? 0;
        if (key.isNotEmpty) cookingRecipes[key] = val;
      }
    }

    // 3. Recetas de Fabricación (Crafting)
    final Map<String, int> craftingRecipes = {};
    final craftingNode = farmerNode.findElements('craftingRecipes').firstOrNull;
    if (craftingNode != null) {
      for (var item in craftingNode.findElements('item')) {
        final key = item.findElements('key').firstOrNull?.innerText ?? '';
        final val = int.tryParse(item.findElements('value').firstOrNull?.innerText ?? '0') ?? 0;
        if (key.isNotEmpty) craftingRecipes[key] = val;
      }
    }

    // 4. Amistad con Aldeanos (Friendships)
    final Map<String, VillagerFriendship> friendships = {};
    final friendshipNode = farmerNode.findElements('friendshipData').firstOrNull;
    if (friendshipNode != null) {
      for (var item in friendshipNode.findElements('item')) {
        final key = item.findElements('key').firstOrNull?.innerText ?? '';
        final valNode = item.findElements('value').firstOrNull;
        final pointsNode = valNode?.findElements('FriendshipData').firstOrNull?.findElements('Points').firstOrNull ??
            valNode?.findElements('Points').firstOrNull;
        final points = int.tryParse(pointsNode?.innerText ?? '0') ?? 0;
        final hearts = points ~/ 250;

        if (key.isNotEmpty) {
          friendships[key] = VillagerFriendship(
            name: key,
            points: points,
            hearts: hearts,
            isModded: _isModdedVillager(key),
          );
        }
      }
    }

    // 5. Peces Atrapados
    final Map<String, int> fishCaught = {};
    final fishNode = farmerNode.findElements('fishCaught').firstOrNull;
    if (fishNode != null) {
      for (var item in fishNode.findElements('item')) {
        final key = item.findElements('key').firstOrNull?.innerText ?? '';
        final countStr = item.findElements('value').firstOrNull?.findElements('int').firstOrNull?.innerText ?? '1';
        final count = int.tryParse(countStr) ?? 1;
        if (key.isNotEmpty) fishCaught[key] = count;
      }
    }

    // 6. Envíos (Basic Shipped)
    final Map<String, int> shippingItems = {};
    final shipNode = farmerNode.findElements('basicShipped').firstOrNull;
    if (shipNode != null) {
      for (var item in shipNode.findElements('item')) {
        final key = item.findElements('key').firstOrNull?.innerText ?? '';
        final val = int.tryParse(item.findElements('value').firstOrNull?.innerText ?? '0') ?? 0;
        if (key.isNotEmpty) shippingItems[key] = val;
      }
    }

    // 7. Detección de Mods
    final Set<String> detectedMods = {};
    final modDataNode = farmerNode.findElements('modData').firstOrNull;
    if (modDataNode != null) {
      final xmlText = modDataNode.innerText;
      if (xmlText.contains('RSV') || xmlText.contains('Ridgeside')) detectedMods.add('Ridgeside Village');
      if (xmlText.contains('SVE') || xmlText.contains('Expanded')) detectedMods.add('Stardew Valley Expanded');
      if (xmlText.contains('SpaceCore')) detectedMods.add('SpaceCore Framework');
      if (xmlText.contains('DynamicReflections')) detectedMods.add('Dynamic Reflections');
    }

    // 8. Edificios & Perfección
    bool hasGoldenClock = xmlString.contains('Gold Clock') || xmlString.contains('Golden Clock');
    int obelisksCount = 0;
    if (xmlString.contains('Earth Obelisk')) obelisksCount++;
    if (xmlString.contains('Water Obelisk')) obelisksCount++;
    if (xmlString.contains('Desert Obelisk')) obelisksCount++;
    if (xmlString.contains('Island Obelisk')) obelisksCount++;

    return StardewSaveData(
      farmerName: name,
      farmName: farmName,
      currentMoney: money,
      totalEarnings: totalEarnings,
      gameYear: gameYear,
      gameSeason: gameSeason,
      gameDay: gameDay,
      playtimeHours: playtimeHours,
      cookingRecipes: cookingRecipes,
      craftingRecipes: craftingRecipes,
      fishCaught: fishCaught,
      shippingItems: shippingItems,
      friendships: friendships,
      monsterKills: {},
      stardrops: ['Mine', 'Fair', 'Krobus', 'OldMasterCannoli', 'Spouse'],
      hasGoldenClock: hasGoldenClock,
      obelisksCount: obelisksCount,
      detectedMods: detectedMods,
    );
  }

  static bool _isModdedVillager(String name) {
    const vanillaVillagers = {
      'Abigail', 'Alex', 'Caroline', 'Clint', 'Demetrius', 'Dwarf', 'Elliott',
      'Emily', 'Evelyn', 'George', 'Gus', 'Haley', 'Harvey', 'Jas', 'Jodi',
      'Kent', 'Krobus', 'Leah', 'Leo', 'Lewis', 'Linus', 'Marnie', 'Maru',
      'Pam', 'Penny', 'Pierre', 'Robin', 'Sam', 'Sebastian', 'Shane', 'Willy', 'Wizard'
    };
    return !vanillaVillagers.contains(name);
  }
}
