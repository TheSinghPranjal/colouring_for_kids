import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../models/brush_stroke.dart';
import '../../models/coloring_artwork.dart';
import '../../models/coloring_region.dart';
import '../../models/coloring_template.dart';
import '../../models/drawing_tool.dart';
import '../../models/palette_color.dart';
import '../../models/sticker.dart';
import '../free_draw/drawing_history.dart';
import 'region_hit_tester.dart';
import 'region_renderer.dart';

/// Owns one artwork's editable state and every action a child can take on
/// it. All coordinates here are template coordinates; widgets convert with
/// [CanvasTransform] before calling in.
class ColoringController extends ChangeNotifier {
  ColoringController({
    required this.template,
    required ColoringArtwork artwork,
    this.onArtworkChanged,
    int historyLimit = 100,
  }) : _artwork = artwork,
       hitTester = RegionHitTester(template),
       history = DrawingHistory(limit: historyLimit) {
    final prefs = artwork.studio;
    _selectedColor = prefs.color ?? kBasicPalette.first.color;
    _mode = prefs.mode;
    _tool = prefs.tool;
    _brushSize = prefs.brushSize;
    // Drop fills for regions that no longer exist (e.g. after an app update
    // reshaped a template) instead of failing to open the picture.
    artwork.fills.removeWhere((id, _) => template.region(id) == null);
  }

  final ColoringTemplate template;
  final RegionHitTester hitTester;
  final DrawingHistory history;

  /// Called after every meaningful change so the project can be autosaved.
  void Function(ColoringArtwork artwork)? onArtworkChanged;

  final ColoringArtwork _artwork;
  ColoringArtwork get artwork => _artwork;

  late Color _selectedColor;
  late StudioMode _mode;
  late DrawingTool _tool;
  late BrushSize _brushSize;
  StickerKind _stickerKind = StickerKind.star;

  Color get selectedColor => _selectedColor;
  StudioMode get mode => _mode;
  DrawingTool get tool => _tool;
  BrushSize get brushSize => _brushSize;
  StickerKind get stickerKind => _stickerKind;

  /// Bumped whenever committed strokes change, so the cached drawing layer
  /// is re-recorded only then (not on every frame).
  int get drawingRevision => _drawingRevision;
  int _drawingRevision = 0;

  /// Fires on every pointer move while drawing; cheaper than rebuilding the
  /// whole studio through [notifyListeners].
  final RepaintSignal liveRepaint = RepaintSignal();

  BrushStroke? get liveStroke => _liveStroke;
  BrushStroke? _liveStroke;

  FillRipple? get lastRipple => _lastRipple;
  FillRipple? _lastRipple;
  int get rippleSerial => _rippleSerial;
  int _rippleSerial = 0;

  final math.Random _random = math.Random();

  bool get canUndo => history.canUndo;
  bool get canRedo => history.canRedo;

  double get brushWidth => _tool.widthFor(_brushSize);

  /// Fraction of fillable regions that have a colour.
  double get progress {
    final total = template.fillableRegions.length;
    if (total == 0) return 0;
    return template.fillableRegions.where((r) => _artwork.fills.containsKey(r.id)).length / total;
  }

  // ---------------------------------------------------------------- choices

  void selectColor(Color color) {
    if (color == _selectedColor) return;
    _selectedColor = color;
    _prefsChanged();
  }

  void setMode(StudioMode mode) {
    if (mode == _mode) return;
    cancelStroke();
    _mode = mode;
    _prefsChanged();
  }

  void setTool(DrawingTool tool) {
    _tool = tool;
    _mode = StudioMode.draw;
    _prefsChanged();
  }

  void setBrushSize(BrushSize size) {
    _brushSize = size;
    _prefsChanged();
  }

  void setStickerKind(StickerKind kind) {
    _stickerKind = kind;
    _mode = StudioMode.sticker;
    notifyListeners();
  }

  // ---------------------------------------------------------------- filling

  ColoringRegion? regionAt(Offset templatePoint, {double tolerance = 0}) =>
      hitTester.regionAt(templatePoint, tolerance: tolerance);

  /// Fills the region under [templatePoint]. Returns the filled region, or
  /// null (and changes nothing) if the point is not on a fillable region.
  ColoringRegion? fillAt(Offset templatePoint, {Color? color, double tolerance = 0}) {
    final region = regionAt(templatePoint, tolerance: tolerance);
    if (region == null) return null;
    fillRegion(region.id, color ?? _selectedColor, origin: templatePoint);
    return region;
  }

