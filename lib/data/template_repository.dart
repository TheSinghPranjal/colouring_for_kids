import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

import '../models/coloring_region.dart';
import '../models/coloring_template.dart';
import 'coloring_catalog.dart';
import 'svg_path_parser.dart';

/// Loads template geometry from bundled assets and caches the parsed result,
/// so paths are parsed once per app session rather than on every frame.
class TemplateRepository {
  TemplateRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, Future<ColoringTemplate>> _cache = {};
  final Map<String, ColoringTemplate> _loaded = {};

  Future<ColoringTemplate> load(String templateId) {
    return _cache.putIfAbsent(templateId, () async {
      final info = ColoringCatalog.template(templateId);
      if (info == null) throw ArgumentError('Unknown template $templateId');
      try {
        final regionsJson = await _bundle.loadString(info.regionsAsset);
        final outlineSvg = await _bundle.loadString(info.outlineAsset);
        return _loaded[templateId] = parseTemplate(info, regionsJson, outlineSvg);
      } catch (_) {
        _cache.remove(templateId);
        rethrow;
      }
    });
  }

  /// Returns the template if it has already finished loading.
  ColoringTemplate? peek(String templateId) => _loaded[templateId];

  static ColoringTemplate parseTemplate(TemplateInfo info, String regionsJson, String outlineSvg) {
    final json = jsonDecode(regionsJson) as Map<String, dynamic>;
    final version = (json['version'] as num?)?.toInt() ?? 0;
    if (version != 1) throw FormatException('Unsupported region file version $version');
    if (json['templateId'] != info.id) {
      throw FormatException('regions.json belongs to ${json['templateId']}, not ${info.id}');
    }
    final vb = (json['viewBox'] as List).cast<num>();
    final viewBox = Rect.fromLTWH(vb[0].toDouble(), vb[1].toDouble(), vb[2].toDouble(), vb[3].toDouble());
    final regions = <ColoringRegion>[
      for (final r in (json['regions'] as List).cast<Map<String, dynamic>>())
        ColoringRegion(
          id: r['id'] as String,
          templateId: info.id,
          label: r['label'] as String? ?? r['id'] as String,
          z: (r['z'] as num).toInt(),
          fillable: r['fillable'] as bool? ?? true,
          path: parseSvgPathData(r['path'] as String),
          demoColor: _parseHex(r['demoColor'] as String?) ?? const Color(0xFFFFFFFF),
          area: (r['area'] as num?)?.toDouble() ?? 0,
        ),
    ];
    return ColoringTemplate(
      info: info,
      viewBox: viewBox,
      regions: regions,
      outline: parseOutlineSvg(outlineSvg),
      schemaVersion: version,
    );
  }

  /// Reads the `<path>` elements of a template's outline.svg.
  static List<OutlineShape> parseOutlineSvg(String svg) {
    final shapes = <OutlineShape>[];
    for (final m in RegExp(r'<path\b([^>]*?)/?>').allMatches(svg)) {
      final attrs = {
        for (final a in RegExp(r'([\w-]+)="([^"]*)"').allMatches(m.group(1)!)) a.group(1)!: a.group(2)!,
      };
      final d = attrs['d'];
      if (d == null) continue;
      final fill = attrs['fill'];
      final stroke = attrs['stroke'];
      if (stroke != null && stroke != 'none') {
        shapes.add(
          OutlineShape(
            path: parseSvgPathData(d, fillType: PathFillType.nonZero),
            color: _parseHex(stroke) ?? const Color(0xFF1F1B2E),
            strokeWidth: double.tryParse(attrs['stroke-width'] ?? '') ?? 12,
          ),
        );
      } else if (fill != null && fill != 'none') {
        shapes.add(
          OutlineShape(path: parseSvgPathData(d), color: _parseHex(fill) ?? const Color(0xFF1F1B2E)),
        );
      }
    }
    return shapes;
  }

  static Color? _parseHex(String? hex) {
    if (hex == null || !hex.startsWith('#') || hex.length != 7) return null;
    final v = int.tryParse(hex.substring(1), radix: 16);
    return v == null ? null : Color(0xFF000000 | v);
  }
}
