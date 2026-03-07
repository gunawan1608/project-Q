import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PressScale
// Uses TweenAnimationBuilder so there's zero AnimationController per widget.
// The tween drives a scale from 1.0 → [scale] on press and back.
// ─────────────────────────────────────────────────────────────────────────────

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale     = 0.94,
    this.downMs    = 80,
    this.upMs      = 200,
    this.haptic    = false,
    this.enabled   = true,
  });
  final Widget   child;
  final VoidCallback? onTap;
  final double   scale;
  final int      downMs, upMs;
  final bool     haptic, enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _onDown(_) {
    if (!widget.enabled) return;
    setState(() => _down = true);
  }

  void _onUp(_) {
    if (!widget.enabled) return;
    setState(() => _down = false);
    if (widget.haptic) HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _onCancel() {
    if (!widget.enabled) return;
    setState(() => _down = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:   HitTestBehavior.opaque,
      onTapDown:  widget.enabled ? _onDown   : null,
      onTapUp:    widget.enabled ? _onUp     : null,
      onTapCancel: widget.enabled ? _onCancel : null,
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          begin: _down ? 1.0 : widget.scale,
          end:   _down ? widget.scale : 1.0,
        ),
        duration: Duration(milliseconds: _down ? widget.downMs : widget.upMs),
        curve: _down ? Curves.easeIn : Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerScope + ShimmerBox
// One AnimationController at the scope level; all boxes share it.
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerScope extends StatefulWidget {
  const ShimmerScope({super.key, required this.child});
  final Widget child;

  static _ShimmerScopeState? _of(BuildContext ctx) =>
      ctx.findAncestorStateOfType<_ShimmerScopeState>();

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() { ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.height,
    required this.radius,
    required this.isDark,
    this.width = double.infinity,
  });
  final double height, radius, width;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final state = ShimmerScope._of(context);
    if (state == null) return SizedBox(height: height, width: width);

    final lo = isDark ? AppTheme.darkElevated : const Color(0xFFE2F5EC);
    final hi = isDark ? AppTheme.darkCard     : const Color(0xFFF6FEF9);

    return AnimatedBuilder(
      animation: state.ctrl,
      builder: (_, __) => Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: Color.lerp(lo, hi,
              Curves.easeInOut.transform(state.ctrl.value)),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SlidePageRoute  — shared page transition
// ─────────────────────────────────────────────────────────────────────────────

class SlidePageRoute extends PageRouteBuilder {
  SlidePageRoute({required Widget child})
      : super(
          pageBuilder:      (_, __, ___) => child,
          transitionDuration:        const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          transitionsBuilder: (_, anim, __, child) {
            final c = CurvedAnimation(
              parent: anim,
              curve:        Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: c,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end:   Offset.zero,
                ).animate(c),
                child: child,
              ),
            );
          },
        );
}