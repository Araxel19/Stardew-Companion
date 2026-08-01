import 'package:flutter/material.dart';
import '../theme/stardew_theme.dart';

class VillagerAvatar extends StatelessWidget {
  final String name;
  final bool isDatable;
  final bool isModded;
  final double size;

  const VillagerAvatar({
    super.key,
    required this.name,
    this.isDatable = false,
    this.isModded = false,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgAccent;
    if (isDatable) {
      bgAccent = StardewColors.rubyRed;
    } else if (isModded) {
      bgAccent = StardewColors.iridiumPurple;
    } else {
      bgAccent = StardewColors.primaryGold;
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [bgAccent.withValues(alpha: 0.8), StardewColors.cardBackground],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: bgAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: bgAccent.withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/stardew_villagers_avatar.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
                Text(
                  initial,
                  style: TextStyle(
                    fontSize: size * 0.45,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isDatable)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: StardewColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite, size: size * 0.35, color: StardewColors.rubyRed),
            ),
          ),
      ],
    );
  }
}

class CropAvatar extends StatelessWidget {
  final String name;
  final String season;
  final bool isModded;
  final double size;

  const CropAvatar({
    super.key,
    required this.name,
    required this.season,
    this.isModded = false,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color seasonColor;
    switch (season.toLowerCase()) {
      case 'primavera':
      case 'spring':
        seasonColor = StardewColors.emeraldGreen;
        break;
      case 'verano':
      case 'summer':
        seasonColor = StardewColors.primaryGold;
        break;
      case 'otoño':
      case 'fall':
        seasonColor = const Color(0xFFEA580C);
        break;
      default:
        seasonColor = StardewColors.oceanBlue;
        break;
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '🌱';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [seasonColor.withValues(alpha: 0.8), StardewColors.cardBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: seasonColor, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: seasonColor.withValues(alpha: 0.25),
            blurRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/stardew_crops_avatar.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
            Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
