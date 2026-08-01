import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../application/perfection_service.dart';
import '../providers/app_state_provider.dart';
import '../theme/stardew_theme.dart';

import '../widgets/stardew_shimmer.dart';

class SaveImporterView extends StatelessWidget {
  const SaveImporterView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final saveData = provider.activeSaveData;
    final savedFarms = provider.savedFarms;
    final installedMods = provider.installedMods;
    final currencyFormatter = NumberFormat.currency(symbol: 'g ', decimalDigits: 0);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: provider.isLoadingSave
          ? const SaveDashboardSkeleton(key: ValueKey('skeleton'))
          : SingleChildScrollView(
              key: const ValueKey('content'),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 650;
                final headerContent = Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: StardewColors.primaryGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: StardewColors.primaryGold, width: 2),
                      ),
                      child: const Icon(Icons.shield_moon, color: Colors.black, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            saveData != null ? 'Granjero ${saveData.farmerName}' : 'Cargar Partida de Stardew Valley',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, color: StardewColors.primaryGold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            saveData != null
                                ? 'Granja ${saveData.farmName} • Año ${saveData.gameYear}, ${saveData.gameSeason} Día ${saveData.gameDay}'
                                : 'Selecciona tu archivo de guardado para sincronizar finanzas, mods y perfecciones',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final button = ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.pickFiles(
                      allowMultiple: false,
                      dialogTitle: 'Selecciona tu archivo de partida de Stardew Valley',
                    );
                    if (result != null && result.files.single.path != null) {
                      await provider.loadSaveFile(result.files.single.path!);
                    }
                  },
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Importar Archivo Manual'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StardewColors.primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: headerContent),
                      const SizedBox(width: 16),
                      button,
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headerContent,
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, child: button),
                    ],
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Selector de Partidas Disponibles
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder_shared, color: StardewColors.primaryGold),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Tus Partidas Guardadas / Importadas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: StardewColors.primaryGold),
                        tooltip: 'Buscar partidas locales',
                        onPressed: () => provider.scanAndLoadSaves(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (savedFarms.isEmpty)
                    const Text('No se encontraron partidas locales. ¡Haz clic en Importar Archivo Manual arriba para cargar cualquier guardado!')
                  else
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: savedFarms.length,
                        itemBuilder: (context, index) {
                          final farm = savedFarms[index];
                          final isSelected = saveData != null &&
                              saveData.farmerName == farm['farmerName'] &&
                              saveData.farmName == farm['farmName'];

                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              mouseCursor: SystemMouseCursors.click,
                              onTap: () => provider.loadSaveFile(farm['savePath']),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 220,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? StardewColors.iridiumPurple.withValues(alpha: 0.25)
                                      : StardewColors.background,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? StardewColors.iridiumPurple : StardewColors.cardBorder,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isSelected ? StardewColors.primaryGold : StardewColors.cardBorder,
                                      child: Icon(
                                        isSelected ? Icons.check : Icons.agriculture,
                                        color: isSelected ? Colors.black : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            farm['farmerName'] ?? 'Granjero',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? StardewColors.primaryGold : StardewColors.textBright,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Granja ${farm['farmName']}',
                                            style: const TextStyle(fontSize: 12, color: StardewColors.textMuted),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            currencyFormatter.format(farm['gold'] ?? 0),
                                            style: const TextStyle(fontSize: 11, color: StardewColors.emeraldGreen, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
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
                  value: '${PerfectionService.calculate(saveData).toStringAsFixed(1)}%',
                  icon: Icons.star_rounded,
                  color: StardewColors.iridiumPurple,
                ),
                _buildStatCard(
                  title: 'Mods Instalados / Activos',
                  value: '${installedMods.isNotEmpty ? installedMods.length : saveData.detectedMods.length} Mods',
                  icon: Icons.extension_outlined,
                  color: StardewColors.oceanBlue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Mods & Friendship Overview
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 750;
                final modsCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.extension, color: StardewColors.oceanBlue),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Mods Detectados & Instalados',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (installedMods.isNotEmpty)
                              Chip(
                                label: Text('${installedMods.length} Instalados', style: const TextStyle(fontSize: 11, color: Colors.white)),
                                backgroundColor: StardewColors.oceanBlue.withValues(alpha: 0.3),
                              ),
                          ],
                        ),
                          const Divider(height: 24),
                          if (installedMods.isNotEmpty) ...[
                            const Text('Mods en la carpeta de Stardew Valley / SMAPI:', style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textMuted)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: installedMods.take(15).map((mod) {
                                return Chip(
                                  avatar: const Icon(Icons.check_circle, size: 16, color: StardewColors.emeraldGreen),
                                  label: Text('${mod.name} (v${mod.version})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                  backgroundColor: StardewColors.cardBorder,
                                );
                              }).toList(),
                            ),
                            if (installedMods.length > 15) ...[
                              const SizedBox(height: 8),
                              Text('+ ${installedMods.length - 15} mods más instalados...', style: const TextStyle(color: StardewColors.primaryGold, fontSize: 12)),
                            ],
                          ] else if (saveData.detectedMods.isNotEmpty) ...[
                            const Text('Etiquetas de mods encontradas en este archivo XML:', style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textMuted)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: saveData.detectedMods.map((mod) {
                                return Chip(
                                  avatar: const Icon(Icons.check_circle, size: 16, color: StardewColors.emeraldGreen),
                                  label: Text(mod, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                  backgroundColor: StardewColors.cardBorder,
                                );
                              }).toList(),
                            ),
                           ] else ...[
                             const Text('No se detectaron carpetas de mods ni etiquetas especiales en esta partida.'),
                           ],
                        ],
                      ),
                    ),
                  );
                final friendshipCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: StardewColors.rubyRed),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Aldeanos Registrados (Amistad)',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: modsCard),
                      const SizedBox(width: 16),
                      Expanded(child: friendshipCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      modsCard,
                      const SizedBox(height: 16),
                      friendshipCard,
                    ],
                  );
                }
              },
            ),
          ],
        ],
      ),
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
