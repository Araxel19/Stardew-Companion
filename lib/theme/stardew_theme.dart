import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum StardewThemeMode { iridium, gold, emerald, coral }

class StardewColors {
  static const Color background = Color(0xFF130F1A);
  static const Color cardBackground = Color(0xFF1F182A);
  static const Color cardBorder = Color(0xFF382A4A);
  static const Color primaryGold = Color(0xFFF59E0B);
  static const Color secondaryGold = Color(0xFFD97706);
  static const Color iridiumPurple = Color(0xFFA855F7);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color rubyRed = Color(0xFFEF4444);
  static const Color oceanBlue = Color(0xFF3B82F6);
  static const Color textBright = Color(0xFFF3F4F6);
  static const Color textMuted = Color(0xFF9CA3AF);
}

class StardewTheme {
  static ThemeData getTheme(StardewThemeMode mode) {
    Color primaryColor;
    Color secondaryColor;

    switch (mode) {
      case StardewThemeMode.iridium:
        primaryColor = StardewColors.iridiumPurple;
        secondaryColor = StardewColors.primaryGold;
        break;
      case StardewThemeMode.gold:
        primaryColor = StardewColors.primaryGold;
        secondaryColor = StardewColors.secondaryGold;
        break;
      case StardewThemeMode.emerald:
        primaryColor = StardewColors.emeraldGreen;
        secondaryColor = StardewColors.primaryGold;
        break;
      case StardewThemeMode.coral:
        primaryColor = const Color(0xFFF97316);
        secondaryColor = StardewColors.iridiumPurple;
        break;
    }

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: StardewColors.background,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: StardewColors.cardBackground,
        error: StardewColors.rubyRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: StardewColors.textBright, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.outfit(color: primaryColor, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.outfit(color: StardewColors.textBright),
        bodyMedium: GoogleFonts.outfit(color: StardewColors.textMuted),
      ),
      cardTheme: CardThemeData(
        color: StardewColors.cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) return primaryColor.withValues(alpha: 0.15);
            if (states.contains(WidgetState.pressed)) return primaryColor.withValues(alpha: 0.25);
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) return primaryColor.withValues(alpha: 0.15);
            return null;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) return primaryColor.withValues(alpha: 0.15);
            return null;
          }),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
        ),
      ),
      listTileTheme: ListTileThemeData(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
        iconColor: StardewColors.textMuted,
        selectedColor: primaryColor,
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: primaryColor.withValues(alpha: 0.25),
        unselectedIconTheme: const IconThemeData(color: StardewColors.textMuted, size: 24),
        selectedIconTheme: IconThemeData(color: secondaryColor, size: 26),
        unselectedLabelTextStyle: const TextStyle(color: StardewColors.textMuted),
        selectedLabelTextStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
        selectedItemColor: primaryColor,
        unselectedItemColor: StardewColors.textMuted,
      ),
      tabBarTheme: TabBarThemeData(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      ),
      popupMenuTheme: PopupMenuThemeData(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      ),
      dividerColor: StardewColors.cardBorder,
    );
  }
}
