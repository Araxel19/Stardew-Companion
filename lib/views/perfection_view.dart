import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/stardew_theme.dart';

class PerfectionView extends StatelessWidget {
  const PerfectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final saveData = provider.activeSaveData;
    final totalPerfection = saveData?.perfectionPercentage ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de Perfección
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [StardewColors.iridiumPurple.withOpacity(0.4), StardewColors.cardBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StardewColors.iridiumPurple, width: 2),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: totalPerfection / 100.0,
                        strokeWidth: 10,
                        backgroundColor: StardewColors.background,
                        color: StardewColors.iridiumPurple,
                      ),
                    ),
                    Text(
                      '${totalPerfection.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: StardewColors.primaryGold),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('El Camino a la Perfección (100%)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: StardewColors.primaryGold)),
                      SizedBox(height: 6),
                      Text(
                        'Consigue el Gran Desafío del Nogal del Señor Qi. Esta sección evalúa automáticamente tu progreso guardado.',
                        style: TextStyle(color: StardewColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Categorías de Perfección
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildPerfectionCard(
                title: 'Reloj de Oro de la Granja',
                subtitle: saveData?.hasGoldenClock == true ? '¡Construido! (10,000,000g)' : 'Pendiente (10,000,000g)',
                isDone: saveData?.hasGoldenClock ?? false,
                icon: Icons.access_time_filled,
              ),
              _buildPerfectionCard(
                title: 'Obeliscos de Teletransporte',
                subtitle: '${saveData?.obelisksCount ?? 0} de 4 Obeliscos Construidos',
                isDone: (saveData?.obelisksCount ?? 0) >= 4,
                icon: Icons.account_balance,
              ),
              _buildPerfectionCard(
                title: 'Recetas de Cocina',
                subtitle: '${saveData?.cookingRecipes.values.where((c) => c > 0).length ?? 0} Recetas Cocinadas',
                isDone: false,
                icon: Icons.restaurant,
              ),
              _buildPerfectionCard(
                title: 'Objetos de Fabricación (Crafting)',
                subtitle: '${saveData?.craftingRecipes.values.where((c) => c > 0).length ?? 0} Objetos Fabricados',
                isDone: false,
                icon: Icons.construction,
              ),
              _buildPerfectionCard(
                title: 'Colección de Peces Atrapados',
                subtitle: '${saveData?.fishCaught.length ?? 0} Especies de Peces Atrapadas',
                isDone: false,
                icon: Icons.phishing,
              ),
              _buildPerfectionCard(
                title: 'Amistad Máxima con Aldeanos',
                subtitle: '${saveData?.friendships.values.where((f) => f.hearts >= 8).length ?? 0} Aldeanos al máximo de corazones',
                isDone: false,
                icon: Icons.favorite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerfectionCard({
    required String title,
    required String subtitle,
    required bool isDone,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isDone ? StardewColors.emeraldGreen : StardewColors.primaryGold, size: 32),
                Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isDone ? StardewColors.emeraldGreen : StardewColors.textMuted,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: StardewColors.textMuted, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
