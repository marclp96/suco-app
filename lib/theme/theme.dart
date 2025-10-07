import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Colores principales de SUCO
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color accent = Color(0xFFCBFBC7);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color grey = Colors.grey;

  // 🖋️ Tipografías globales
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      useMaterial3: false,
      colorScheme: ColorScheme.dark(
        background: background,
        surface: surface,
        primary: accent,
        secondary: accent,
      ),
      textTheme: const TextTheme(
        // Titulares grandes (páginas, headers)
        headlineLarge: TextStyle(
          fontFamily: 'NeueHaasUnica',
          fontWeight: FontWeight.w800,
          fontSize: 28,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'NeueHaasUnica',
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'NeueHaasUnica',
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: textPrimary,
        ),

        // Subtítulos o etiquetas secundarias
        titleLarge: TextStyle(
          fontFamily: 'BDOGrotesk',
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'BDOGrotesk',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: textSecondary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'BDOGrotesk',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: textSecondary,
        ),

        // Cuerpo de texto
        bodyLarge: TextStyle(
          fontFamily: 'BDOGrotesk',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'BDOGrotesk',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'BDOGrotesk',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: textSecondary,
        ),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontFamily: 'BDOGrotesk',
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: Colors.white, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: 'BDOGrotesk',
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: 'BDOGrotesk',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'NeueHaasUnica',
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }
}
