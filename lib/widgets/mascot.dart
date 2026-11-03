import 'dart:math' as math;

import 'package:flutter/material.dart';

/// "Sprout", the app's mascot: a cheerful paint drop with a little leaf.
class Mascot extends StatefulWidget {
  const Mascot({super.key, this.size = 120, this.animate = true});

  final double size;
  final bool animate;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _bob.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(Mascot old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_bob.isAnimating) _bob.repeat(reverse: true);
    if (!widget.animate) _bob.stop();
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _bob,
        builder: (context, child) =>
            Transform.translate(offset: Offset(0, -6 * Curves.easeInOut.transform(_bob.value)), child: child),
        child: CustomPaint(size: Size.square(widget.size), painter: _MascotPainter()),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  static const ink = Color(0xFF2B2440);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.scale(s);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ink;

    // Leaf sprout.
    final stem = Path()
      ..moveTo(50, 20)
      ..quadraticBezierTo(52, 12, 58, 8);
    canvas.drawPath(stem, line);
    final leaf = Path()
      ..moveTo(57, 9)
      ..quadraticBezierTo(70, 0, 80, 6)
      ..quadraticBezierTo(70, 16, 57, 9)
      ..close();
    canvas.drawPath(leaf, Paint()..color = const Color(0xFF7ED957));
    canvas.drawPath(leaf, line);

    // Drop body.
    final body = Path()
      ..moveTo(50, 16)
      ..cubicTo(62, 34, 84, 50, 84, 66)
      ..cubicTo(84, 86, 68, 96, 50, 96)
      ..cubicTo(32, 96, 16, 86, 16, 66)
      ..cubicTo(16, 50, 38, 34, 50, 16)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7FD0FF), Color(0xFF4F9DF7)],
        ).createShader(const Rect.fromLTWH(16, 16, 68, 80)),
    );
    canvas.drawPath(body, line);
    // Shine.
    canvas.drawOval(const Rect.fromLTWH(28, 50, 9, 16), Paint()..color = Colors.white.withValues(alpha: 0.7));

    // Face.
    final eye = Paint()..color = ink;
    canvas.drawCircle(const Offset(40, 66), 4.4, eye);
    canvas.drawCircle(const Offset(60, 66), 4.4, eye);
    canvas.drawCircle(const Offset(41.5, 64.5), 1.4, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(61.5, 64.5), 1.4, Paint()..color = Colors.white);
    canvas.drawArc(const Rect.fromLTWH(42, 68, 16, 12), 0.2, math.pi - 0.4, false, line);
    final cheek = Paint()..color = const Color(0xFFFF9EB5).withValues(alpha: 0.8);
    canvas.drawCircle(const Offset(31, 75), 4.5, cheek);
    canvas.drawCircle(const Offset(69, 75), 4.5, cheek);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
