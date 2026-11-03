import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart' show HSLColor;

import '../../models/brush_stroke.dart';
import '../../models/drawing_tool.dart';

/// Renders freehand strokes. Each tool has its own look:
///
/// * Pencil – thin, slightly translucent graphite line with a fine grain line.
/// * Crayon – waxy, irregular edges with paper-grain speckles knocked out.
/// * Marker – smooth, opaque, broad and bright.
/// * Watercolor – soft translucent wash with lighter pigment blooms.
/// * Eraser – clears the drawing layer only (BlendMode.clear), so it can never
///   touch region fills or the template outline, which live on other layers.
///
/// All randomness is seeded per stroke, so a stroke renders identically on
/// screen, after restore and in the exported PNG.
class StrokeRenderer {
  StrokeRenderer._();

  static Path pathFor(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 1) {
      // A tap leaves a dot: a tiny segment drawn with round caps.
      path.lineTo(pts.first.dx + 0.01, pts.first.dy);
      return path;
    }
    for (var i = 1; i < pts.length - 1; i++) {
      final mid = (pts[i] + pts[i + 1]) / 2;
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  static void paintAll(Canvas canvas, Iterable<BrushStroke> strokes) {
    for (final s in strokes) {
      paint(canvas, s);
    }
  }

  static Picture record(Iterable<BrushStroke> strokes) {
    final recorder = PictureRecorder();
    paintAll(Canvas(recorder), strokes);
    return recorder.endRecording();
  }

  static Paint _line(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  static void paint(Canvas canvas, BrushStroke stroke) {
    if (stroke.points.isEmpty) return;
    final path = pathFor(stroke.points);
    final w = stroke.width;
    switch (stroke.tool) {
      case DrawingTool.pencil:
        _pencil(canvas, path, stroke, w);
      case DrawingTool.crayon:
        _crayon(canvas, path, stroke, w);
      case DrawingTool.marker:
        canvas.drawPath(path, _line(stroke.color, w));
      case DrawingTool.watercolor:
        _watercolor(canvas, path, stroke, w);
      case DrawingTool.eraser:
        canvas.drawPath(path, _line(const Color(0xFF000000), w)..blendMode = BlendMode.clear);
    }
  }

  static void _pencil(Canvas canvas, Path path, BrushStroke stroke, double w) {
    canvas.drawPath(path, _line(stroke.color.withValues(alpha: 0.86), w));
    final grain = Color.lerp(stroke.color, const Color(0xFF000000), 0.25)!.withValues(alpha: 0.35);
    canvas.drawPath(path.shift(Offset(w * 0.16, w * 0.12)), _line(grain, w * 0.4));
    canvas.drawPath(
      path.shift(Offset(-w * 0.14, -w * 0.1)),
      _line(stroke.color.withValues(alpha: 0.3), w * 0.35),
    );
  }

  static void _crayon(Canvas canvas, Path path, BrushStroke stroke, double w) {
    final rnd = math.Random(stroke.seed);
    canvas.saveLayer(stroke.bounds, Paint());
    canvas.drawPath(path, _line(stroke.color.withValues(alpha: 0.9), w * 0.92));
    // Waxy, uneven edges.
    canvas.drawPath(
      path.shift(Offset(w * 0.17, -w * 0.11)),
      _line(stroke.color.withValues(alpha: 0.55), w * 0.55),
    );
    canvas.drawPath(
      path.shift(Offset(-w * 0.15, w * 0.15)),
      _line(stroke.color.withValues(alpha: 0.5), w * 0.5),
    );
    // Paper grain: knock small specks out of the wax.
    final speck = Paint()
      ..blendMode = BlendMode.dstOut
      ..color = const Color(0xC0000000);
    for (final metric in path.computeMetrics()) {
      final step = math.max(2.0, w * 0.3);
      for (var d = 0.0; d <= metric.length; d += step) {
        final pos = metric.getTangentForOffset(d)?.position;
        if (pos == null) continue;
        for (var k = 0; k < 3; k++) {
          final a = rnd.nextDouble() * math.pi * 2;
          final r = rnd.nextDouble() * w * 0.5;
          canvas.drawCircle(
            pos + Offset(math.cos(a), math.sin(a)) * r,
            w * (0.035 + rnd.nextDouble() * 0.05),
            speck,
          );
        }
      }
    }
    canvas.restore();
  }

  static void _watercolor(Canvas canvas, Path path, BrushStroke stroke, double w) {
    final rnd = math.Random(stroke.seed);
    // Group opacity: the stroke is uniformly translucent, while separate
    // strokes still layer on top of each other like real washes.
    canvas.saveLayer(stroke.bounds, Paint()..color = const Color(0x8C000000));
    canvas.drawPath(
      path,
      _line(stroke.color, w)..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.5, w * 0.1)),
    );
    final hsl = HSLColor.fromColor(stroke.color);
    final light = hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 0.95)).toColor();
    canvas.drawPath(path.shift(Offset(w * 0.06, -w * 0.05)), _line(light.withValues(alpha: 0.55), w * 0.5));
    // Gentle pigment blooms with a slight hue drift.
    final bloom = Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.5, w * 0.12));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d <= metric.length; d += math.max(4.0, w * 1.4)) {
        final pos = metric.getTangentForOffset(d)?.position;
        if (pos == null) continue;
        final drift = hsl.withHue((hsl.hue + (rnd.nextDouble() - 0.5) * 18) % 360);
        bloom.color = drift.toColor().withValues(alpha: 0.35);
        canvas.drawCircle(
          pos + Offset(rnd.nextDouble() - 0.5, rnd.nextDouble() - 0.5) * w * 0.4,
          w * 0.28,
          bloom,
        );
      }
    }
    canvas.restore();
  }
}
