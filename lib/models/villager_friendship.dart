/// Datos de amistad del granjero con un aldeano.
///
/// Extraído de [save_data.dart] para que cada entidad tenga su propio archivo.
class VillagerFriendship {
  final String name;
  final int points;
  final int hearts; // points / 250
  final bool isModded;

  const VillagerFriendship({
    required this.name,
    required this.points,
    required this.hearts,
    this.isModded = false,
  });
}
