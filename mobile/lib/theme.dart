import 'package:flutter/material.dart';

class AppTheme {
  static const Color green900 = Color(0xFF064E3B);
  static const Color green800 = Color(0xFF065F46);
  static const Color green600 = Color(0xFF16A34A);
  static const Color bg = Color(0xFFF3FBF6);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: green800,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: bg,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: green900,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: green900.withOpacity(0.08),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: green900,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: green900,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: green900.withOpacity(0.9),
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: green900.withOpacity(0.85),
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
