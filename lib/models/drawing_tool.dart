/// What a finger does on the canvas.
enum StudioMode { fill, draw, sticker }

/// Freehand tools. The eraser lives here too because it is recorded in the
/// same editable stroke list (as a "clear" stroke on the drawing layer).
enum DrawingTool {
  pencil('Pencil'),
  crayon('Crayon'),
  marker('Marker'),
  watercolor('Watercolor'),
  eraser('Eraser');

  const DrawingTool(this.label);

  final String label;

  bool get isEraser => this == DrawingTool.eraser;

  /// Stroke width in template units (the 1000 x 1000 view box), so a stroke
  /// keeps its size relative to the picture on every screen.
  double widthFor(BrushSize size) => switch (this) {
    DrawingTool.pencil => [7.0, 12.0, 18.0][size.index],
    DrawingTool.crayon => [18.0, 30.0, 46.0][size.index],
    DrawingTool.marker => [20.0, 34.0, 54.0][size.index],
    DrawingTool.watercolor => [30.0, 48.0, 74.0][size.index],
    DrawingTool.eraser => [50.0, 75.0, 110.0][size.index],
  };

  static DrawingTool fromName(String? name) =>
      DrawingTool.values.firstWhere((t) => t.name == name, orElse: () => DrawingTool.crayon);
}

enum BrushSize {
  small('Small'),
  medium('Medium'),
  large('Large');

  const BrushSize(this.label);

  final String label;

  static BrushSize fromName(String? name) =>
      BrushSize.values.firstWhere((s) => s.name == name, orElse: () => BrushSize.medium);
}
