import 'dart:ui';

import 'drawing_tool.dart';

/// One freehand mark (or eraser pass) in template coordinates.
class BrushStroke {
  BrushStroke({
    required this.id,
    required this.tool,
    required this.color,
    required this.width,
    required this.seed,
    List<Offset>? points,
  }) : points = points ?? <Offset>[];

  final int id;
  final DrawingTool tool;
  final Color color;
  final double width;

  /// Seeds the texture of crayon / watercolor so a stroke always looks the
  /// same when re-rendered, restored or exported.
  final int seed;
  final List<Offset> points;

  bool get isEraser => tool.isEraser;

  Rect get bounds {
    if (points.isEmpty) return Rect.zero;
    var l = points.first.dx, r = l, t = points.first.dy, b = t;
    for (final p in points) {
      if (p.dx < l) l = p.dx;
      if (p.dx > r) r = p.dx;
      if (p.dy < t) t = p.dy;
      if (p.dy > b) b = p.dy;
    }
    return Rect.fromLTRB(l, t, r, b).inflate(width);
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'tool': tool.name,
    'color': color.toARGB32(),
    'width': width,
    'seed': seed,
    // Flat [x0, y0, x1, y1, ...] list rounded to 0.1 units keeps files small.
    'points': [
      for (final p in points) ...[_round(p.dx), _round(p.dy)],
    ],
  };

  factory BrushStroke.fromJson(Map<String, Object?> json) {
    final flat = (json['points'] as List).cast<num>();
    if (flat.length.isOdd) throw const FormatException('Odd point list');
    return BrushStroke(
      id: (json['id'] as num).toInt(),
      tool: DrawingTool.fromName(json['tool'] as String?),
      color: Color((json['color'] as num).toInt()),
      width: (json['width'] as num).toDouble(),
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      points: [for (var i = 0; i < flat.length; i += 2) Offset(flat[i].toDouble(), flat[i + 1].toDouble())],
    );
  }

  static double _round(double v) => (v * 10).roundToDouble() / 10;
}
