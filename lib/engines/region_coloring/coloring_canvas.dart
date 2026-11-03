import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/coloring_region.dart';
import '../../models/drawing_tool.dart';
import '../../models/sticker.dart';
import '../free_draw/sticker_art.dart';
import 'canvas_transform.dart';
import 'coloring_controller.dart';
import 'region_renderer.dart';

/// Payload carried when a child drags a palette swatch.
class SwatchDragData {
  const SwatchDragData(this.color);

  final Color color;
}

/// The interactive picture. Converts every pointer position through one
/// [CanvasTransform] (the same one used to paint), then asks the
/// [ColoringController] to fill, draw or place stickers.
///
/// * Dropping a dragged swatch fills the region under the finger, in any mode.
/// * In Fill mode a tap fills with the selected colour; finger drags do
///   nothing, so scribbles never trigger fills.
/// * In Draw mode every touch draws; it never fills.
class ColoringCanvas extends StatefulWidget {
  const ColoringCanvas({
    super.key,
    required this.controller,
    this.reducedMotion = false,
    this.hintsEnabled = true,
    this.onFilled,
    this.onInvalidDrop,
    this.onStrokeStarted,
    this.onStickerPlaced,
    this.onInteraction,
  });

  final ColoringController controller;
  final bool reducedMotion;
  final bool hintsEnabled;
  final void Function(ColoringRegion region)? onFilled;

  /// A swatch was dropped somewhere that is not a fillable region.
  final void Function(Offset globalPosition, Color color)? onInvalidDrop;
  final VoidCallback? onStrokeStarted;
  final VoidCallback? onStickerPlaced;
  final VoidCallback? onInteraction;

  /// Touch slack, in logical pixels, for near-miss taps on region edges.
  static const double touchTolerance = 14;

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> with TickerProviderStateMixin {
  late ArtworkRenderer _renderer;
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  final GlobalKey _paintKey = GlobalKey();

  CanvasTransform? _transform;
  ColoringRegion? _hover;
  Color? _hoverColor;
  ColoringRegion? _hint;
  Timer? _idle;
  int _lastRippleSerial = 0;

  int? _pointer;
  Offset? _downLocal;
  bool _moved = false;
  PlacedSticker? _dragSticker;
  Offset? _dragFrom;

  ColoringController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _renderer = ArtworkRenderer(_c.template);
    _lastRippleSerial = _c.rippleSerial;
    _c.addListener(_onControllerChanged);
    _scheduleHint();
  }

