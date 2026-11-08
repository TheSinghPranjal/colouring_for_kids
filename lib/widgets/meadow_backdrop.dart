import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bright garden scenery behind the Pick a Picture screens: blue sky,
/// drifting clouds, a leafy branch, a tree line with a wooden fence and a
/// flowery meadow. Clouds stay still when [animate] is false.
class MeadowBackdrop extends StatefulWidget {
  const MeadowBackdrop({super.key, required this.animate, this.horizon = 0.42, this.child});

  final bool animate;

  /// Where the meadow starts, as a fraction of the height.
  final double horizon;
  final Widget? child;

  @override
  State<MeadowBackdrop> createState() => _MeadowBackdropState();
}

class _MeadowBackdropState extends State<MeadowBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 60));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _t.repeat();
  }

  @override
  void didUpdateWidget(MeadowBackdrop old) {
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
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          child: RepaintBoundary(child: CustomPaint(painter: _MeadowPainter(_t, widget.horizon))),
        ),
        ?widget.child,
      ],
    );
  }
}

class _MeadowPainter extends CustomPainter {
  _MeadowPainter(this.t, this.horizon) : super(repaint: t);

  final Animation<double> t;
  final double horizon;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final hy = h * horizon;
    final unit = math.min(w, 600.0);

    // Sky.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF2E9BEF), Color(0xFF7CC9FB), Color(0xFFD4F0FF)],
          stops: [0, horizon * 0.6, horizon],
        ).createShader(Rect.fromLTWH(0, 0, w, hy + 1)),
    );

    _sun(canvas, Offset(unit * 0.2, unit * 0.13), unit * 0.075);

    // Clouds drift slowly to the right.
    for (final (y, scale, offset) in const [
      (0.07, 1.0, 0.72),
      (0.17, 0.8, 0.05),
      (0.27, 0.7, 0.45),
      (0.13, 0.55, 0.3),
    ]) {
      final span = w + unit * 0.5;
      final x = ((offset + t.value) % 1) * span - unit * 0.25;
      _cloud(canvas, Offset(x, h * y), unit * 0.09 * scale);
    }

    _treeLine(canvas, w, hy, unit);
    _fence(canvas, w, hy, unit);

    // Meadow with a lighter rolling hill on top.
    final meadow = Path()
      ..moveTo(0, hy + unit * 0.02)
      ..quadraticBezierTo(w * 0.35, hy - unit * 0.05, w * 0.7, hy + unit * 0.01)
      ..quadraticBezierTo(w * 0.88, hy + unit * 0.04, w, hy - unit * 0.01)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      meadow,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9BDB5E), AppColors.grass, Color(0xFF5BB83A)],
          stops: [0, 0.3, 1],
        ).createShader(Rect.fromLTWH(0, hy - unit * 0.05, w, h - hy)),
    );
    final glow = Path()
      ..moveTo(0, hy + unit * 0.12)
      ..quadraticBezierTo(w * 0.5, hy + unit * 0.02, w, hy + unit * 0.14)
      ..lineTo(w, hy + unit * 0.22)
      ..quadraticBezierTo(w * 0.5, hy + unit * 0.1, 0, hy + unit * 0.2)
      ..close();
    canvas.drawPath(glow, Paint()..color = Colors.white.withValues(alpha: 0.12));

    _path(canvas, w, h, hy, unit);
    for (final (fx, fy, scale) in [(0.0, 0.18, 1.0), (0.06, 0.42, 0.8), (1.0, 0.22, 0.95), (0.95, 0.48, 0.75)]) {
      _tree(canvas, Offset(w * fx, hy + (h - hy) * fy), unit * 0.09 * scale);
    }

    // Grass tufts and flowers scattered over the meadow.
    final rnd = math.Random(11);
    for (var i = 0; i < 26; i++) {
      final p = Offset(rnd.nextDouble() * w, hy + unit * 0.06 + rnd.nextDouble() * (h - hy - unit * 0.06));
      _tuft(canvas, p, unit * 0.022);
    }
    const petals = [Color(0xFFFF8FC0), Color(0xFFFFD43B), Colors.white, Color(0xFFFF7FA8), Color(0xFFB79CFF)];
    for (var i = 0; i < 14; i++) {
      final edge = i.isEven;
      final x = edge
          ? (rnd.nextBool() ? rnd.nextDouble() * w * 0.12 : w - rnd.nextDouble() * w * 0.12)
          : rnd.nextDouble() * w;
      final y = hy + unit * 0.05 + rnd.nextDouble() * (h - hy - unit * 0.08);
      _flower(canvas, Offset(x, y), unit * (0.011 + rnd.nextDouble() * 0.006), petals[i % petals.length]);
    }

    _branch(canvas, unit);
    canvas
      ..save()
      ..translate(w, 0)
      ..scale(-0.8, 0.8);
    _branch(canvas, unit);
    canvas.restore();
    _cornerBushes(canvas, w, h, unit);
  }

  void _sun(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r * 1.9, Paint()..color = const Color(0xFFFFF3B0).withValues(alpha: 0.35));
    final rays = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = r * 0.14
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * 2 * math.pi;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * r * 1.25, c + d * r * 1.55, rays);
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFCA28)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  /// A sandy path winding up from the bottom of the screen.
  void _path(Canvas canvas, double w, double h, double hy, double unit) {
    final top = hy + (h - hy) * 0.45;
    final path = Path()
      ..moveTo(w * 0.36, h)
      ..cubicTo(w * 0.42, h - (h - top) * 0.4, w * 0.62, h - (h - top) * 0.6, w * 0.5, top)
      ..lineTo(w * 0.53, top)
      ..cubicTo(w * 0.7, h - (h - top) * 0.6, w * 0.6, h - (h - top) * 0.35, w * 0.66, h)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3DFA2), Color(0xFFE8C77E)],
        ).createShader(Rect.fromLTWH(0, top, w, h - top)),
    );
  }

  /// A round leafy tree standing at [base].
  void _tree(Canvas canvas, Offset base, double r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: base + Offset(0, -r * 0.6), width: r * 0.32, height: r * 1.4),
        Radius.circular(r * 0.1),
      ),
      Paint()..color = const Color(0xFF8A5A2B),
    );
    final dark = Paint()..color = const Color(0xFF3E9E2E);
    final light = Paint()..color = const Color(0xFF5DBB3F);
    canvas.drawCircle(base + Offset(-r * 0.45, -r * 1.5), r * 0.75, dark);
    canvas.drawCircle(base + Offset(r * 0.45, -r * 1.55), r * 0.75, dark);
    canvas.drawCircle(base + Offset(0, -r * 2.15), r * 0.85, light);
    canvas.drawCircle(base + Offset(-r * 0.2, -r * 2.3), r * 0.35, Paint()..color = const Color(0xFF8BD45A));
  }

  void _cloud(Canvas canvas, Offset c, double r) {
    final shade = Paint()..color = const Color(0xFFDDEFFC);
    final paint = Paint()..color = Colors.white;
    for (final (dx, dy, rr, p) in [
      (0.0, 0.12, 1.0, shade),
      (-1.1, 0.0, 0.75, paint),
      (-0.3, -0.45, 0.95, paint),
      (0.75, -0.2, 0.8, paint),
      (1.4, 0.15, 0.6, paint),
    ]) {
      canvas.drawCircle(c + Offset(dx * r, dy * r), rr * r, p);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(c.dx - r * 1.7, c.dy, c.dx + r * 2.0, c.dy + r * 0.75),
        Radius.circular(r * 0.4),
      ),
      paint,
    );
  }

  void _treeLine(Canvas canvas, double w, double hy, double unit) {
    final back = Paint()..color = const Color(0xFF4FA83A);
    final front = Paint()..color = const Color(0xFF66BF45);
    final r = unit * 0.07;
    for (var x = -r; x < w + r; x += r * 1.3) {
      final bump = math.sin(x * 0.05) * r * 0.25;
      canvas.drawCircle(Offset(x, hy - r * 0.35 + bump), r, back);
    }
    for (var x = -r * 0.5; x < w + r; x += r * 1.6) {
      final bump = math.cos(x * 0.04) * r * 0.2;
      canvas.drawCircle(Offset(x, hy + r * 0.05 + bump), r * 0.8, front);
    }
  }

  void _fence(Canvas canvas, double w, double hy, double unit) {
    final wood = Paint()..color = const Color(0xFFE0A964);
    final edge = Paint()
      ..color = const Color(0xFFA8692E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final postW = unit * 0.022, postH = unit * 0.1;
    final left = w * 0.7, base = hy + unit * 0.03;
    for (final y in [base - postH * 0.75, base - postH * 0.38]) {
      final rail = RRect.fromRectAndRadius(
        Rect.fromLTWH(left - postW, y, w - left + postW * 2, postH * 0.14),
        const Radius.circular(3),
      );
      canvas.drawRRect(rail, wood);
      canvas.drawRRect(rail, edge);
    }
    for (var x = left; x < w + postW; x += postW * 3.4) {
      final post = Path()
        ..moveTo(x, base)
        ..lineTo(x, base - postH)
        ..lineTo(x + postW / 2, base - postH - postW * 0.6)
        ..lineTo(x + postW, base - postH)
        ..lineTo(x + postW, base)
        ..close();
      canvas.drawPath(post, wood);
      canvas.drawPath(post, edge);
    }
  }

  void _tuft(Canvas canvas, Offset p, double s) {
    final paint = Paint()
      ..color = AppColors.grassDeep.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.3
      ..strokeCap = StrokeCap.round;
    for (final a in const [-0.5, 0.0, 0.5]) {
      canvas.drawLine(p, p + Offset(math.sin(a) * s, -math.cos(a) * s * (a == 0 ? 1.3 : 1)), paint);
    }
  }

  void _flower(Canvas canvas, Offset c, double r, Color color) {
    final petal = Paint()..color = color;
    for (var i = 0; i < 5; i++) {
      final a = i / 5 * 2 * math.pi;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, r * 0.8, petal);
    }
    canvas.drawCircle(c, r * 0.65, Paint()..color = const Color(0xFFFFB300));
  }

  void _leaf(Canvas canvas, Offset c, double len, double angle, Color color) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.5, -len * 0.38, len, 0)
      ..quadraticBezierTo(len * 0.5, len * 0.38, 0, 0)
      ..close();
    canvas.drawPath(leaf, Paint()..color = color);
    canvas.drawLine(
      Offset.zero,
      Offset(len * 0.85, 0),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..strokeWidth = 1.2,
    );
    canvas.restore();
  }

  /// A leafy branch reaching in from the top-left corner.
  void _branch(Canvas canvas, double unit) {
    final s = unit / 400;
    final branch = Path()
      ..moveTo(-10 * s, 40 * s)
      ..quadraticBezierTo(50 * s, 18 * s, 125 * s, -6 * s);
    canvas.drawPath(
      branch,
      Paint()
        ..color = const Color(0xFF8A5A2B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * s
        ..strokeCap = StrokeCap.round,
    );
    const light = Color(0xFF9BE15D), dark = Color(0xFF5DBB3F);
    for (final (x, y, a, l, c) in const [
      (-4.0, 52.0, 1.2, 26.0, dark),
      (12.0, 36.0, 1.9, 24.0, light),
      (22.0, 34.0, 0.9, 28.0, dark),
      (38.0, 26.0, -0.6, 26.0, light),
      (50.0, 22.0, 1.4, 25.0, light),
      (64.0, 15.0, 0.4, 27.0, dark),
      (80.0, 10.0, -0.9, 22.0, dark),
      (90.0, 6.0, 1.1, 24.0, light),
      (106.0, 1.0, 0.2, 22.0, light),
      (6.0, 44.0, 0.2, 24.0, light),
    ]) {
      _leaf(canvas, Offset(x * s, y * s), l * s, a, c);
    }
  }

  void _cornerBushes(Canvas canvas, double w, double h, double unit) {
    final dark = Paint()..color = const Color(0xFF3F9E2F);
    final light = Paint()..color = const Color(0xFF58B83C);
    final r = unit * 0.075;
    for (final (cx, sign) in [(0.0, 1.0), (w, -1.0)]) {
      canvas.drawCircle(Offset(cx + sign * r * 0.2, h - r * 0.2), r * 1.4, dark);
      canvas.drawCircle(Offset(cx + sign * r * 1.4, h + r * 0.2), r * 1.1, light);
      canvas.drawCircle(Offset(cx - sign * r * 0.2, h - r * 1.2), r * 0.9, light);
    }
    _flower(canvas, Offset(w - r * 1.5, h - r * 1.1), unit * 0.02, Colors.white);
    _flower(canvas, Offset(r * 0.9, h - r * 1.6), unit * 0.018, const Color(0xFFFF8FC0));
  }

  @override
  bool shouldRepaint(covariant _MeadowPainter old) => old.t != t || old.horizon != horizon;
}