  /// Returns false if nothing changed (unknown region or same colour).
  bool fillRegion(String regionId, Color color, {Offset? origin}) {
    final region = template.region(regionId);
    if (region == null || !region.fillable) return false;
    final before = _artwork.fills[regionId];
    if (before == color) return false;
    history.perform(_artwork, FillAction(regionId, before, color));
    _lastRipple = FillRipple(regionId: regionId, from: before, to: color, origin: origin ?? region.center);
    _rippleSerial++;
    _contentChanged();
    return true;
  }

  // ---------------------------------------------------------------- drawing

  void beginStroke(Offset p) {
    _liveStroke = BrushStroke(
      id: _artwork.nextStrokeId,
      tool: _tool,
      color: _selectedColor,
      width: brushWidth,
      seed: _random.nextInt(1 << 31),
      points: [p],
    );
    liveRepaint.ping();
  }

  void extendStroke(Offset p) {
    final stroke = _liveStroke;
    if (stroke == null) return;
    final minStep = math.max(1.0, stroke.width * 0.08);
    if ((stroke.points.last - p).distance < minStep) return;
    stroke.points.add(p);
    liveRepaint.ping();
  }

  void endStroke() {
    final stroke = _liveStroke;
    if (stroke == null) return;
    _liveStroke = null;
    // An eraser pass over nothing is not worth an undo step.
    if (stroke.isEraser && _artwork.strokes.isEmpty) {
      liveRepaint.ping();
      return;
    }
    history.perform(_artwork, StrokeAction(stroke));
    _drawingRevision++;
    _contentChanged();
  }

  void cancelStroke() {
    if (_liveStroke == null) return;
    _liveStroke = null;
    liveRepaint.ping();
  }

  /// Completes any in-progress gesture (used before saving).
  void finishGesture() => endStroke();

  // --------------------------------------------------------------- stickers

  PlacedSticker? stickerAt(Offset p) {
    for (final s in _artwork.stickers.reversed) {
      if (s.hitTest(p)) return s;
    }
    return null;
  }

  PlacedSticker addSticker(Offset p, {StickerKind? kind}) {
    final sticker = PlacedSticker(id: _artwork.nextStickerId, kind: kind ?? _stickerKind, position: p);
    history.perform(_artwork, AddStickerAction(sticker));
    _contentChanged();
    return sticker;
  }

  /// Moves a sticker while it is being dragged (not yet an undo step).
  void dragSticker(int id, Offset p) {
    for (final s in _artwork.stickers) {
      if (s.id == id) s.position = p;
    }
    liveRepaint.ping();
  }

  /// Ends a sticker drag. Dropping it off the picture removes it.
  void endStickerDrag(int id, Offset from) {
    final index = _artwork.stickers.indexWhere((s) => s.id == id);
    if (index < 0) return;
    final sticker = _artwork.stickers[index];
    if (!template.viewBox.contains(sticker.position)) {
      history.perform(_artwork, RemoveStickerAction(sticker, index, originalPosition: from));
    } else if (sticker.position != from) {
      history.perform(_artwork, MoveStickerAction(id, from, sticker.position));
    } else {
      return;
    }
    _contentChanged();
  }

  // ---------------------------------------------------------------- editing

  void clearDrawing() {
    if (_artwork.strokes.isEmpty && _artwork.stickers.isEmpty) return;
    cancelStroke();
    history.perform(_artwork, ClearDrawingAction(_artwork));
    _drawingRevision++;
    _contentChanged();
  }

  void resetPicture() {
    cancelStroke();
    if (_artwork.isEmpty) return;
    history.perform(_artwork, ResetAction(_artwork));
    _drawingRevision++;
    _lastRipple = null;
    _contentChanged();
  }

  void undo() {
    cancelStroke();
    final action = history.undo(_artwork);
    if (action == null) return;
    _afterHistoryStep(action);
  }

  void redo() {
    cancelStroke();
    final action = history.redo(_artwork);
    if (action == null) return;
    _afterHistoryStep(action);
  }

  void _afterHistoryStep(ArtworkAction action) {
    if (action.touchesDrawing) _drawingRevision++;
    _lastRipple = null;
    _contentChanged();
  }

  // -------------------------------------------------------------- internals

  StudioPrefs get _prefs =>
      StudioPrefs(color: _selectedColor, tool: _tool, brushSize: _brushSize, mode: _mode);

  void _prefsChanged() {
    _artwork.studio = _prefs;
    if (!_artwork.isEmpty) onArtworkChanged?.call(_artwork);
    notifyListeners();
  }

  void _contentChanged() {
    _artwork.updatedAt = DateTime.now();
    _artwork.studio = _prefs;
    onArtworkChanged?.call(_artwork);
    notifyListeners();
    liveRepaint.ping();
  }

  @override
  void dispose() {
    liveRepaint.dispose();
    super.dispose();
  }
}

/// A listenable the canvas repaints on, without rebuilding any widgets.
class RepaintSignal extends ChangeNotifier {
  void ping() => notifyListeners();
}
