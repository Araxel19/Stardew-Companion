import 'dart:io';
import 'package:xml/xml.dart';
import '../core/constants/stardew_constants.dart';
import '../models/save_data.dart';
import '../models/villager_friendship.dart';

class XmlParserService {
  static Future<StardewSaveData> parseSaveFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('El archivo de guardado no existe en la ruta: $filePath');
    }

    final xmlString = await file.readAsString();
    final document = XmlDocument.parse(xmlString);

    // Buscar el nodo principal player (o Farmer en multijugador)
    final farmerNode = document.findAllElements('player').firstOrNull ??
        document.findAllElements('Farmer').firstOrNull ??
        document.rootElement;

    // 1. Información Básica del Granjero
    final name = _getXmlText(farmerNode, 'name') ?? 'Granjero';
    final farmName = _getXmlText(farmerNode, 'farmName') ?? 'Granja';
    final money = int.tryParse(_getXmlText(farmerNode, 'money') ?? '0') ?? 0;
    final totalEarnings = int.tryParse(_getXmlText(farmerNode, 'totalMoneyEarned') ?? '0') ?? 0;

    final gameYear = int.tryParse(document.findAllElements('year').firstOrNull?.innerText ?? '1') ?? 1;
    final gameSeason = document.findAllElements('currentSeason').firstOrNull?.innerText ?? 'Primavera';
    final gameDay = int.tryParse(document.findAllElements('dayOfMonth').firstOrNull?.innerText ?? '1') ?? 1;
    final milliseconds = double.tryParse(_getXmlText(farmerNode, 'millisecondsPlayed') ?? '0') ?? 0;
    final playtimeHours = milliseconds / (1000 * 60 * 60);

    // 2. Recetas de Cocina
    final Map<String, int> cookingRecipes = {};
    final cookingNode = farmerNode.findElements('cookingRecipes').firstOrNull ??
        document.findAllElements('cookingRecipes').firstOrNull;
    if (cookingNode != null) {
      for (var item in cookingNode.findElements('item')) {
        final key = _extractItemKey(item);
        final val = _extractItemValue(item);
        if (key.isNotEmpty) cookingRecipes[key] = val;
      }
    }

    // 3. Recetas de Fabricación (Crafting)
    final Map<String, int> craftingRecipes = {};
    final craftingNode = farmerNode.findElements('craftingRecipes').firstOrNull ??
        document.findAllElements('craftingRecipes').firstOrNull;
    if (craftingNode != null) {
      for (var item in craftingNode.findElements('item')) {
        final key = _extractItemKey(item);
        final val = _extractItemValue(item);
        if (key.isNotEmpty) craftingRecipes[key] = val;
      }
    }

    // 4. Amistad con Aldeanos (Friendships)
    final Map<String, VillagerFriendship> friendships = {};
    final friendshipNode = farmerNode.findElements('friendshipData').firstOrNull ??
        document.findAllElements('friendshipData').firstOrNull;
    if (friendshipNode != null) {
      for (var item in friendshipNode.findElements('item')) {
        final key = _extractItemKey(item);
        final valNode = item.findElements('value').firstOrNull;
        final pointsStr = valNode?.findAllElements('Points').firstOrNull?.innerText ??
            valNode?.innerText ?? '0';
        final points = int.tryParse(pointsStr.trim()) ?? 0;
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
    final fishNode = farmerNode.findElements('fishCaught').firstOrNull ??
        document.findAllElements('fishCaught').firstOrNull;
    if (fishNode != null) {
      for (var item in fishNode.findElements('item')) {
        final key = _extractItemKey(item);
        final val = _extractItemValue(item);
        if (key.isNotEmpty) fishCaught[key] = val > 0 ? val : 1;
      }
    }

    // 6. Envíos (Basic Shipped)
    final Map<String, int> shippingItems = {};
    final shipNode = farmerNode.findElements('basicShipped').firstOrNull ??
        document.findAllElements('basicShipped').firstOrNull;
    if (shipNode != null) {
      for (var item in shipNode.findElements('item')) {
        final key = _extractItemKey(item);
        final val = _extractItemValue(item);
        if (key.isNotEmpty) shippingItems[key] = val;
      }
    }

    // 7. Detección de Mods en XML
    final Set<String> detectedMods = {};
    final modDataNode = farmerNode.findElements('modData').firstOrNull;
    if (modDataNode != null) {
      for (var item in modDataNode.findElements('item')) {
        final keyNode = item.findElements('key').firstOrNull ?? item.findElements('string').firstOrNull;
        if (keyNode != null) {
          final keyText = keyNode.innerText.trim();
          if (keyText.isNotEmpty) {
            String cleanModName = keyText;
            if (cleanModName.contains('.')) {
              cleanModName = cleanModName.split('.').last;
            }
            if (cleanModName.contains('/')) {
              cleanModName = cleanModName.split('/').last;
            }
            detectedMods.add(cleanModName);
          }
        }
      }
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

  static String? _getXmlText(XmlElement parent, String tag) {
    return parent.findElements(tag).firstOrNull?.innerText ??
        parent.findAllElements(tag).firstOrNull?.innerText;
  }

  static String _extractItemKey(XmlElement item) {
    final keyNode = item.findElements('key').firstOrNull;
    if (keyNode == null) return '';
    final strNode = keyNode.findElements('string').firstOrNull ?? keyNode.findAllElements('string').firstOrNull;
    return (strNode?.innerText ?? keyNode.innerText).trim();
  }

  static int _extractItemValue(XmlElement item) {
    final valNode = item.findElements('value').firstOrNull;
    if (valNode == null) return 0;
    final intNode = valNode.findElements('int').firstOrNull ?? valNode.findAllElements('int').firstOrNull;
    final text = (intNode?.innerText ?? valNode.innerText).trim();
    return int.tryParse(text) ?? 0;
  }

  static bool _isModdedVillager(String name) {
    return !StardewConstants.vanillaVillagers.contains(name);
  }
}
