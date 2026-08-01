class VillagerModel {
  final String id;
  final String name;
  final String season;
  final int day;
  final List<String> lovedGifts;
  final bool isDatable;
  final bool isModded;
  final String? sourceMod;

  const VillagerModel({
    required this.id,
    required this.name,
    required this.season,
    required this.day,
    required this.lovedGifts,
    this.isDatable = false,
    this.isModded = false,
    this.sourceMod,
  });
}
