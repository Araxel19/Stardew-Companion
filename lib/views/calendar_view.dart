import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/calendar_service.dart';
import '../models/default_stardew_data.dart';
import '../models/villager_friendship.dart';
import '../models/villager_model.dart';
import '../models/planted_crop_model.dart';
import '../providers/app_state_provider.dart';
import '../providers/planted_crop_provider.dart';
import '../theme/stardew_theme.dart';
import '../widgets/stardew_avatars.dart';
import '../widgets/villager_gifts_dialog.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String activeSeason = 'Primavera';
  String _searchQuery = '';
  String _villagerFilter = 'Todos'; // Todos, Solteros, Mods

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final saveData = provider.activeSaveData;
    final seasonEvents = CalendarService.getSeasonEvents(activeSeason, DefaultStardewData.defaultVillagers);
    final tasks = provider.tasks;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Column(
      children: [
        // Tab Navigation Header
        Container(
          color: StardewColors.cardBackground,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: StardewColors.primaryGold,
            labelColor: StardewColors.primaryGold,
            unselectedLabelColor: StardewColors.textMuted,
            tabs: const [
              Tab(icon: Icon(Icons.calendar_month), text: 'Calendario & Cosechas'),
              Tab(icon: Icon(Icons.favorite), text: 'Aldeanos, Amistad & Regalos'),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // --- TAB 1: CALENDARIO ---
              _buildCalendarTab(context, seasonEvents, tasks, isMobile, provider),

              // --- TAB 2: ALDEANOS & REGALOS ---
              _buildVillagersTab(context, saveData, isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarTab(
    BuildContext context,
    Map<String, List<Map<String, String>>> seasonEvents,
    List<Map<String, dynamic>> tasks,
    bool isMobile,
    AppStateProvider provider,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Season Switcher
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendario del Juego & Cosechas',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: isMobile ? 18 : 22, color: StardewColors.primaryGold),
              ),
              const SizedBox(height: 4),
              const Text('Haz clic en cualquier día para desplegar eventos, regalos de cumpleaños y agendar tareas.', style: TextStyle(color: StardewColors.textMuted, fontSize: 13)),
              const SizedBox(height: 12),

              // Season Selector Button              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...['Primavera', 'Verano', 'Otoño', 'Invierno', 'Invernadero'].map((season) {
                      final isSelected = activeSeason == season;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ChoiceChip(
                            label: Text(season),
                            selected: isSelected,
                            selectedColor: StardewColors.primaryGold,
                            labelStyle: TextStyle(
                              color: isSelected ? StardewColors.background : StardewColors.textBright,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => activeSeason = season);
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => VillagerGiftsDialog.show(context),
                      icon: const Icon(Icons.card_giftcard, color: StardewColors.primaryGold, size: 18),
                      label: const Text('Guía de Regalos', style: TextStyle(color: StardewColors.primaryGold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 28-Day Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: isMobile ? 4 : 12,
              mainAxisSpacing: isMobile ? 4 : 12,
              childAspectRatio: isMobile ? 0.65 : 1.1,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              final dayNumber = index + 1;
              final dayStr = dayNumber.toString();
              
              final events = seasonEvents[dayStr] ?? [];
              final dayTasks = tasks.where((t) {
                if (t['day'] != dayNumber) return false;
                final tSeason = (t['season'] ?? '').toString().toLowerCase();
                final actSeason = activeSeason.toLowerCase();
                return tSeason == actSeason || tSeason == 'invernadero' || tSeason == 'general';
              }).toList();
              final isTravelingCart = [5, 7, 12, 14, 19, 21, 26, 28].contains(dayNumber);

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Card(
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 14),
                    onTap: () => _showDayDetailsModal(context, dayNumber, activeSeason, events, dayTasks, isTravelingCart, provider),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 4.0 : 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: StardewColors.cardBorder,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'D$dayNumber',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 10 : 12, color: StardewColors.primaryGold),
                                  ),
                                ),
                                if (isTravelingCart) ...[
                                  SizedBox(width: isMobile ? 2 : 4),
                                  const Tooltip(
                                    message: 'Carro Ambulante disponible hoy',
                                    child: Icon(Icons.shopping_cart, size: 12, color: StardewColors.iridiumPurple),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          Expanded(
                            child: ListView(
                              children: [
                                ...events.map((e) => Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: e['type'] == 'festival'
                                        ? StardewColors.rubyRed.withValues(alpha: 0.25)
                                        : StardewColors.primaryGold.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    e['title'] ?? '',
                                    style: TextStyle(fontSize: isMobile ? 8 : 10, fontWeight: FontWeight.w600, color: StardewColors.textBright),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),

                                ...dayTasks.map((t) {
                                  final isHarvest = (t['category'] == 'Cosecha') || (t['title']?.contains('Cosecha') ?? false);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isHarvest
                                          ? StardewColors.primaryGold.withAlpha(50)
                                          : StardewColors.emeraldGreen.withAlpha(40),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isHarvest
                                            ? StardewColors.primaryGold.withAlpha(120)
                                            : StardewColors.emeraldGreen.withAlpha(80),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      t['title'] ?? '',
                                      style: TextStyle(
                                        fontSize: isMobile ? 8 : 10,
                                        fontWeight: FontWeight.bold,
                                        color: isHarvest ? StardewColors.primaryGold : StardewColors.emeraldGreen,
                                        decoration: t['isCompleted'] == 1 ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVillagersTab(BuildContext context, dynamic saveData, bool isMobile) {
    final Map<String, dynamic> activeFriendships = saveData?.friendships ?? {};
    
    final List<VillagerModel> villagersList = [];
    final Set<String> processedNames = {};

    for (final v in DefaultStardewData.defaultVillagers) {
      villagersList.add(v);
      processedNames.add(v.name.toLowerCase());
      processedNames.add(v.id.toLowerCase());
    }

    if (activeFriendships.isNotEmpty) {
      activeFriendships.forEach((npcName, friendshipObj) {
        if (!processedNames.contains(npcName.toLowerCase())) {
          processedNames.add(npcName.toLowerCase());
          villagersList.add(VillagerModel(
            id: npcName.toLowerCase(),
            name: npcName,
            season: 'Desconocida',
            day: 1,
            lovedGifts: ['Regalos de Mod / Preferidos por descubrir en el juego'],
            isDatable: false,
            isModded: true,
            sourceMod: 'Mod Detectado',
          ));
        }
      });
    }

    final filteredVillagers = villagersList.where((v) {
      if (_villagerFilter == 'Solteros' && !v.isDatable) return false;
      if (_villagerFilter == 'Mods' && !v.isModded) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = v.name.toLowerCase().contains(query);
        final giftMatch = v.lovedGifts.any((g) => g.toLowerCase().contains(query));
        return nameMatch || giftMatch;
      }
      return true;
    }).toList();

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
      child: Column(
        children: [
          // Bar de Búsqueda y Filtros
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      style: const TextStyle(color: StardewColors.textBright),
                      decoration: InputDecoration(
                        hintText: 'Buscar aldeano o regalo favorito...',
                        hintStyle: const TextStyle(color: StardewColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: StardewColors.primaryGold),
                        filled: true,
                        fillColor: StardewColors.cardBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Todos', 'Solteros', 'Mods'].map((filter) {
                          final isSelected = _villagerFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: isSelected,
                                selectedColor: StardewColors.primaryGold,
                                labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                onSelected: (val) {
                                  if (val) setState(() => _villagerFilter = filter);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: StardewColors.textBright),
                        decoration: InputDecoration(
                          hintText: 'Buscar aldeano o regalo favorito (ej. Amethyst, Abigail)...',
                          hintStyle: const TextStyle(color: StardewColors.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: StardewColors.primaryGold),
                          filled: true,
                          fillColor: StardewColors.cardBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 6,
                      children: ['Todos', 'Solteros', 'Mods'].map((filter) {
                        final isSelected = _villagerFilter == filter;
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: StardewColors.primaryGold,
                            labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            onSelected: (val) {
                              if (val) setState(() => _villagerFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
          const SizedBox(height: 16),

          // Lista de Aldeanos con Fotos de Avatar y Progreso Real
          Expanded(
            child: ListView.builder(
              itemCount: filteredVillagers.length,
              itemBuilder: (context, index) {
                final v = filteredVillagers[index];
                final saveFriendship = activeFriendships[v.name] ?? activeFriendships[v.id];
                final points = saveFriendship?.points ?? 0;
                final hearts = saveFriendship?.hearts ?? (points ~/ 250);

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showVillagerDetailsModal(context, v, saveFriendship),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isMobile
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          VillagerAvatar(
                                            name: v.name,
                                            isDatable: v.isDatable,
                                            isModded: v.isModded,
                                            size: 44,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        v.name,
                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StardewColors.textBright),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (v.isModded) ...[
                                                      const SizedBox(width: 6),
                                                      Chip(
                                                        label: Text(v.sourceMod ?? 'Mod', style: const TextStyle(fontSize: 9, color: Colors.white)),
                                                        backgroundColor: StardewColors.iridiumPurple.withValues(alpha: 0.4),
                                                        visualDensity: VisualDensity.compact,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                Text('Cumpleaños: ${v.season} Día ${v.day}', style: const TextStyle(fontSize: 12, color: StardewColors.textMuted)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Row(
                                              children: List.generate(10, (hIndex) {
                                                return Icon(
                                                  hIndex < hearts ? Icons.favorite : Icons.favorite_border,
                                                  color: hIndex < hearts ? StardewColors.rubyRed : StardewColors.textMuted,
                                                  size: 15,
                                                );
                                              }),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '$hearts / 10 Corazones ($points pts)',
                                              style: const TextStyle(fontSize: 11, color: StardewColors.primaryGold, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          VillagerAvatar(
                                            name: v.name,
                                            isDatable: v.isDatable,
                                            isModded: v.isModded,
                                            size: 48,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(v.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                                                  if (v.isModded) ...[
                                                    const SizedBox(width: 8),
                                                    Chip(
                                                      label: Text(v.sourceMod ?? 'Mod', style: const TextStyle(fontSize: 10, color: Colors.white)),
                                                      backgroundColor: StardewColors.iridiumPurple.withValues(alpha: 0.4),
                                                      visualDensity: VisualDensity.compact,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Text('Cumpleaños: ${v.season} Día ${v.day}', style: const TextStyle(fontSize: 12, color: StardewColors.textMuted)),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Amistad & Corazones
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: List.generate(10, (hIndex) {
                                              return Icon(
                                                hIndex < hearts ? Icons.favorite : Icons.favorite_border,
                                                color: hIndex < hearts ? StardewColors.rubyRed : StardewColors.textMuted,
                                                size: 16,
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$hearts / 10 Corazones ($points pts)',
                                            style: const TextStyle(fontSize: 11, color: StardewColors.primaryGold, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                            const Divider(height: 20),

                            // Regalos Favoritos (Loved Gifts)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('🎁 Regalos Favoritos:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: StardewColors.primaryGold)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: v.lovedGifts.map((gift) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: StardewColors.emeraldGreen.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: StardewColors.emeraldGreen.withValues(alpha: 0.4)),
                                        ),
                                        child: Text(
                                          gift,
                                          style: const TextStyle(fontSize: 11, color: StardewColors.textBright),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL DE DETALLES DEL DÍA DEL CALENDARIO ---
  void _showDayDetailsModal(
    BuildContext context,
    int dayNumber,
    String season,
    List<Map<String, String>> events,
    List<Map<String, dynamic>> dayTasks,
    bool isTravelingCart,
    AppStateProvider provider,
  ) {
    final taskController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: StardewColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final plantedProvider = Provider.of<PlantedCropProvider>(context, listen: false);
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final currentDayTasks = provider.tasks.where((t) {
              if (t['day'] != dayNumber) return false;
              final tSeason = (t['season'] ?? '').toString().toLowerCase();
              final actSeason = season.toLowerCase();
              return tSeason == actSeason || tSeason == 'invernadero' || tSeason == 'general';
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: StardewColors.primaryGold, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Día $dayNumber de $season',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: StardewColors.primaryGold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: StardewColors.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  if (isTravelingCart)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: StardewColors.iridiumPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: StardewColors.iridiumPurple),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.shopping_cart, color: StardewColors.iridiumPurple),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '🛒 ¡El Carro Ambulante está abierto hoy al sur del Bosque Tiznado!',
                              style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Eventos & Cumpleaños
                  const Text('🎉 Eventos & Cumpleaños del Día:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: StardewColors.textBright)),
                  const SizedBox(height: 8),
                  if (events.isEmpty)
                    const Text('No hay festivales ni cumpleaños especiales agendados para hoy.', style: TextStyle(color: StardewColors.textMuted))
                  else
                    ...events.map((e) {
                      final villagerId = e['villagerId'];
                      VillagerModel? vObj;
                      if (villagerId != null) {
                        vObj = DefaultStardewData.defaultVillagers.firstWhere((v) => v.id == villagerId, orElse: () => DefaultStardewData.defaultVillagers.first);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: e['type'] == 'festival' ? StardewColors.rubyRed.withValues(alpha: 0.2) : StardewColors.primaryGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                            if (vObj != null) ...[
                              const SizedBox(height: 6),
                              Text('🎁 Regalos Favoritos: ${vObj.lovedGifts.join(", ")}', style: const TextStyle(fontSize: 12, color: StardewColors.emeraldGreen)),
                            ],
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 16),
                  const Text('📌 Tareas del Día:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: StardewColors.textBright)),
                  const SizedBox(height: 8),
                  if (currentDayTasks.isEmpty)
                    const Text('No tienes tareas registradas para este día.', style: TextStyle(color: StardewColors.textMuted))
                  else
                    ...currentDayTasks.map((t) => Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(t['title'], style: TextStyle(decoration: t['isCompleted'] == 1 ? TextDecoration.lineThrough : null)),
                                value: t['isCompleted'] == 1,
                                onChanged: (val) async {
                                  await provider.toggleTask(t['id'], t['isCompleted'] == 1);
                                  setModalState(() {});
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              tooltip: 'Eliminar tarea',
                              onPressed: () {
                                _confirmDeleteTaskOrBatch(
                                  context: context,
                                  task: t,
                                  provider: provider,
                                  plantedProvider: plantedProvider,
                                  onRefreshModal: () => setModalState(() {}),
                                );
                              },
                            ),
                          ],
                        )),

                  const SizedBox(height: 16),
                  // Agregar Tarea Rápidamente
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taskController,
                          style: const TextStyle(color: StardewColors.textBright),
                          decoration: const InputDecoration(
                            hintText: 'Nueva tarea para este día...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (taskController.text.isNotEmpty) {
                            await provider.addTask(
                              title: taskController.text,
                              season: season,
                              day: dayNumber,
                            );
                            taskController.clear();
                            setModalState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: StardewColors.primaryGold, foregroundColor: Colors.black),
                        child: const Text('Agregar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTaskOrBatch({
    required BuildContext context,
    required Map<String, dynamic> task,
    required AppStateProvider provider,
    required PlantedCropProvider plantedProvider,
    required VoidCallback onRefreshModal,
  }) {
    final title = task['title']?.toString() ?? '';
    final isHarvest = title.contains('Cosecha');

    String? cropName;
    if (isHarvest) {
      final parts = title.replaceFirst('🌾 Cosecha:', '').trim();
      if (parts.contains('(')) {
        cropName = parts.split('(').first.trim();
      } else {
        cropName = parts.trim();
      }
    }

    PlantedCropBatch? matchingBatch;
    if (cropName != null && cropName.isNotEmpty) {
      try {
        matchingBatch = plantedProvider.batches.firstWhere(
          (b) => b.cropName.toLowerCase() == cropName!.toLowerCase(),
        );
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: StardewColors.cardBackground,
        title: const Text('Eliminar Tarea o Cultivo', style: TextStyle(color: StardewColors.primaryGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Cómo deseas proceder con "${task['title']}"?'),
            const SizedBox(height: 12),
            if (matchingBatch != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StardewColors.primaryGold.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: StardewColors.primaryGold.withAlpha(80)),
                ),
                child: Text(
                  '🌱 Lote detectado en la granja: ${matchingBatch.cropName} (${matchingBatch.quantity} parcelas)',
                  style: const TextStyle(fontSize: 12, color: StardewColors.primaryGold, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: StardewColors.cardBorder),
            onPressed: () async {
              await provider.deleteTask(task['id']);
              if (dlgCtx.mounted) Navigator.pop(dlgCtx);
              onRefreshModal();
            },
            child: const Text('Solo esta fecha'),
          ),
          if (matchingBatch != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                if (matchingBatch!.id != null) {
                  await plantedProvider.deleteBatch(matchingBatch.id!);
                }
                final targetName = matchingBatch.cropName.toLowerCase();
                for (var t in List.from(provider.tasks)) {
                  final tTitle = (t['title'] ?? '').toString().toLowerCase();
                  if (tTitle.contains(targetName)) {
                    await provider.deleteTask(t['id']);
                  }
                }
                if (dlgCtx.mounted) Navigator.pop(dlgCtx);
                onRefreshModal();
              },
              child: const Text('Eliminar Cultivo Completo'),
            ),
        ],
      ),
    );
  }

  // --- MODAL DE PERFIL DEL ALDEANO & REGALOS ---
  void _showVillagerDetailsModal(BuildContext context, VillagerModel villager, VillagerFriendship? friendship) {
    final points = friendship?.points ?? 0;
    final hearts = friendship?.hearts ?? (points ~/ 250);

    showModalBottomSheet(
      context: context,
      backgroundColor: StardewColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  VillagerAvatar(
                    name: villager.name,
                    isDatable: villager.isDatable,
                    isModded: villager.isModded,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(villager.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: StardewColors.primaryGold)),
                        const SizedBox(height: 4),
                        Text('🎉 Cumpleaños: ${villager.season} Día ${villager.day}', style: const TextStyle(color: StardewColors.textMuted)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(villager.isDatable ? '❤️ Candidato Matrimonio' : '🏡 Aldeano', style: const TextStyle(fontSize: 11, color: Colors.white)),
                              backgroundColor: villager.isDatable ? StardewColors.rubyRed.withValues(alpha: 0.4) : StardewColors.cardBorder,
                              visualDensity: VisualDensity.compact,
                            ),
                            if (villager.isModded) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(villager.sourceMod ?? 'Mod', style: const TextStyle(fontSize: 11, color: Colors.white)),
                                backgroundColor: StardewColors.iridiumPurple.withValues(alpha: 0.4),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Progreso de Amistad de la Partida
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: StardewColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StardewColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Progreso de Amistad en tu Granja:', style: TextStyle(fontWeight: FontWeight.bold, color: StardewColors.textBright)),
                        Text('$hearts / 10 Corazones', style: const TextStyle(color: StardewColors.primaryGold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(10, (hIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Icon(
                            hIndex < hearts ? Icons.favorite : Icons.favorite_border,
                            color: hIndex < hearts ? StardewColors.rubyRed : StardewColors.textMuted,
                            size: 20,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text('$points Puntos de Amistad acumulados (250 pts por corazón)', style: const TextStyle(fontSize: 12, color: StardewColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Regalos Favoritos
              const Text('🎁 Regalos Favoritos (Loved Gifts):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StardewColors.primaryGold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: villager.lovedGifts.map((gift) {
                  return Chip(
                    avatar: const Icon(Icons.card_giftcard, size: 16, color: StardewColors.emeraldGreen),
                    label: Text(gift, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    backgroundColor: StardewColors.emeraldGreen.withValues(alpha: 0.25),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: StardewColors.iridiumPurple, foregroundColor: Colors.white),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
