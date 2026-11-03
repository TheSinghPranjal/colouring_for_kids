import 'dart:ui';

import 'brush_stroke.dart';
import 'drawing_tool.dart';
import 'sticker.dart';

/// The child's editable work on one template.
///
/// Only the child's changes are stored (region colours, strokes, stickers);
/// the template's own artwork is never copied into a project.
class ColoringArtwork {
  ColoringArtwork({
    required this.id,
    required this.templateId,
    Map<String, Color>? fills,
    List<BrushStroke>? strokes,
    List<PlacedSticker>? stickers,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastExportedAt,
    this.lastExportPath,
    this.studio = const StudioPrefs(),
  }) : fills = fills ?? {},
       strokes = strokes ?? [],
       stickers = stickers ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  static const int schemaVersion = 1;

  final String id;
  final String templateId;
  final Map<String, Color> fills;
  final List<BrushStroke> strokes;
  final List<PlacedSticker> stickers;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? lastExportedAt;
  String? lastExportPath;
  StudioPrefs studio;

  bool get isEmpty => fills.isEmpty && strokes.isEmpty && stickers.isEmpty;

  int get nextStrokeId => strokes.fold(0, (m, s) => s.id > m ? s.id : m) + 1;

  int get nextStickerId => stickers.fold(0, (m, s) => s.id > m ? s.id : m) + 1;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'templateId': templateId,
    'fills': {for (final e in fills.entries) e.key: e.value.toARGB32()},
    'strokes': [for (final s in strokes) s.toJson()],
    'stickers': [for (final s in stickers) s.toJson()],
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastExportedAt': lastExportedAt?.toIso8601String(),
    'lastExportPath': lastExportPath,
    'studio': studio.toJson(),
  };

  /// Throws [FormatException] for data that cannot be understood, so callers
  /// can skip a damaged project without crashing.
  factory ColoringArtwork.fromJson(Map<String, Object?> json) {
    final version = (json['schemaVersion'] as num?)?.toInt() ?? 0;
    if (version < 1 || version > schemaVersion) {
      throw FormatException('Unsupported artwork version $version');
    }
    final id = json['id'];
    final templateId = json['templateId'];
    if (id is! String || templateId is! String) {
      throw const FormatException('Artwork is missing its id');
    }
    final fillsJson = (json['fills'] as Map?) ?? const {};
    return ColoringArtwork(
      id: id,
      templateId: templateId,
      fills: {for (final e in fillsJson.entries) e.key as String: Color((e.value as num).toInt())},
      strokes: [
        for (final s in (json['strokes'] as List?) ?? const []) BrushStroke.fromJson((s as Map).cast()),
      ],
      stickers: [
        for (final s in (json['stickers'] as List?) ?? const []) ?PlacedSticker.fromJson((s as Map).cast()),
      ],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      lastExportedAt: DateTime.tryParse(json['lastExportedAt'] as String? ?? ''),
      lastExportPath: json['lastExportPath'] as String?,
      studio: StudioPrefs.fromJson((json['studio'] as Map?)?.cast() ?? const {}),
    );
  }
}

/// The child's last studio choices for this picture, restored on resume.
class StudioPrefs {
  const StudioPrefs({
    this.color,
    this.tool = DrawingTool.crayon,
    this.brushSize = BrushSize.medium,
    this.mode = StudioMode.fill,
  });

  final Color? color;
  final DrawingTool tool;
  final BrushSize brushSize;
  final StudioMode mode;

  Map<String, Object?> toJson() => {
    'color': color?.toARGB32(),
    'tool': tool.name,
    'brushSize': brushSize.name,
    'mode': mode.name,
  };

  factory StudioPrefs.fromJson(Map<String, Object?> json) => StudioPrefs(
    color: json['color'] is num ? Color((json['color'] as num).toInt()) : null,
    tool: DrawingTool.fromName(json['tool'] as String?),
    brushSize: BrushSize.fromName(json['brushSize'] as String?),
    mode: StudioMode.values.firstWhere((m) => m.name == json['mode'], orElse: () => StudioMode.fill),
  );
}
