// Constantes globales de Stardew Valley reutilizadas en múltiples capas.
// Centralizar aquí evita duplicar conjuntos y strings en servicios y modelos.

class StardewConstants {
  StardewConstants._(); // no instanciable

  /// Estaciones jugables
  static const List<String> seasons = [
    'Primavera',
    'Verano',
    'Otoño',
    'Invierno',
    'Invernadero',
  ];

  /// Aldeanos presentes en el juego vanilla (1.6).
  /// Usado para detectar personajes de mods.
  static const Set<String> vanillaVillagers = {
    'Abigail', 'Alex', 'Caroline', 'Clint', 'Demetrius', 'Dwarf',
    'Elliott', 'Emily', 'Evelyn', 'George', 'Gus', 'Haley', 'Harvey',
    'Jas', 'Jodi', 'Kent', 'Krobus', 'Leah', 'Leo', 'Lewis', 'Linus',
    'Marnie', 'Maru', 'Pam', 'Penny', 'Pierre', 'Robin', 'Sam',
    'Sandy', 'Sebastian', 'Shane', 'Vincent', 'Willy', 'Wizard',
  };

  /// Duración de una estación en días
  static const int seasonLength = 28;

  /// Puntos de amistad por corazón
  static const int pointsPerHeart = 250;
}
