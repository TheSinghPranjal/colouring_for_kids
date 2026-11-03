import 'package:flutter/material.dart';

import '../engines/region_coloring/canvas_transform.dart';
import '../engines/region_coloring/region_renderer.dart';
import '../models/coloring_artwork.dart';
import '../models/coloring_template.dart';
import '../services/app_scope.dart';

/// Static rendering of a template, optionally with a child's artwork or the
/// template's demo colours. Uses the same renderer as the studio and export.
class ArtworkView extends StatefulWidget {
  const ArtworkView({super.key, required this.templateId, this.artwork, this.demoColors = false});

  final String templateId;
  final ColoringArtwork? artwork;

  /// Paint the template's example colours (category covers only).
  final bool demoColors;

  @override
  State<ArtworkView> createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  Future<ColoringTemplate>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(context).templates.load(widget.templateId);
  }

  @override
  void didUpdateWidget(ArtworkView old) {
    super.didUpdateWidget(old);
    if (old.templateId != widget.templateId) _future = AppScope.of(context).templates.load(widget.templateId);
  }

  @override
  Widget build(BuildContext context) {
    final cached = AppScope.of(context).templates.peek(widget.templateId);
    if (cached != null) return _paint(cached);
    return FutureBuilder<ColoringTemplate>(
      future: _future,
      builder: (context, snap) => snap.hasData ? _paint(snap.data!) : const SizedBox.expand(),
    );
  }

  Widget _paint(ColoringTemplate t) => RepaintBoundary(
    child: CustomPaint(
      size: Size.infinite,
      painter: _ArtworkPainter(t, widget.artwork, widget.demoColors, widget.artwork?.updatedAt),
    ),
  );
}

class _ArtworkPainter extends CustomPainter {
  _ArtworkPainter(this.template, this.artwork, this.demo, this.version);

  final ColoringTemplate template;
  final ColoringArtwork? artwork;
  final bool demo;
  final DateTime? version;

  @override
  void paint(Canvas canvas, Size size) {
    final fills = demo
        ? {for (final r in template.regions) r.id: r.demoColor}
        : (artwork?.fills ?? const <String, Color>{});
    final renderer = ArtworkRenderer(template);
    renderer.paint(
      canvas,
      CanvasTransform.fit(size, template.viewBox, padding: 4),
      fills: fills,
      strokes: artwork?.strokes ?? const [],
      stickers: artwork?.stickers ?? const [],
      background: demo ? null : artwork?.backgroundColor,
    );
    renderer.dispose();
  }

  @override
  bool shouldRepaint(_ArtworkPainter old) =>
      old.template != template || old.artwork != artwork || old.version != version || old.demo != demo;
}
