import 'dart:math' as math;
import 'dart:ui';

import '../../models/brush_stroke.dart';
import '../../models/coloring_template.dart';
import '../../models/sticker.dart';
import '../free_draw/sticker_art.dart';
import '../free_draw/stroke_renderer.dart';
import 'canvas_transform.dart';

/// A fill that is currently spreading out from where the colour was dropped.
class FillRipple {
  const FillRipple({required this.regionId, required this.from, required this.to, required this.origin});

  final String regionId;
  final Color? from;
  final Color to;

  /// Template-space point the colour spreads from.
  final Offset origin;
}

/// Paints an artwork's permanent layers, in this order:
///
///   1. background  2. region fills  3. original outline
///   4. child's drawing layer (strokes + eraser)  5. stickers
///
/// The studio canvas and the PNG exporter both use this class, so the saved
/// picture is rendered by exactly the same code as the one on screen.
/// Temporary highlights are drawn by the canvas on top and never exported.
class ArtworkRenderer {
  ArtworkRenderer(this.template);

  final ColoringTemplate template;

  static final Expando<Picture> _outlineCache = Expando('outline');

  Picture? _drawingPicture;
  int _drawingRevision = -1;

  /// The template's line art, recorded once in template units.
  Picture get outlinePicture => _outlineCache[template] ??= _recordOutline(template);

  static Picture _recordOutline(ColoringTemplate template) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    for (final shape in template.outline) {
      final paint = Paint()
        ..color = shape.color
        ..isAntiAlias = true;
      if (shape.isStroke) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = shape.strokeWidth!
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
      }
      canvas.drawPath(shape.path, paint);
    }
    return recorder.endRecording();
  }

  void paint(
    Canvas canvas,
    CanvasTransform transform, {
    required Map<String, Color> fills,
    required List<BrushStroke> strokes,
    required List<PlacedSticker> stickers,
    int? drawingRevision,
    BrushStroke? liveStroke,
    FillRipple? ripple,
    double rippleProgress = 1,
    Color? background = const Color(0xFFFFFFFF),
  }) {
    canvas.save();
    transform.apply(canvas);
    final vb = template.viewBox;
    if (background != null) canvas.drawRect(vb, Paint()..color = background);
    paintFills(canvas, fills, ripple: ripple, rippleProgress: rippleProgress);
    canvas.drawPicture(outlinePicture);
    paintDrawing(canvas, strokes, drawingRevision: drawingRevision, liveStroke: liveStroke);
    for (final s in stickers) {
      StickerArt.paint(canvas, s.kind, s.position, s.size);
    }
    canvas.restore();
  }

  void paintFills(Canvas canvas, Map<String, Color> fills, {FillRipple? ripple, double rippleProgress = 1}) {
    final paint = Paint()..isAntiAlias = true;
    for (final region in template.regions) {
      final active = ripple != null && ripple.regionId == region.id && rippleProgress < 1;
      if (!active) {
        final color = fills[region.id];
        if (color != null) canvas.drawPath(region.path, paint..color = color);
        continue;
      }
      if (ripple.from != null) canvas.drawPath(region.path, paint..color = ripple.from!);
      final b = region.bounds;
      final reach = [
        b.topLeft,
        b.topRight,
        b.bottomLeft,
        b.bottomRight,
      ].map((c) => (c - ripple.origin).distance).reduce(math.max);
      canvas.save();
      canvas.clipPath(region.path);
      canvas.drawCircle(ripple.origin, reach * _easeOut(rippleProgress), paint..color = ripple.to);
      canvas.restore();
    }
  }

  /// Draws strokes on their own transparent layer so the eraser (a clear
  /// blend) only removes the child's marks.
  void paintDrawing(
    Canvas canvas,
    List<BrushStroke> strokes, {
    int? drawingRevision,
    BrushStroke? liveStroke,
  }) {
    if (strokes.isEmpty && liveStroke == null) return;
    canvas.saveLayer(template.viewBox, Paint());
    if (drawingRevision == null) {
      StrokeRenderer.paintAll(canvas, strokes);
    } else {
      if (_drawingRevision != drawingRevision || _drawingPicture == null) {
        _drawingPicture?.dispose();
        _drawingPicture = StrokeRenderer.record(strokes);
        _drawingRevision = drawingRevision;
      }
      canvas.drawPicture(_drawingPicture!);
    }
    if (liveStroke != null) StrokeRenderer.paint(canvas, liveStroke);
    canvas.restore();
  }

  void dispose() {
    _drawingPicture?.dispose();
    _drawingPicture = null;
  }
}

double _easeOut(double t) => 1 - math.pow(1 - t.clamp(0.0, 1.0), 3).toDouble();
