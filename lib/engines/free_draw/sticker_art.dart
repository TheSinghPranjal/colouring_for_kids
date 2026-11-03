import 'dart:math' as math;
import 'dart:ui';

import '../../models/sticker.dart';

/// Vector art for the optional sticker tray.
class StickerArt {
  StickerArt._();

  static const _ink = Color(0xFF1F1B2E);

  static void paint(Canvas canvas, StickerKind kind, Offset c, double size) {
    final s = size / 2;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = _ink;
    switch (kind) {
      case StickerKind.star:
        final path = _star(c, s * 0.95, s * 0.45);
        canvas.drawPath(path, Paint()..color = const Color(0xFFFFD54F));
        canvas.drawPath(path, outline);
      case StickerKind.heart:
        final path = Path()
          ..moveTo(c.dx, c.dy + s * 0.8)
          ..cubicTo(c.dx - s * 1.25, c.dy - s * 0.05, c.dx - s * 0.55, c.dy - s * 1.0, c.dx, c.dy - s * 0.35)
          ..cubicTo(c.dx + s * 0.55, c.dy - s * 1.0, c.dx + s * 1.25, c.dy - s * 0.05, c.dx, c.dy + s * 0.8)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFF06292));
        canvas.drawPath(path, outline);
      case StickerKind.flower:
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          final pc = c + Offset(math.cos(a), math.sin(a)) * s * 0.5;
          canvas.drawCircle(pc, s * 0.42, Paint()..color = const Color(0xFFBA68C8));
          canvas.drawCircle(pc, s * 0.42, outline);
        }
        canvas.drawCircle(c, s * 0.38, Paint()..color = const Color(0xFFFFD54F));
        canvas.drawCircle(c, s * 0.38, outline);
      case StickerKind.smiley:
        canvas.drawCircle(c, s * 0.92, Paint()..color = const Color(0xFFFFE082));
        canvas.drawCircle(c, s * 0.92, outline);
        final ink = Paint()..color = _ink;
        canvas.drawCircle(c + Offset(-s * 0.32, -s * 0.2), s * 0.11, ink);
        canvas.drawCircle(c + Offset(s * 0.32, -s * 0.2), s * 0.11, ink);
        canvas.drawArc(
          Rect.fromCircle(center: c + Offset(0, s * 0.05), radius: s * 0.45),
          0.5,
          math.pi - 1.0,
          false,
          outline,
        );
      case StickerKind.rainbow:
        const colours = [Color(0xFFEF5350), Color(0xFFFFCA28), Color(0xFF66BB6A), Color(0xFF42A5F5)];
        final base = c + Offset(0, s * 0.45);
        for (var i = 0; i < colours.length; i++) {
          final r = s * (0.95 - i * 0.17);
          final band = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.17
            ..color = colours[i];
          canvas.drawArc(Rect.fromCircle(center: base, radius: r - s * 0.085), math.pi, math.pi, false, band);
        }
        final rim = Path()
          ..addArc(Rect.fromCircle(center: base, radius: s * 0.95), math.pi, math.pi)
          ..lineTo(base.dx + s * 0.27, base.dy)
          ..arcTo(Rect.fromCircle(center: base, radius: s * 0.27), 0, -math.pi, false)
          ..close();
        canvas.drawPath(rim, outline);
    }
  }

  static Path _star(Offset c, double rOut, double rIn) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? rOut : rIn;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }
}
