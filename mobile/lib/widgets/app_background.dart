import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Static background — paints once, never repaints.
/// SafeArea is pushed outside so the child gets the full safe insets.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  // shared painters — created once per app lifetime
  static final _LightPainter _light = _LightPainter();
  static final _DarkPainter  _dark  = _DarkPainter();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(children: [
      // background layer — RepaintBoundary so it never triggers child repaints
      RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark ? AppTheme.darkBgGradient : AppTheme.bgGradient,
          ),
          child: CustomPaint(
            painter: isDark ? _dark : _light,
            child: const SizedBox.expand(),
          ),
        ),
      ),
      SafeArea(child: child),
    ]);
  }
}

class _LightPainter extends CustomPainter {
  final Paint _p = Paint()
    ..color = const Color(0x06064E3B)
    ..isAntiAlias = false;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 52.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 2, _p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _DarkPainter extends CustomPainter {
  final Paint _p = Paint()
    ..color = const Color(0x0A10B981)
    ..isAntiAlias = false;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 52.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.5, _p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}