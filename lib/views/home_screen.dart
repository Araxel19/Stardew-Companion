import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/i18n_service.dart';
import '../theme/stardew_theme.dart';
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
      // --- Layout Adaptativo para Móviles (Android / iOS) ---
      return Scaffold(
        appBar: AppBar(
          backgroundColor: StardewColors.cardBackground,
          elevation: 2,
          title: Row(
            children: [
              const Icon(Icons.star_half, color: StardewColors.primaryGold, size: 24),
              const SizedBox(width: 8),
              Text(
                navItems[_selectedIndex]['label'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: StardewColors.primaryGold),
              ),
            ],
          ),
          actions: [
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
                      '${saveData.perfectionPercentage.toStringAsFixed(0)}% Qi',
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
                      if (saveData != null) ...[
                        const SizedBox(height: 4),
                        Text('Granjero: ${saveData.farmerName}', style: const TextStyle(color: StardewColors.textMuted, fontSize: 12)),
                      ],
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
                    return ListTile(
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
                        Navigator.pop(context); // Cerrar Drawer
                      },
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

    // --- Layout Adaptativo para PC / Desktop (Windows / Web / Tablet amplia) ---
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
                const SizedBox(height: 20),
              ],
            ),
            destinations: navItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item['icon'] as IconData),
                selectedIcon: Icon(item['icon'] as IconData, color: StardewColors.primaryGold),
                label: Text(item['label'] as String),
              );
            }).toList(),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: saveData != null && MediaQuery.of(context).size.width > 1100
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(),
                            Text('Granjero: ${saveData.farmerName}', style: const TextStyle(fontSize: 12, color: StardewColors.textMuted)),
                            Text('Perfección: ${saveData.perfectionPercentage.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: StardewColors.iridiumPurple, fontWeight: FontWeight.bold)),
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
