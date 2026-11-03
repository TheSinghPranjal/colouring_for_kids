import 'dart:ui';

/// Payload when dragging a sticker from the tray onto the picture.
class StickerDragData {
  const StickerDragData(this.kind);

  final StickerKind kind;
}

enum StickerKind {
  star('Star'),
  heart('Heart'),
  flower('Flower'),
  smiley('Smiley'),
  rainbow('Rainbow');

  const StickerKind(this.label);

  final String label;

  static StickerKind? fromName(String? name) {
    for (final k in StickerKind.values) {
      if (k.name == name) return k;
    }
    return null;
  }
}

/// A sticker placed on the picture, in template coordinates.
class PlacedSticker {
  PlacedSticker({required this.id, required this.kind, required this.position, this.size = 130});

  final int id;
  final StickerKind kind;
  Offset position;
  final double size;

  bool hitTest(Offset p) => (p - position).distance <= size * 0.6;

  PlacedSticker copy() => PlacedSticker(id: id, kind: kind, position: position, size: size);

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'x': position.dx,
    'y': position.dy,
    'size': size,
  };

  static PlacedSticker? fromJson(Map<String, Object?> json) {
    final kind = StickerKind.fromName(json['kind'] as String?);
    if (kind == null) return null;
    return PlacedSticker(
      id: (json['id'] as num).toInt(),
      kind: kind,
      position: Offset((json['x'] as num).toDouble(), (json['y'] as num).toDouble()),
      size: (json['size'] as num?)?.toDouble() ?? 130,
    );
  }
}
