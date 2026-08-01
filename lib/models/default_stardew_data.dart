import 'crop_model.dart';
import 'villager_model.dart';

/// Datos estáticos de Stardew Valley vanilla + mods populares.
///
/// Esta clase es un **registro de datos** — solo listas inmutables.
/// La lógica de consulta y montaje del calendario vive en [CalendarService].
class DefaultStardewData {
  DefaultStardewData._(); // no instanciable

  // ─────────────────────────────────────────────────────────
  //  ALDEANOS — Cumpleaños y Regalos Favoritos
  // ─────────────────────────────────────────────────────────

  static const List<VillagerModel> defaultVillagers = [
    // --- PRIMAVERA ---
    VillagerModel(id: 'willy', name: 'Willy', season: 'Primavera', day: 2, isDatable: false, lovedGifts: ['Bagre (Catfish)', 'Diamante', 'Barra de Iridio', 'Hidromiel (Mead)', 'Pulpo (Octopus)', 'Calabaza', 'Pepino de Mar', 'Esturión']),
    VillagerModel(id: 'kent', name: 'Kent', season: 'Primavera', day: 4, isDatable: false, lovedGifts: ['Risotto de Helecho', 'Avellanas Tostadas']),
    VillagerModel(id: 'lewis', name: 'Lewis', season: 'Primavera', day: 7, isDatable: false, lovedGifts: ['Botín de Otoño', 'Ñames Glaseados', 'Té Verde', 'Chile Picante', 'Variado de Verduras']),
    VillagerModel(id: 'vincent', name: 'Vincent', season: 'Primavera', day: 10, isDatable: false, lovedGifts: ['Caramelo de Arándanos', 'Uva', 'Pastel de Rosa']),
    VillagerModel(id: 'haley', name: 'Haley', season: 'Primavera', day: 14, isDatable: true, lovedGifts: ['Coco', 'Ensalada de Frutas', 'Pastel Rosa (Pink Cake)', 'Girasol']),
    VillagerModel(id: 'pam', name: 'Pam', season: 'Primavera', day: 18, isDatable: false, lovedGifts: ['Cerveza', 'Fruto de Cactus', 'Ñames Glaseados', 'Hidromiel', 'Pale Ale', 'Chirivía', 'Sopa de Chirivía']),
    VillagerModel(id: 'shane', name: 'Shane', season: 'Primavera', day: 20, isDatable: true, lovedGifts: ['Cerveza', 'Chile Picante', 'Pimientos Rellenos', 'Pizza']),
    VillagerModel(id: 'pierre', name: 'Pierre', season: 'Primavera', day: 26, isDatable: false, lovedGifts: ['Calamar Frito']),
    VillagerModel(id: 'emily', name: 'Emily', season: 'Primavera', day: 27, isDatable: true, lovedGifts: ['Amatista', 'Aguamarina', 'Tela', 'Esmeralda', 'Jade', 'Rubí', 'Hamburguesa de Supervivencia', 'Topacio', 'Lana']),

    // --- VERANO ---
    VillagerModel(id: 'jas', name: 'Jas', season: 'Verano', day: 4, isDatable: false, lovedGifts: ['Rosa Hada', 'Pastel Rosa', 'Pudin de Ciruela']),
    VillagerModel(id: 'gus', name: 'Gus', season: 'Verano', day: 8, isDatable: false, lovedGifts: ['Diamante', 'Caracoles (Escargot)', 'Taco de Pescado', 'Naranja', 'Curry Tropical']),
    VillagerModel(id: 'maru', name: 'Maru', season: 'Verano', day: 10, isDatable: true, lovedGifts: ['Batería', 'Coliflor con Queso', 'Diamante', 'Barra de Oro', 'Barra de Iridio', 'Aperitivo de Minero', 'Pimientos Rellenos', 'Pastel de Ruibarbo', 'Fresa']),
    VillagerModel(id: 'alex', name: 'Alex', season: 'Verano', day: 13, isDatable: true, lovedGifts: ['Desayuno Completo', 'Cena de Salmón']),
    VillagerModel(id: 'sam', name: 'Sam', season: 'Verano', day: 17, isDatable: true, lovedGifts: ['Fruto de Cactus', 'Barra de Arce (Maple Bar)', 'Pizza', 'Ojo de Tigre']),
    VillagerModel(id: 'demetrius', name: 'Demetrius', season: 'Verano', day: 19, isDatable: false, lovedGifts: ['Estofado de Alubias', 'Helado', 'Pudin de Arroz', 'Fresa']),
    VillagerModel(id: 'dwarf', name: 'Enano (Dwarf)', season: 'Verano', day: 20, isDatable: false, lovedGifts: ['Amatista', 'Aguamarina', 'Esmeralda', 'Jade', 'Piedra Limón', 'Omnigeoda', 'Rubí', 'Topacio']),
    VillagerModel(id: 'elliott', name: 'Elliott', season: 'Verano', day: 24, isDatable: true, lovedGifts: ['Pasteles de Cangrejo', 'Pluma de Pato', 'Langosta', 'Granada', 'Tinta de Calamar', 'Sopa Tom Kha']),
    VillagerModel(id: 'leo', name: 'Leo', season: 'Verano', day: 26, isDatable: false, lovedGifts: ['Pluma de Pato', 'Mango', 'Huevo de Avestruz', 'Poi']),

    // --- OTOÑO ---
    // NOTA: Elliott fue eliminado de aquí (id: 'elliott_fall') — su cumpleaños es Verano 24.
    VillagerModel(id: 'penny', name: 'Penny', season: 'Otoño', day: 2, isDatable: true, lovedGifts: ['Diamante', 'Esmeralda', 'Melón', 'Amapola', 'Muffin de Amapola', 'Plato Rojo', 'Plato de Raíces', 'Pez Arena']),
    VillagerModel(id: 'jodi', name: 'Jodi', season: 'Otoño', day: 11, isDatable: false, lovedGifts: ['Pastel de Chocolate', 'Lubina Crujiente', 'Berenjena al Parmesano', 'Anguila Frita', 'Tortitas', 'Tartas de Ruibarbo', 'Variado de Verduras']),
    VillagerModel(id: 'abigail', name: 'Abigail', season: 'Otoño', day: 13, isDatable: true, lovedGifts: ['Amatista', 'Pudin de Plátano', 'Tarta de Moras', 'Pastel de Chocolate', 'Pez Globo', 'Calabaza', 'Anguila Picante']),
    VillagerModel(id: 'sandy', name: 'Sandy', season: 'Otoño', day: 15, isDatable: false, lovedGifts: ['Flor de Azafrán', 'Girasol', 'Dulce de Fruto de Cactus']),
    VillagerModel(id: 'marnie', name: 'Marnie', season: 'Otoño', day: 18, isDatable: false, lovedGifts: ['Almuerzo de Granjero', 'Pastel Rosa', 'Tarta de Calabaza', 'Diamante']),
    VillagerModel(id: 'robin', name: 'Robin', season: 'Otoño', day: 21, isDatable: false, lovedGifts: ['Queso de Cabra', 'Melocotón', 'Espaguetis']),
    VillagerModel(id: 'george', name: 'George', season: 'Otoño', day: 24, isDatable: false, lovedGifts: ['Seta Frita', 'Puerro']),

    // --- INVIERNO ---
    VillagerModel(id: 'linus', name: 'Linus', season: 'Invierno', day: 3, isDatable: false, lovedGifts: ['Tarta de Arándanos', 'Fruto de Cactus', 'Coco', 'Plato del Mar', 'Ñame']),
    VillagerModel(id: 'caroline', name: 'Caroline', season: 'Invierno', day: 7, isDatable: false, lovedGifts: ['Taco de Pescado', 'Té Verde', 'Comodín de Verano', 'Curry Tropical']),
    VillagerModel(id: 'sebastian', name: 'Sebastian', season: 'Invierno', day: 10, isDatable: true, lovedGifts: ['Lágrima Helada', 'Obsidiana', 'Sopa de Calabaza', 'Sashimi', 'Huevo Vacío']),
    VillagerModel(id: 'harvey', name: 'Harvey', season: 'Invierno', day: 14, isDatable: true, lovedGifts: ['Café', 'Encurtidos', 'Súper Comida', 'Aceite de Trufa', 'Vino']),
    VillagerModel(id: 'wizard', name: 'Mago (Wizard)', season: 'Invierno', day: 17, isDatable: false, lovedGifts: ['Libro de las Estrellas', 'Esencia Solar', 'Esencia Vacía', 'Seta Púrpura', 'Superpepino']),
    VillagerModel(id: 'evelyn', name: 'Evelyn', season: 'Invierno', day: 20, isDatable: false, lovedGifts: ['Remolacha', 'Pastel de Chocolate', 'Diamante', 'Rosa Hada', 'Relleno', 'Tulipán']),
    VillagerModel(id: 'leah', name: 'Leah', season: 'Invierno', day: 23, isDatable: true, lovedGifts: ['Queso de Cabra', 'Muffin de Amapola', 'Ensalada', 'Salteado de Verduras', 'Trufa', 'Vino']),
    VillagerModel(id: 'clint', name: 'Clint', season: 'Invierno', day: 26, isDatable: false, lovedGifts: ['Amatista', 'Aguamarina', 'Alcachofa con Salsa', 'Esmeralda', 'Risotto de Helecho', 'Barra de Oro', 'Jade', 'Omnigeoda', 'Rubí', 'Topacio']),
    VillagerModel(id: 'krobus', name: 'Krobus', season: 'Invierno', day: 1, isDatable: false, lovedGifts: ['Diamante', 'Barra de Iridio', 'Calabaza', 'Huevo Vacío', 'Mayonesa Vacía', 'Rábano Silvestre']),

    // --- MODS POPULARES (SVE & Ridgeside Village) ---
    VillagerModel(id: 'sophia', name: 'Sophia (SVE)', season: 'Primavera', day: 27, isDatable: true, isModded: true, sourceMod: 'Stardew Valley Expanded', lovedGifts: ['Vino de Hada', 'Tarta de Fresa', 'Tela Rosa']),
    VillagerModel(id: 'victor', name: 'Victor (SVE)', season: 'Verano', day: 8, isDatable: true, isModded: true, sourceMod: 'Stardew Valley Expanded', lovedGifts: ['Vino Batería', 'Espaguetis de Mar', 'Bebida Energética']),
    VillagerModel(id: 'claire', name: 'Claire (SVE)', season: 'Otoño', day: 14, isDatable: true, isModded: true, sourceMod: 'Stardew Valley Expanded', lovedGifts: ['Té Verde', 'Palomitas de Maíz', 'Batido Energético']),
    VillagerModel(id: 'lance', name: 'Lance (SVE)', season: 'Primavera', day: 12, isDatable: true, isModded: true, sourceMod: 'Stardew Valley Expanded', lovedGifts: ['Daga de la Selva', 'Gema de Sombras']),
    VillagerModel(id: 'ian', name: 'Ian (RSV)', season: 'Primavera', day: 6, isDatable: true, isModded: true, sourceMod: 'Ridgeside Village', lovedGifts: ['Cerveza de la Cresta', 'Carne Asada']),
    VillagerModel(id: 'jeric', name: 'Jeric (RSV)', season: 'Verano', day: 15, isDatable: true, isModded: true, sourceMod: 'Ridgeside Village', lovedGifts: ['Baya de la Montaña', 'Pastel de Leche']),
  ];

