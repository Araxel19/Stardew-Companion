import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/default_stardew_data.dart';
import '../providers/app_state_provider.dart';
import '../theme/stardew_theme.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  String activeSeason = 'Primavera';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final seasonEvents = DefaultStardewData.getSeasonEvents(activeSeason);
    final tasks = provider.tasks;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Season Switcher
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calendario del Juego & Cosechas', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: isMobile ? 18 : 22, color: StardewColors.primaryGold)),
              const SizedBox(height: 4),
              const Text('Planifica tus días de siembra, cosecha, cumpleaños y eventos especiales.', style: TextStyle(color: StardewColors.textMuted, fontSize: 13)),
              const SizedBox(height: 12),

              // Season Selector Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Primavera', 'Verano', 'Otoño', 'Invierno'].map((season) {
                    final isSelected = activeSeason == season;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(season),
                        selected: isSelected,
                        selectedColor: StardewColors.primaryGold,
                        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        onSelected: (val) {
                          if (val) setState(() => activeSeason = season);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 28-Day Stardew Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 días por semana
              crossAxisSpacing: isMobile ? 4 : 12,
              mainAxisSpacing: isMobile ? 4 : 12,
              childAspectRatio: isMobile ? 0.65 : 1.1,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              final dayNumber = index + 1;
              final dayStr = dayNumber.toString();
              
              final events = seasonEvents[dayStr] ?? [];
              final dayTasks = tasks.where((t) => t['season'].toString().toLowerCase() == activeSeason.toLowerCase() && t['day'] == dayNumber).toList();
              final isTravelingCart = [5, 7, 12, 14, 19, 21, 26, 28].contains(dayNumber);

              return Card(
                color: StardewColors.cardBackground,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: dayTasks.isNotEmpty
                        ? StardewColors.emeraldGreen
                        : events.isNotEmpty
                            ? StardewColors.primaryGold
                            : StardewColors.cardBorder,
                    width: dayTasks.isNotEmpty || events.isNotEmpty ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 14),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 4.0 : 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: StardewColors.cardBorder,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'D$dayNumber',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12, color: StardewColors.primaryGold),
                            ),
                          ),
                          if (isTravelingCart)
                            Icon(Icons.shopping_cart, size: isMobile ? 12 : 16, color: StardewColors.iridiumPurple),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Eventos del día
                      Expanded(
                        child: ListView(
                          children: [
                            ...events.map((e) => Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: e['type'] == 'festival'
                                    ? StardewColors.rubyRed.withValues(alpha: 0.2)
                                    : StardewColors.primaryGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                e['title'] ?? '',
                                style: TextStyle(fontSize: isMobile ? 8 : 10, fontWeight: FontWeight.w600, color: StardewColors.textBright),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),

                            ...dayTasks.map((t) => Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: StardewColors.emeraldGreen.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t['title'] ?? '',
                                style: TextStyle(fontSize: isMobile ? 8 : 10, fontWeight: FontWeight.bold, color: StardewColors.emeraldGreen),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
