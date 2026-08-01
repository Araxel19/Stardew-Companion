import 'package:flutter/material.dart';
import '../theme/stardew_theme.dart';
import 'stardew_avatars.dart';

class VillagerGiftsDialog extends StatefulWidget {
  const VillagerGiftsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const VillagerGiftsDialog(),
    );
  }

  @override
  State<VillagerGiftsDialog> createState() => _VillagerGiftsDialogState();
}

class _VillagerGiftsDialogState extends State<VillagerGiftsDialog> {
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
    final filtered = _villagers
        .where((v) =>
            (v['name'] as String).toLowerCase().contains(_query.toLowerCase()) ||
            (v['loved'] as String).toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Dialog(
      backgroundColor: StardewColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: StardewColors.primaryGold, width: 2),
      ),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard, color: StardewColors.primaryGold, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Guía de Regalos y Cumpleaños de Aldeanos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.primaryGold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: StardewColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: StardewColors.textBright),
              decoration: InputDecoration(
                hintText: 'Buscar aldeano o objeto preferido...',
                hintStyle: const TextStyle(color: StardewColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: StardewColors.oceanBlue),
                filled: true,
                fillColor: StardewColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: StardewColors.cardBorder),
                ),
              ),
              onChanged: (val) => setState(() => _query = val.trim()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final v = filtered[index];
                  final name = v['name'] as String;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: VillagerAvatar(name: name, size: 40),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🎂 Cumpleaños: ${v['birthday']}', style: const TextStyle(color: StardewColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('❤️ Le encanta: ${v['loved']}', style: const TextStyle(color: StardewColors.textMuted, fontSize: 12)),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
