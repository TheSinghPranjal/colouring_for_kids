import 'dart:ui';

/// Maps between a widget's local (logical pixel) space and a template's view
/// box. Painting, hit-testing and export all use this one transform, so what
/// the child sees is exactly what gets filled.
///
/// The template is scaled uniformly to fit, centred, and letterboxed. Logical
/// pixels are used throughout; Flutter applies the device pixel ratio below
/// this layer, so it never needs to be handled separately.
class CanvasTransform {
  const CanvasTransform._(this.viewBox, this.scale, this.offset);

  factory CanvasTransform.fit(Size size, Rect viewBox, {double padding = 0}) {
    final availW = (size.width - padding * 2).clamp(1.0, double.infinity);
    final availH = (size.height - padding * 2).clamp(1.0, double.infinity);
    final scale = (availW / viewBox.width) < (availH / viewBox.height)
        ? availW / viewBox.width
        : availH / viewBox.height;
    final drawnW = viewBox.width * scale;
    final drawnH = viewBox.height * scale;
    final offset = Offset((size.width - drawnW) / 2, (size.height - drawnH) / 2);
    return CanvasTransform._(viewBox, scale, offset);
  }

  final Rect viewBox;

  /// Logical pixels per template unit.
  final double scale;

  /// Local position of the view box's top-left corner.
  final Offset offset;

  /// Where the picture is drawn, in local coordinates.
  Rect get destination => Rect.fromLTWH(offset.dx, offset.dy, viewBox.width * scale, viewBox.height * scale);

  Offset toTemplate(Offset local) =>
      Offset((local.dx - offset.dx) / scale + viewBox.left, (local.dy - offset.dy) / scale + viewBox.top);

  Offset toLocal(Offset template) => Offset(
    (template.dx - viewBox.left) * scale + offset.dx,
    (template.dy - viewBox.top) * scale + offset.dy,
  );

  /// Converts a distance in logical pixels into template units.
  double toTemplateDistance(double logical) => logical / scale;

  bool containsTemplatePoint(Offset p) => viewBox.contains(p);

  void apply(Canvas canvas) {
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);
    canvas.translate(-viewBox.left, -viewBox.top);
  }

  @override
  bool operator ==(Object other) =>
      other is CanvasTransform && other.viewBox == viewBox && other.scale == scale && other.offset == offset;

  @override
  int get hashCode => Object.hash(viewBox, scale, offset);
}
