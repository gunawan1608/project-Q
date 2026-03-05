import 'package:flutter/material.dart';

class AppTheme {
  // ── Base palette ────────────────────────────────────────────────────────
  static const Color green900 = Color(0xFF064E3B);
  static const Color green800 = Color(0xFF065F46);
  static const Color green600 = Color(0xFF16A34A);
  static const Color bg       = Color(0xFFF3FBF6);

  // ── Pre-computed green900 + alpha ────────────────────────────────────────
  static const Color green900op90 = Color(0xE6064E3B);
  static const Color green900op85 = Color(0xD9064E3B);
  static const Color green900op82 = Color(0xD1064E3B);
  static const Color green900op68 = Color(0xAD064E3B);
  static const Color green900op55 = Color(0x8C064E3B);
  static const Color green900op50 = Color(0x80064E3B);
  static const Color green900op45 = Color(0x73064E3B);
  static const Color green900op40 = Color(0x66064E3B);
  static const Color green900op38 = Color(0x61064E3B);
  static const Color green900op08 = Color(0x14064E3B);
  static const Color green900op07 = Color(0x12064E3B);
  static const Color green900op06 = Color(0x0F064E3B);

  // ── Pre-computed green800 + alpha ────────────────────────────────────────
  static const Color green800op35  = Color(0x59065F46);
  static const Color green800op30  = Color(0x4D065F46);
  static const Color green800op12  = Color(0x1F065F46);
  static const Color green800op10  = Color(0x1A065F46);
  static const Color green800op07  = Color(0x12065F46);
  static const Color green800op045 = Color(0x0B065F46);

  // ── Pre-computed green600 + alpha ────────────────────────────────────────
  static const Color green600op65 = Color(0xA616A34A);

  // ── Pre-computed white + alpha ───────────────────────────────────────────
  static const Color white90 = Color(0xE6FFFFFF);
  static const Color white85 = Color(0xD9FFFFFF);
  static const Color white75 = Color(0xBFFFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);

  // ── Const gradients ──────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green800, green900],
  );

  static const LinearGradient badgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green800, green600],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8FDF0), bg, Color(0xFFF7FFFA)],
  );

  // ── Const BoxDecoration ───────────────────────────────────────────────────
  static const BoxDecoration heroBgDecoration = BoxDecoration(
    gradient: heroGradient,
  );

  // ── Const TextStyles (zero allocation per build) ──────────────────────────
  static const TextStyle arabicAyah = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 26,
    height: 2.3,
    color: green900,
    letterSpacing: 0.3,
  );

  static const TextStyle arabicHero = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 36,
    height: 1.6,
    color: Colors.white,
  );

  static const TextStyle arabicBismillah = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    height: 2.0,
    color: green800,
    letterSpacing: 0.5,
  );

  static const TextStyle arabicListTile = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 20,
    height: 1.5,
    color: green800,
  );

  static const TextStyle latinAyah = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    height: 1.9,
    fontStyle: FontStyle.italic,
    color: green900op68,
    letterSpacing: 0.1,
  );

  static const TextStyle translationAyah = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    height: 1.8,
    color: green900op85,
    letterSpacing: 0.1,
  );

  static const TextStyle ayahBadgeNumber = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static const TextStyle pillLabel = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  // ── ThemeData ─────────────────────────────────────────────────────────────
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: green900op08,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700, color: green900),
        titleMedium: base.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w600, color: green900),
        bodyLarge:  base.textTheme.bodyLarge?.copyWith(color: green900op90),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(color: green900op85),
        labelLarge: base.textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}