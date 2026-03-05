import 'package:flutter/material.dart';
import '../theme.dart';

class GreenBackground extends StatelessWidget {
  const GreenBackground({super.key, required this.child});

  final Widget child;

  static final _PatternPainter _painter = _PatternPainter();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
            child: CustomPaint(
              painter: _painter,
              child: const SizedBox.expand(),
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Paint _dotPaint = Paint()
    ..color = const Color(0x09064E3B) 
    ..isAntiAlias = false; 

  @override
  void paint(Canvas canvas, Size size) {
    const double step = 48.0;
    const double radius = 10.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        canvas.drawCircle(Offset(x, y), radius, _dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}