  @override
  void didUpdateWidget(ColoringCanvas old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onControllerChanged);
      _renderer.dispose();
      _renderer = ArtworkRenderer(_c.template);
      _c.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _idle?.cancel();
    _c.removeListener(_onControllerChanged);
    _ripple.dispose();
    _pulse.dispose();
    _renderer.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_c.rippleSerial != _lastRippleSerial) {
      _lastRippleSerial = _c.rippleSerial;
      if (widget.reducedMotion) {
        _ripple.value = 1;
      } else {
        _ripple.forward(from: 0);
      }
    }
    if (_hint != null && _c.artwork.fills.containsKey(_hint!.id)) _clearHint();
  }

  // ------------------------------------------------------------------ hints

  void _scheduleHint() {
    _idle?.cancel();
    if (!widget.hintsEnabled) return;
    _idle = Timer(const Duration(seconds: 20), () {
      if (!mounted || _c.mode != StudioMode.fill) return;
      ColoringRegion? best;
      for (final r in _c.template.fillableRegions) {
        if (_c.artwork.fills.containsKey(r.id)) continue;
        if (best == null || r.area > best.area) best = r;
      }
      if (best == null) return;
      setState(() => _hint = best);
      if (widget.reducedMotion) {
        _pulse.value = 0.6;
      } else {
        _pulse.repeat(reverse: true);
      }
    });
  }

  void _clearHint() {
    if (_hint == null) return;
    _pulse.stop();
    setState(() => _hint = null);
  }

  void _interacted() {
    _clearHint();
    _scheduleHint();
    widget.onInteraction?.call();
  }

  // ---------------------------------------------------------- coordinates

  Offset? _templateFromGlobal(Offset global) {
    final box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    final t = _transform;
    if (box == null || t == null) return null;
    return t.toTemplate(box.globalToLocal(global));
  }

  double get _tolerance => (_transform?.toTemplateDistance(ColoringCanvas.touchTolerance)) ?? 0;

  // ---------------------------------------------------------- swatch drops

  void _dragMoved(DragTargetDetails<SwatchDragData> d) {
    final p = _templateFromGlobal(d.offset);
    final region = p == null ? null : _c.regionAt(p, tolerance: _tolerance);
    if (region != _hover || _hoverColor != d.data.color) {
      setState(() {
        _hover = region;
        _hoverColor = d.data.color;
      });
    }
  }

  void _dragLeft() {
    if (_hover != null) setState(() => _hover = null);
  }

  void _dropped(DragTargetDetails<SwatchDragData> d) {
    _interacted();
    setState(() => _hover = null);
    final p = _templateFromGlobal(d.offset);
    final region = p == null ? null : _c.fillAt(p, color: d.data.color, tolerance: _tolerance);
    if (region == null) {
      widget.onInvalidDrop?.call(d.offset, d.data.color);
    } else {
      widget.onFilled?.call(region);
    }
  }

  // ------------------------------------------------------------- pointers

  void _down(PointerDownEvent e) {
    if (_pointer != null) return; // Ignore extra fingers.
    _pointer = e.pointer;
    _downLocal = e.localPosition;
    _moved = false;
    _interacted();
    final t = _transform;
    if (t == null) return;
    final p = t.toTemplate(e.localPosition);
    switch (_c.mode) {
      case StudioMode.draw:
        _c.beginStroke(p);
        widget.onStrokeStarted?.call();
      case StudioMode.sticker:
        final s = _c.stickerAt(p);
        if (s != null) {
          _dragSticker = s;
          _dragFrom = s.position;
        }
      case StudioMode.fill:
        break;
    }
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    final t = _transform;
    if (t == null) return;
    if (!_moved && (e.localPosition - _downLocal!).distance > 10) _moved = true;
    final p = t.toTemplate(e.localPosition);
    switch (_c.mode) {
      case StudioMode.draw:
        _c.extendStroke(p);
      case StudioMode.sticker:
        if (_dragSticker != null) _c.dragSticker(_dragSticker!.id, p);
      case StudioMode.fill:
        break;
    }
  }

  void _up(PointerUpEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    final t = _transform;
    if (t == null) return;
    final p = t.toTemplate(e.localPosition);
    switch (_c.mode) {
      case StudioMode.draw:
        _c.endStroke();
      case StudioMode.sticker:
        if (_dragSticker != null) {
          _c.endStickerDrag(_dragSticker!.id, _dragFrom!);
          _dragSticker = null;
        } else if (!_moved && t.containsTemplatePoint(p)) {
          _c.addSticker(p);
          widget.onStickerPlaced?.call();
        }
      case StudioMode.fill:
        if (!_moved) {
          final region = _c.fillAt(p, tolerance: _tolerance);
          if (region != null) widget.onFilled?.call(region);
        }
    }
  }

  void _cancel(PointerCancelEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    if (_c.mode == StudioMode.draw) _c.endStroke();
    if (_dragSticker != null) {
      _c.endStickerDrag(_dragSticker!.id, _dragFrom!);
      _dragSticker = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        _transform = CanvasTransform.fit(size, _c.template.viewBox, padding: 10);
        return DragTarget<SwatchDragData>(
          onWillAcceptWithDetails: (_) => true,
          onMove: _dragMoved,
          onLeave: (_) => _dragLeft(),
          onAcceptWithDetails: _dropped,
          builder: (context, candidates, rejected) => Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _down,
            onPointerMove: _move,
            onPointerUp: _up,
            onPointerCancel: _cancel,
            child: Semantics(
              label: 'Coloring picture: ${_c.template.title}',
              child: CustomPaint(
                key: _paintKey,
                size: size,
                isComplex: true,
                painter: _CanvasPainter(
                  controller: _c,
                  renderer: _renderer,
                  transform: _transform!,
                  ripple: _ripple,
                  pulse: _pulse,
                  hover: _hover,
                  hoverColor: _hoverColor,
                  hint: _hint,
                  onSemanticTap: (region) {
                    if (_c.fillRegion(region.id, _c.selectedColor)) widget.onFilled?.call(region);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({
    required this.controller,
    required this.renderer,
    required this.transform,
    required this.ripple,
    required this.pulse,
    required this.hover,
    required this.hoverColor,
    required this.hint,
    required this.onSemanticTap,
  }) : super(repaint: Listenable.merge([controller.liveRepaint, ripple, pulse]));

  final ColoringController controller;
  final ArtworkRenderer renderer;
  final CanvasTransform transform;
  final Animation<double> ripple;
  final Animation<double> pulse;
  final ColoringRegion? hover;
  final Color? hoverColor;
  final ColoringRegion? hint;
  final void Function(ColoringRegion region) onSemanticTap;

  @override
  void paint(Canvas canvas, Size size) {
    final a = controller.artwork;
    final dest = transform.destination;
    canvas.drawRRect(RRect.fromRectAndRadius(dest, const Radius.circular(6)), Paint()..color = Colors.white);
    canvas.save();
    transform.apply(canvas);
    renderer.paintFills(canvas, a.fills, ripple: controller.lastRipple, rippleProgress: ripple.value);
    // Temporary highlights sit under the outline so the line art stays crisp.
    if (hover != null) {
      canvas.drawPath(hover!.path, Paint()..color = (hoverColor ?? Colors.white).withValues(alpha: 0.5));
    }
    if (hint != null) {
      canvas.drawPath(
        hint!.path,
        Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.25 + 0.45 * pulse.value),
      );
    }
    canvas.drawPicture(renderer.outlinePicture);
    renderer.paintDrawing(
      canvas,
      a.strokes,
      drawingRevision: controller.drawingRevision,
      liveStroke: controller.liveStroke,
    );
    for (final s in a.stickers) {
      StickerArt.paint(canvas, s.kind, s.position, s.size);
    }
    canvas.restore();
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder =>
      (size) => [
        for (final r in controller.template.fillableRegions)
          CustomPainterSemantics(
            rect: Rect.fromPoints(
              transform.toLocal(r.bounds.topLeft),
              transform.toLocal(r.bounds.bottomRight),
            ),
            properties: SemanticsProperties(
              label: r.label,
              button: true,
              textDirection: TextDirection.ltr,
              onTap: () => onSemanticTap(r),
            ),
          ),
      ];

  @override
  bool shouldRebuildSemantics(_CanvasPainter old) =>
      old.transform != transform || old.controller.template != controller.template;

  @override
  bool shouldRepaint(_CanvasPainter old) =>
      old.transform != transform || old.hover != hover || old.hoverColor != hoverColor || old.hint != hint;
}
