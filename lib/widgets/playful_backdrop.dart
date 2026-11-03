import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Sky, sun, drifting clouds, floating confetti and rolling hills: the
/// scenery behind the splash and title screens. Stays still when
/// [animate] is false (reduced motion).
class PlayfulBackdrop extends StatefulWidget {
  const PlayfulBackdrop({super.key, required this.animate, this.child});

  final bool animate;
  final Widget? child;

  /// The top colour of the sky; the native launch screens use it too.
  static const skyTop = Color(0xFFBFE6FF);

  @override
  State<PlayfulBackdrop> createState() => _PlayfulBackdropState();
}

class _PlayfulBackdropState extends State<PlayfulBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _t.repeat();
  }

  @override
  void didUpdateWidget(PlayfulBackdrop old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_t.isAnimating) _t.repeat();
    if (!widget.animate) _t.stop();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [PlayfulBackdrop.skyTop, AppColors.cream],
          stops: [0, 0.7],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: RepaintBoundary(child: CustomPaint(painter: _BackdropPainter(_t))),
          ),
          ?widget.child,
        ],
      ),
    );
  }
}

class _Confetti {
  const _Confetti(this.x, this.y, this.size, this.color, this.star, this.phase);

  final double x, y, size, phase;
  final Color color;
  final bool star;
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  static final List<_Confetti> _confetti = () {
    final r = math.Random(7);
    const palette = [
      AppColors.coral,
      AppColors.skyDeep,
      AppColors.lavenderDeep,
      AppColors.mintDeep,
      Color(0xFFF5B800),
      Color(0xFFFF9EB5),
    ];
    return [
      for (var i = 0; i < 16; i++)
        _Confetti(
          r.nextDouble(),
          0.08 + r.nextDouble() * 0.7,
          6 + r.nextDouble() * 9,
          palette[i % palette.length],
          i.isEven,
          r.nextDouble(),
        ),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    final unit = size.shortestSide;
    _sun(canvas, Offset(size.width * 0.12, size.height * 0.08), unit * 0.08, v);
    for (final (y, scale, speed, offset) in const [
      (0.07, 1.0, 1.0, 0.1),
      (0.2, 0.75, 2.0, 0.55),
      (0.33, 0.6, 1.0, 0.85),
    ]) {
      final span = size.width + unit * 0.6;
      final x = ((offset + v * speed) % 1) * span - unit * 0.3;
      _cloud(canvas, Offset(x, size.height * y), unit * 0.11 * scale);
    }
    for (final c in _confetti) {
      final bob = math.sin((v * 6 + c.phase) * 2 * math.pi) * 8;
      final p = Offset(c.x * size.width, c.y * size.height + bob);
      final paint = Paint()..color = c.color.withValues(alpha: 0.5);
      if (c.star) {
        _star(canvas, p, c.size, (v * 4 + c.phase) * 2 * math.pi, paint);
      } else {
        canvas.drawCircle(p, c.size * 0.55, paint);
      }
    }
    _hills(canvas, size);
  }

  void _sun(Canvas canvas, Offset c, double r, double v) {
    final rays = Paint()
      ..color = const Color(0xFFFFC94D)
      ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * 2 * math.pi + v * 2 * math.pi;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * r * 1.3, c + d * r * 1.65, rays);
    }
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFD95C));
    canvas.drawCircle(c, r * 0.78, Paint()..color = const Color(0xFFFFE58A));
  }

  void _cloud(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: r * 3.4, height: r * 1.1), Radius.circular(r)),
      paint,
    );
    canvas.drawCircle(c + Offset(-r * 0.6, -r * 0.35), r * 0.7, paint);
    canvas.drawCircle(c + Offset(r * 0.35, -r * 0.55), r * 0.9, paint);
  }

  void _star(Canvas canvas, Offset c, double r, double angle, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = angle + i * math.pi / 5 - math.pi / 2;
      final rad = i.isEven ? r : r * 0.45;
      final p = c + Offset(math.cos(a), math.sin(a)) * rad;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  void _hills(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final hill = math.min(h * 0.16, 150.0);
    final back = Path()
      ..moveTo(0, h - hill * 0.75)
      ..quadraticBezierTo(w * 0.3, h - hill * 1.35, w * 0.62, h - hill * 0.8)
      ..quadraticBezierTo(w * 0.85, h - hill * 0.45, w, h - hill * 0.9)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = AppColors.mint);
    final front = Path()
      ..moveTo(0, h - hill * 0.35)
      ..quadraticBezierTo(w * 0.45, h - hill * 0.85, w, h - hill * 0.3)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF9FE3C3));

    // A few little flowers dotted on the front hill.
    for (final (fx, color) in const [
      (0.08, AppColors.coral),
      (0.27, Color(0xFFF5B800)),
      (0.73, AppColors.lavenderDeep),
      (0.92, Color(0xFFFF9EB5)),
    ]) {
      final x = w * fx;
      // Height of the front hill's curve at x (approximate quadratic).
      final s = fx;
      final y = (1 - s) * (1 - s) * (h - hill * 0.35) + 2 * (1 - s) * s * (h - hill * 0.85) + s * s * (h - hill * 0.3);
      final p = Offset(x, y + 6);
      final petal = Paint()..color = color;
      for (var i = 0; i < 5; i++) {
        final a = i / 5 * 2 * math.pi;
        canvas.drawCircle(p + Offset(math.cos(a), math.sin(a)) * 5, 4, petal);
      }
      canvas.drawCircle(p, 3.5, Paint()..color = const Color(0xFFFFE58A));
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => oldDelegate.t != t;
}
