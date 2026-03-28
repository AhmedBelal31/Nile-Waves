import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // App Colors exactly like the Dribbble design
  static const Color background = Color(0xFF2C313F); 
  static const Color surface = Color(0xFF2C313F);
  static const Color cardColor = Color(0xFF242936);
  static const Color primary = Color(0xFFFF3344); 
  static const Color textMain = Colors.white;
  static const Color textSecondary = Color(0xFF9FA3B0);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: cardColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textMain, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textMain),
        titleSmall: TextStyle(color: textMain),
        bodyLarge: TextStyle(color: textMain),
        bodyMedium: TextStyle(color: textMain),
        bodySmall: TextStyle(color: textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        elevation: 0,
      ),
    );
  }

  /// Provides dynamic text theme based on language
  static TextTheme getTextTheme(BuildContext context) {
    final base = Theme.of(context).textTheme;
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return GoogleFonts.cairoTextTheme(base);
    }
    return GoogleFonts.interTextTheme(base);
  }
}
