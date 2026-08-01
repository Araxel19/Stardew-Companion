import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/stardew_theme.dart';

class SaveImporterView extends StatelessWidget {
  const SaveImporterView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final saveData = provider.activeSaveData;
    final currencyFormatter = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2E1C4D), StardewColors.cardBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StardewColors.iridiumPurple, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: StardewColors.primaryGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: StardewColors.primaryGold, width: 2),
                  ),
                  child: const Icon(Icons.shield_moon, color: Colors.black, size: 36),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        saveData != null ? 'Granjero ${saveData.farmerName}' : 'Cargar Partida de Stardew Valley',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: StardewColors.primaryGold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        saveData != null
                            ? 'Granja ${saveData.farmName} • Año ${saveData.gameYear}, ${saveData.gameSeason} Día ${saveData.gameDay}'
                            : 'Selecciona tu archivo de guardado para sincronizar finanzas y perfecciones',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.pickFiles();
                    if (result != null && result.files.single.path != null) {
                      provider.loadSaveFile(result.files.single.path!);
                    }
                  },
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Cargar Guardado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StardewColors.primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (provider.isLoadingSave)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: StardewColors.primaryGold),
              ),
            )
          else if (saveData != null) ...[
            // Stat Cards Grid
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _buildStatCard(
                  title: 'Oro Actual',
                  value: currencyFormatter.format(saveData.currentMoney),
                  icon: Icons.monetization_on,
                  color: StardewColors.primaryGold,
                ),
                _buildStatCard(
                  title: 'Ganancias Totales',
                  value: currencyFormatter.format(saveData.totalEarnings),
                  icon: Icons.trending_up,
                  color: StardewColors.emeraldGreen,
                ),
                _buildStatCard(
                  title: 'Perfección 100%',
                  value: '${saveData.perfectionPercentage.toStringAsFixed(1)}%',
                  icon: Icons.star_rounded,
                  color: StardewColors.iridiumPurple,
                ),
                _buildStatCard(
                  title: 'Mods Detectados',
                  value: '${saveData.detectedMods.length} Activos',
                  icon: Icons.extension_outlined,
                  color: StardewColors.oceanBlue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Mods & Friendship Overview
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.extension, color: StardewColors.oceanBlue),
                              SizedBox(width: 10),
                              Text('Mods Detectados en tu Partida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                            ],
                          ),
                          const Divider(height: 24),
                          if (saveData.detectedMods.isEmpty)
                            const Text('No se detectaron etiquetas específicas de mods en esta partida.')
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: saveData.detectedMods.map((mod) {
                                return Chip(
                                  avatar: const Icon(Icons.check_circle, size: 16, color: StardewColors.emeraldGreen),
                                  label: Text(mod, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  backgroundColor: StardewColors.cardBorder,
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.favorite, color: StardewColors.rubyRed),
                              SizedBox(width: 10),
                              Text('Aldeanos Registrados (Amistad)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                            ],
                          ),
                          const Divider(height: 24),
                          Text('${saveData.friendships.length} Aldeanos encontrados (${saveData.friendships.values.where((f) => f.isModded).length} de Mods)'),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: saveData.friendships.isEmpty
                                ? 0
                                : (saveData.friendships.values.where((f) => f.hearts >= 8).length / saveData.friendships.length),
                            backgroundColor: StardewColors.background,
                            color: StardewColors.rubyRed,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: StardewColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
