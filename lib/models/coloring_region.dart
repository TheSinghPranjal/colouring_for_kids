import 'dart:ui';

/// One independently fillable section of a template.
///
/// Regions in a template form a planar partition: they never overlap and
/// neighbours share their boundary exactly, so a point belongs to at most one
/// region. Geometry is parsed once and cached with the template.
class ColoringRegion {
  ColoringRegion({
    required this.id,
    required this.templateId,
    required this.label,
    required this.z,
    required this.fillable,
    required this.path,
    required this.demoColor,
    required this.area,
  }) : bounds = path.getBounds();

  final String id;
  final String templateId;

  /// Short spoken / accessibility label such as "Petal 1".
  final String label;
  final int z;
  final bool fillable;
  final Path path;

  /// Example colour used only for category cover art; never forced on kids.
  final Color demoColor;
  final double area;
  final Rect bounds;

  bool contains(Offset p) => bounds.contains(p) && path.contains(p);

  Offset get center => bounds.center;
}
