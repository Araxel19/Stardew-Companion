import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/i18n_service.dart';
import '../theme/stardew_theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final locale = provider.locale;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            I18nService.get('settings', locale),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: StardewColors.primaryGold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Personaliza el tema visual, idioma y gestiona las copias de seguridad de tus datos.',
            style: TextStyle(color: StardewColors.textMuted),
          ),
          const SizedBox(height: 24),

          // 1. Selector de Idioma
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: StardewColors.primaryGold),
                      const SizedBox(width: 12),
                      Text(I18nService.get('language_selection', locale), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Español 🇪🇸'),
                        selected: locale == 'es',
                        onSelected: (val) {
                          if (val) provider.setLocale('es');
                        },
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('English 🇬🇧'),
                        selected: locale == 'en',
                        onSelected: (val) {
                          if (val) provider.setLocale('en');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Selector de Tema Visual
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: StardewColors.iridiumPurple),
                      const SizedBox(width: 12),
                      Text(I18nService.get('theme_selection', locale), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                    ],
                  ),
                  const Divider(height: 24),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildThemeChip(context, provider, 'Iridium Púrpura', StardewThemeMode.iridium, StardewColors.iridiumPurple),
                      _buildThemeChip(context, provider, 'Oro Solsticio', StardewThemeMode.gold, StardewColors.primaryGold),
                      _buildThemeChip(context, provider, 'Primavera Esmeralda', StardewThemeMode.emerald, StardewColors.emeraldGreen),
                      _buildThemeChip(context, provider, 'Isla Coral', StardewThemeMode.coral, const Color(0xFFF97316)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Copia de Seguridad & Respaldos JSON
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.backup_outlined, color: StardewColors.emeraldGreen),
                      SizedBox(width: 12),
                      Text('Copias de Seguridad (Respaldos JSON)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Exporta todos tus registros contables, cosechas y cultivos de mods a un archivo JSON para pasarlos a tu teléfono móvil u otro PC.',
                    style: TextStyle(color: StardewColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final path = await provider.exportDataBackup();
                          if (path != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('¡Respaldo exportado exitosamente en:\n$path'),
                                backgroundColor: StardewColors.emeraldGreen,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: Text(I18nService.get('export_backup', locale)),
                        style: ElevatedButton.styleFrom(backgroundColor: StardewColors.emeraldGreen, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['json'],
                          );
                          if (result != null && result.files.single.path != null) {
                            final success = await provider.importDataBackup(result.files.single.path!);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('¡Copia de seguridad restaurada correctamente!'),
                                  backgroundColor: StardewColors.primaryGold,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.upload),
                        label: Text(I18nService.get('import_backup', locale)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(BuildContext context, AppStateProvider provider, String label, StardewThemeMode mode, Color color) {
    final isSelected = provider.themeMode == mode;
    return ChoiceChip(
      avatar: CircleAvatar(backgroundColor: color, radius: 8),
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) provider.setThemeMode(mode);
      },
    );
  }
}
