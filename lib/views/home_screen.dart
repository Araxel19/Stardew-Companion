import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/perfection_service.dart';
import '../providers/app_state_provider.dart';
import '../services/i18n_service.dart';
import '../theme/stardew_theme.dart';
import '../widgets/quick_search_dialog.dart';
import 'calendar_view.dart';
import 'crop_calculator_view.dart';
import 'custom_mod_view.dart';
import 'ledger_view.dart';
import 'perfection_view.dart';
import 'save_importer_view.dart';
import 'settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    SaveImporterView(),
    CropCalculatorView(),
    CalendarView(),
    PerfectionView(),
    LedgerView(),
    CustomModView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final saveData = provider.activeSaveData;
    final locale = provider.locale;
    final appVersion = provider.appVersion;
    final isMobile = MediaQuery.of(context).size.width < 800;

    final navItems = [
      {'icon': Icons.dashboard, 'label': I18nService.get('dashboard', locale)},
      {'icon': Icons.calculate, 'label': I18nService.get('crop_calc', locale)},
      {'icon': Icons.calendar_month, 'label': I18nService.get('calendar', locale)},
      {'icon': Icons.star, 'label': I18nService.get('perfection', locale)},
      {'icon': Icons.account_balance_wallet, 'label': I18nService.get('ledger', locale)},
      {'icon': Icons.extension, 'label': I18nService.get('mod_manager', locale)},
      {'icon': Icons.settings, 'label': I18nService.get('settings', locale)},
    ];

    if (isMobile) {
      // --- Layout Adaptativo para Móviles ---
      return Scaffold(
        appBar: AppBar(
          backgroundColor: StardewColors.cardBackground,
          elevation: 2,
          title: Row(
            children: [
              const Icon(Icons.star_half, color: StardewColors.primaryGold, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  navItems[_selectedIndex]['label'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: StardewColors.primaryGold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: StardewColors.primaryGold),
              tooltip: 'Buscador Universal (Cultivos, Aldeanos, Tareas...)',
              onPressed: () => QuickSearchDialog.show(context),
            ),
            if (provider.savedFarms.isNotEmpty)
              PopupMenuButton<String>(
                icon: const Icon(Icons.swap_horiz, color: StardewColors.primaryGold),
                tooltip: 'Cambiar de partida',
                onSelected: (path) => provider.loadSaveFile(path),
                itemBuilder: (context) => provider.savedFarms.map((farm) {
                  final isCurrent = saveData != null &&
                      saveData.farmerName == farm['farmerName'] &&
                      saveData.farmName == farm['farmName'];
                  return PopupMenuItem<String>(
                    value: farm['savePath'],
                    child: Row(
                      children: [
                        Icon(
                          isCurrent ? Icons.check_circle : Icons.agriculture,
                          color: isCurrent ? StardewColors.primaryGold : StardewColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${farm['farmerName']} (${farm['farmName']})',
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? StardewColors.primaryGold : StardewColors.textBright,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (saveData != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: StardewColors.iridiumPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${PerfectionService.calculate(saveData).toStringAsFixed(0)}% Qi',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: StardewColors.iridiumPurple),
                    ),
                  ),
                ),
              ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: StardewColors.cardBackground,
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: StardewColors.background),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_half, color: StardewColors.primaryGold, size: 40),
                      const SizedBox(height: 8),
                      Text(I18nService.get('app_name', locale), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: StardewColors.primaryGold)),
                      const SizedBox(height: 4),
                      Text('v$appVersion', style: const TextStyle(color: StardewColors.iridiumPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: navItems.length,
                  itemBuilder: (context, index) {
                    final item = navItems[index];
                    final isSelected = _selectedIndex == index;
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(item['icon'] as IconData, color: isSelected ? StardewColors.primaryGold : StardewColors.textMuted),
                        title: Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? StardewColors.primaryGold : StardewColors.textBright,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: StardewColors.cardBackground,
          selectedItemColor: StardewColors.primaryGold,
          unselectedItemColor: StardewColors.textMuted,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Granja'),
            BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Cultivos'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendario'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Perfección'),
          ],
        ),
      );
    }

    // --- Layout Adaptativo para PC / Desktop ---
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: StardewColors.cardBackground,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            extended: MediaQuery.of(context).size.width > 1100,
            minExtendedWidth: 230,
            leading: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_half, color: StardewColors.primaryGold, size: 28),
                    if (MediaQuery.of(context).size.width > 1100) ...[
                      const SizedBox(width: 10),
                      Text(
                        I18nService.get('app_name', locale),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: StardewColors.primaryGold),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: StardewColors.iridiumPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('v$appVersion', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: StardewColors.iridiumPurple)),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.search, color: StardewColors.primaryGold),
                  tooltip: 'Buscador Universal (Cultivos, Aldeanos...)',
                  onPressed: () => QuickSearchDialog.show(context),
                ),
                const SizedBox(height: 8),
              ],
            ),
            destinations: navItems.map((item) {
              return NavigationRailDestination(
                icon: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(item['icon'] as IconData),
                ),
                selectedIcon: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(item['icon'] as IconData, color: StardewColors.primaryGold),
                ),
                label: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(item['label'] as String),
                ),
              );
            }).toList(),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: MediaQuery.of(context).size.width > 1100
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(),
                            if (provider.savedFarms.isNotEmpty)
                              PopupMenuButton<String>(
                                tooltip: 'Cambiar de partida activa',
                                onSelected: (path) => provider.loadSaveFile(path),
                                itemBuilder: (context) => provider.savedFarms.map((farm) {
                                  final isCurrent = saveData != null &&
                                      saveData.farmerName == farm['farmerName'] &&
                                      saveData.farmName == farm['farmName'];
                                  return PopupMenuItem<String>(
                                    value: farm['savePath'],
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCurrent ? Icons.check_circle : Icons.agriculture,
                                          color: isCurrent ? StardewColors.primaryGold : StardewColors.textMuted,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Text('${farm['farmerName']} (${farm['farmName']})'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: StardewColors.cardBackground,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: StardewColors.primaryGold.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.agriculture, color: StardewColors.primaryGold, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        saveData != null ? saveData.farmerName : 'Partida',
                                        style: const TextStyle(fontSize: 12, color: StardewColors.textBright, fontWeight: FontWeight.bold),
                                      ),
                                      const Icon(Icons.arrow_drop_down, color: StardewColors.primaryGold, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            if (saveData != null)
                              Text('Perfección: ${PerfectionService.calculate(saveData).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: StardewColors.iridiumPurple, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : null,
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),

          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
