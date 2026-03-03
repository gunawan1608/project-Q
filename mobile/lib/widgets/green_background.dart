import 'package:flutter/material.dart';

import '../theme.dart';

class GreenBackground extends StatelessWidget {
  const GreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _Bg(),
        SafeArea(child: child),
      ],
    );
  }
}

class _Bg extends StatelessWidget {
  const _Bg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8FDF0),
            AppTheme.bg,
            Color(0xFFF7FFFA),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _PatternPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.green900.withOpacity(0.035);

    const double step = 48;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final center = Offset(x, y);
        canvas.drawCircle(center, 10, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
