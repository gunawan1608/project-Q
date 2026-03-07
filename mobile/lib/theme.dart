import 'package:flutter/material.dart';

class AppTheme {
  // ── Base palette (Light) ─────────────────────────────────────────────────
  static const Color green900 = Color(0xFF064E3B);
  static const Color green800 = Color(0xFF065F46);
  static const Color green700 = Color(0xFF047857);
  static const Color green600 = Color(0xFF059669);
  static const Color green500 = Color(0xFF10B981);
  static const Color green100 = Color(0xFFD1FAE5);
  static const Color bg       = Color(0xFFF0FDF9);
  static const Color bgCard   = Color(0xFFFFFFFF);

  // ── Dark palette ─────────────────────────────────────────────────────────
  static const Color darkBg       = Color(0xFF0A0F0D);
  static const Color darkSurface  = Color(0xFF111815);
  static const Color darkCard     = Color(0xFF182420);
  static const Color darkElevated = Color(0xFF1E2D28);
  static const Color darkBorder   = Color(0xFF2A3F38);
  static const Color darkText     = Color(0xFFE6F4EF);
  static const Color darkSubtext  = Color(0xFF8AADA4);

  // ── Semantic aliases ─────────────────────────────────────────────────────
  static const Color accent      = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);
  static const Color gold        = Color(0xFFF59E0B);
  static const Color goldLight   = Color(0xFFFCD34D);
  static const Color error       = Color(0xFFEF4444);

  // ── Alpha variants ───────────────────────────────────────────────────────
  static const Color green900op90 = Color(0xE6064E3B);
  static const Color green900op85 = Color(0xD9064E3B);
  static const Color green900op70 = Color(0xB3064E3B);
  static const Color green900op55 = Color(0x8C064E3B);
  static const Color green900op40 = Color(0x66064E3B);
  static const Color green900op30 = Color(0x4D064E3B);
  static const Color green900op20 = Color(0x33064E3B);
  static const Color green900op12 = Color(0x1F064E3B);
  static const Color green900op08 = Color(0x14064E3B);
  static const Color green900op06 = Color(0x0F064E3B);

  static const Color green800op30 = Color(0x4D065F46);
  static const Color green800op15 = Color(0x26065F46);
  static const Color green800op10 = Color(0x1A065F46);
  static const Color green800op07 = Color(0x12065F46);

  static const Color accentop20 = Color(0x3310B981);
  static const Color accentop10 = Color(0x1A10B981);

  static const Color white90 = Color(0xE6FFFFFF);
  static const Color white75 = Color(0xBFFFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white08 = Color(0x14FFFFFF);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF065F46), Color(0xFF064E3B)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF047857)],
  );

  static const LinearGradient badgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0FDF9), Color(0xFFECFDF5), Color(0xFFF0FDF9)],
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0F0D), Color(0xFF0D1612), Color(0xFF0A0F0D)],
  );

  // ── Text Styles ───────────────────────────────────────────────────────────
  static const TextStyle arabicAyah = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 28,
    height: 2.4,
    color: green900,
    letterSpacing: 0.3,
  );

  static const TextStyle arabicAyahDark = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 28,
    height: 2.4,
    color: darkText,
    letterSpacing: 0.3,
  );

  static const TextStyle arabicHero = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 38,
    height: 1.6,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle arabicBismillah = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 26,
    height: 2.0,
    color: green800,
    letterSpacing: 0.5,
  );

  static const TextStyle arabicBismillahDark = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 26,
    height: 2.0,
    color: accentLight,
    letterSpacing: 0.5,
  );

  static const TextStyle arabicListTile = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22,
    height: 1.5,
    color: green800,
  );

  static const TextStyle arabicListTileDark = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22,
    height: 1.5,
    color: accentLight,
  );

  static const TextStyle latinAyah = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    height: 1.9,
    fontStyle: FontStyle.italic,
    color: green900op70,
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
    letterSpacing: 0.8,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: green900op08, thickness: 1, space: 1),
      textTheme: base.textTheme.copyWith(
        titleLarge:  base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: green900),
        titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: green900),
        bodyLarge:   base.textTheme.bodyLarge?.copyWith(color: green900op90),
        bodyMedium:  base.textTheme.bodyMedium?.copyWith(color: green900op85),
        labelLarge:  base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: green600,
        brightness: Brightness.dark,
      ).copyWith(
        surface: darkBg,
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: darkBg,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: darkText,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: darkCard,
        surfaceTintColor: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1, space: 1),
      textTheme: base.textTheme.copyWith(
        titleLarge:  base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: darkText),
        titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: darkText),
        bodyLarge:   base.textTheme.bodyLarge?.copyWith(color: darkText),
        bodyMedium:  base.textTheme.bodyMedium?.copyWith(color: darkSubtext),
        labelLarge:  base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}