  // ─────────────────────────────────────────────────────────
  //  CULTIVOS — Vanilla Stardew Valley 1.6 + Mods
  // ─────────────────────────────────────────────────────────

  static List<CropModel> get defaultCrops => [
    // --- PRIMAVERA ---
    CropModel(id: 'parsnip', name: 'Chirivía (Parsnip)', season: 'Primavera', seedCost: 20, baseSellPrice: 35, daysToGrow: 4),
    CropModel(id: 'garlic', name: 'Ajo (Garlic)', season: 'Primavera', seedCost: 40, baseSellPrice: 60, daysToGrow: 4),
    CropModel(id: 'potato', name: 'Patata (Potato)', season: 'Primavera', seedCost: 50, baseSellPrice: 80, daysToGrow: 6),
    CropModel(id: 'kale', name: 'Col rizada (Kale)', season: 'Primavera', seedCost: 70, baseSellPrice: 110, daysToGrow: 6),
    CropModel(id: 'carrot', name: 'Zanahoria (Carrot - 1.6)', season: 'Primavera', seedCost: 15, baseSellPrice: 35, daysToGrow: 3),
    CropModel(id: 'cauliflower', name: 'Coliflor (Cauliflower)', season: 'Primavera', seedCost: 80, baseSellPrice: 175, daysToGrow: 12),
    CropModel(id: 'green_bean', name: 'Judía verde (Green Bean)', season: 'Primavera', seedCost: 60, baseSellPrice: 40, daysToGrow: 10, regrowDays: 3),
    CropModel(id: 'strawberry', name: 'Fresa (Strawberry)', season: 'Primavera', seedCost: 100, baseSellPrice: 120, daysToGrow: 8, regrowDays: 4),
    CropModel(id: 'rhubarb', name: 'Ruibarbo (Rhubarb)', season: 'Primavera', seedCost: 100, baseSellPrice: 220, daysToGrow: 13),
    CropModel(id: 'tulip', name: 'Tulipán (Tulip)', season: 'Primavera', seedCost: 20, baseSellPrice: 30, daysToGrow: 6),
    CropModel(id: 'blue_jazz', name: 'Jazz Azul (Blue Jazz)', season: 'Primavera', seedCost: 30, baseSellPrice: 50, daysToGrow: 7),
    CropModel(id: 'unmilled_rice', name: 'Arroz sin moler', season: 'Primavera', seedCost: 40, baseSellPrice: 30, daysToGrow: 8),

    // --- VERANO ---
    CropModel(id: 'tomato', name: 'Tomate (Tomato)', season: 'Verano', seedCost: 50, baseSellPrice: 60, daysToGrow: 11, regrowDays: 4),
    CropModel(id: 'hot_pepper', name: 'Chile picante (Hot Pepper)', season: 'Verano', seedCost: 40, baseSellPrice: 40, daysToGrow: 5, regrowDays: 3),
    CropModel(id: 'summer_squash', name: 'Calabacín de Verano (1.6)', season: 'Verano', seedCost: 45, baseSellPrice: 45, daysToGrow: 6, regrowDays: 3),
    CropModel(id: 'radish', name: 'Rábano (Radish)', season: 'Verano', seedCost: 40, baseSellPrice: 90, daysToGrow: 6),
    CropModel(id: 'melon', name: 'Melón (Melon)', season: 'Verano', seedCost: 80, baseSellPrice: 250, daysToGrow: 12),
    CropModel(id: 'blueberry', name: 'Arándano (Blueberry)', season: 'Verano', seedCost: 80, baseSellPrice: 50, daysToGrow: 13, regrowDays: 4),
    CropModel(id: 'starfruit', name: 'Fruta Estelar (Starfruit)', season: 'Verano', seedCost: 400, baseSellPrice: 750, daysToGrow: 13),
    CropModel(id: 'hops', name: 'Lúpulo (Hops)', season: 'Verano', seedCost: 60, baseSellPrice: 25, daysToGrow: 11, regrowDays: 1),
    CropModel(id: 'red_cabbage', name: 'Lombarda (Red Cabbage)', season: 'Verano', seedCost: 100, baseSellPrice: 260, daysToGrow: 9),
    CropModel(id: 'sunflower', name: 'Girasol (Sunflower)', season: 'Verano', seedCost: 200, baseSellPrice: 80, daysToGrow: 8),
    CropModel(id: 'wheat', name: 'Trigo (Wheat)', season: 'Verano', seedCost: 10, baseSellPrice: 25, daysToGrow: 4),
    CropModel(id: 'poppy', name: 'Amapola (Poppy)', season: 'Verano', seedCost: 100, baseSellPrice: 140, daysToGrow: 7),

    // --- OTOÑO ---
    CropModel(id: 'eggplant', name: 'Berenjena (Eggplant)', season: 'Otoño', seedCost: 20, baseSellPrice: 60, daysToGrow: 5, regrowDays: 5),
    CropModel(id: 'broccoli', name: 'Brócoli (Broccoli - 1.6)', season: 'Otoño', seedCost: 35, baseSellPrice: 70, daysToGrow: 8, regrowDays: 4),
    CropModel(id: 'pumpkin', name: 'Calabaza (Pumpkin)', season: 'Otoño', seedCost: 100, baseSellPrice: 320, daysToGrow: 13),
    CropModel(id: 'yam', name: 'Ñame (Yam)', season: 'Otoño', seedCost: 60, baseSellPrice: 160, daysToGrow: 10),
    CropModel(id: 'cranberries', name: 'Arándanos rojos (Cranberries)', season: 'Otoño', seedCost: 240, baseSellPrice: 75, daysToGrow: 7, regrowDays: 5),
    CropModel(id: 'beet', name: 'Remolacha (Beet)', season: 'Otoño', seedCost: 20, baseSellPrice: 100, daysToGrow: 6),
    CropModel(id: 'artichoke', name: 'Alcachofa (Artichoke)', season: 'Otoño', seedCost: 30, baseSellPrice: 160, daysToGrow: 8),
    CropModel(id: 'bok_choy', name: 'Bok Choy', season: 'Otoño', seedCost: 50, baseSellPrice: 80, daysToGrow: 4),
    CropModel(id: 'sweet_gem_berry', name: 'Baya Dulce de Gema', season: 'Otoño', seedCost: 1000, baseSellPrice: 3000, daysToGrow: 24),
    CropModel(id: 'grape', name: 'Uva (Grape)', season: 'Otoño', seedCost: 60, baseSellPrice: 80, daysToGrow: 10, regrowDays: 3),

    // --- INVIERNO / ESPECIALES ---
    CropModel(id: 'powdermelon', name: 'Melón de Nieve (Powdermelon - 1.6)', season: 'Invierno', seedCost: 20, baseSellPrice: 60, daysToGrow: 7),
    CropModel(id: 'ancient_fruit', name: 'Fruta Antigua (Ancient Fruit)', season: 'Invernadero', seedCost: 500, baseSellPrice: 550, daysToGrow: 28, regrowDays: 7),
    CropModel(id: 'cactus_fruit', name: 'Fruto de Cactus', season: 'Invernadero', seedCost: 150, baseSellPrice: 75, daysToGrow: 12, regrowDays: 3),
    CropModel(id: 'pineapple', name: 'Piña (Pineapple)', season: 'Invernadero', seedCost: 240, baseSellPrice: 300, daysToGrow: 14, regrowDays: 7),

    // --- MODS POPULARES (Stardew Valley Expanded / Ridgeside Village) ---
    CropModel(id: 'sve_slime_berry', name: 'Baya Babosa (Slime Berry - SVE)', season: 'Primavera', seedCost: 200, baseSellPrice: 350, daysToGrow: 8, regrowDays: 3, sourceMod: 'Stardew Valley Expanded'),
    CropModel(id: 'sve_monster_fruit', name: 'Fruta Monstruosa (Monster Fruit - SVE)', season: 'Verano', seedCost: 300, baseSellPrice: 500, daysToGrow: 12, regrowDays: 4, sourceMod: 'Stardew Valley Expanded'),
    CropModel(id: 'sve_salvia', name: 'Salvia Silvestre (Salvia - SVE)', season: 'Otoño', seedCost: 120, baseSellPrice: 310, daysToGrow: 9, sourceMod: 'Stardew Valley Expanded'),
    CropModel(id: 'sve_monster_mushroom', name: 'Hongo Monstruoso (SVE)', season: 'Otoño', seedCost: 250, baseSellPrice: 450, daysToGrow: 10, sourceMod: 'Stardew Valley Expanded'),
    CropModel(id: 'sve_void_root', name: 'Raíz Vacía (Void Root - SVE)', season: 'Invernadero', seedCost: 400, baseSellPrice: 800, daysToGrow: 14, regrowDays: 5, sourceMod: 'Stardew Valley Expanded'),
    CropModel(id: 'rsv_ridge_cherry', name: 'Cereza de la Cresta (RSV)', season: 'Primavera', seedCost: 150, baseSellPrice: 280, daysToGrow: 8, regrowDays: 3, sourceMod: 'Ridgeside Village'),
    CropModel(id: 'rsv_highland_berry', name: 'Baya de la Montaña (RSV)', season: 'Verano', seedCost: 200, baseSellPrice: 420, daysToGrow: 10, regrowDays: 4, sourceMod: 'Ridgeside Village'),
    CropModel(id: 'rsv_highland_lotus', name: 'Loto de las Cumbres (RSV)', season: 'Verano', seedCost: 350, baseSellPrice: 650, daysToGrow: 12, sourceMod: 'Ridgeside Village'),
  ];
}
