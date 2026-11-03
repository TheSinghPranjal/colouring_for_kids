import 'dart:ui';

import '../../models/brush_stroke.dart';
import '../../models/coloring_artwork.dart';
import '../../models/sticker.dart';

/// A reversible change to an artwork.
abstract class ArtworkAction {
  const ArtworkAction();

  void apply(ColoringArtwork artwork);
  void revert(ColoringArtwork artwork);

  /// Whether the freehand drawing layer must be re-rendered.
  bool get touchesDrawing => false;
}

class FillAction extends ArtworkAction {
  const FillAction(this.regionId, this.before, this.after);

  final String regionId;
  final Color? before;
  final Color? after;

  static void _set(ColoringArtwork a, String id, Color? c) =>
      c == null ? a.fills.remove(id) : a.fills[id] = c;

  @override
  void apply(ColoringArtwork artwork) => _set(artwork, regionId, after);

  @override
  void revert(ColoringArtwork artwork) => _set(artwork, regionId, before);
}

/// Adds a brush or eraser stroke. Eraser strokes are ordinary entries in the
/// stroke list, so erasing is partial, non-destructive and undoable.
class StrokeAction extends ArtworkAction {
  const StrokeAction(this.stroke);

  final BrushStroke stroke;

  @override
  bool get touchesDrawing => true;

  @override
  void apply(ColoringArtwork artwork) => artwork.strokes.add(stroke);

  @override
  void revert(ColoringArtwork artwork) => artwork.strokes.removeWhere((s) => s.id == stroke.id);
}

/// Removes the child's marks (strokes and stickers), keeping region fills.
class ClearDrawingAction extends ArtworkAction {
  ClearDrawingAction(ColoringArtwork artwork)
    : _strokes = List.of(artwork.strokes),
      _stickers = [for (final s in artwork.stickers) s.copy()];

  final List<BrushStroke> _strokes;
  final List<PlacedSticker> _stickers;

  @override
  bool get touchesDrawing => true;

  @override
  void apply(ColoringArtwork artwork) {
    artwork.strokes.clear();
    artwork.stickers.clear();
  }

  @override
  void revert(ColoringArtwork artwork) {
    artwork.strokes
      ..clear()
      ..addAll(_strokes);
    artwork.stickers
      ..clear()
      ..addAll(_stickers.map((s) => s.copy()));
  }
}

/// Returns the picture to a blank template (undoable, as a safety net).
class ResetAction extends ArtworkAction {
  ResetAction(ColoringArtwork artwork) : _fills = Map.of(artwork.fills), _clear = ClearDrawingAction(artwork);

  final Map<String, Color> _fills;
  final ClearDrawingAction _clear;

  @override
  bool get touchesDrawing => true;

  @override
  void apply(ColoringArtwork artwork) {
    artwork.fills.clear();
    _clear.apply(artwork);
  }

  @override
  void revert(ColoringArtwork artwork) {
    artwork.fills
      ..clear()
      ..addAll(_fills);
    _clear.revert(artwork);
  }
}

class AddStickerAction extends ArtworkAction {
  AddStickerAction(PlacedSticker sticker) : _sticker = sticker.copy();

  final PlacedSticker _sticker;

  @override
  void apply(ColoringArtwork artwork) => artwork.stickers.add(_sticker.copy());

  @override
  void revert(ColoringArtwork artwork) => artwork.stickers.removeWhere((s) => s.id == _sticker.id);
}

class MoveStickerAction extends ArtworkAction {
  const MoveStickerAction(this.stickerId, this.from, this.to);

  final int stickerId;
  final Offset from;
  final Offset to;

  void _move(ColoringArtwork a, Offset p) {
    for (final s in a.stickers) {
      if (s.id == stickerId) s.position = p;
    }
  }

  @override
  void apply(ColoringArtwork artwork) => _move(artwork, to);

  @override
  void revert(ColoringArtwork artwork) => _move(artwork, from);
}

class RemoveStickerAction extends ArtworkAction {
  RemoveStickerAction(PlacedSticker sticker, this.index, {Offset? originalPosition})
    : _sticker = sticker.copy()..position = originalPosition ?? sticker.position;

  final PlacedSticker _sticker;
  final int index;

  @override
  void apply(ColoringArtwork artwork) => artwork.stickers.removeWhere((s) => s.id == _sticker.id);

  @override
  void revert(ColoringArtwork artwork) =>
      artwork.stickers.insert(index.clamp(0, artwork.stickers.length), _sticker.copy());
}

/// Bounded undo / redo stack.
class DrawingHistory {
  DrawingHistory({this.limit = 100});

  final int limit;
  final List<ArtworkAction> _undo = [];
  final List<ArtworkAction> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  int get undoDepth => _undo.length;

  /// Applies [action] to [artwork] and records it.
  void perform(ColoringArtwork artwork, ArtworkAction action) {
    action.apply(artwork);
    _undo.add(action);
    if (_undo.length > limit) _undo.removeAt(0);
    _redo.clear();
  }

  ArtworkAction? undo(ColoringArtwork artwork) {
    if (_undo.isEmpty) return null;
    final action = _undo.removeLast()..revert(artwork);
    _redo.add(action);
    return action;
  }

  ArtworkAction? redo(ColoringArtwork artwork) {
    if (_redo.isEmpty) return null;
    final action = _redo.removeLast()..apply(artwork);
    _undo.add(action);
    return action;
  }

  void clear() {
    _undo.clear();
    _redo.clear();
  }
}
