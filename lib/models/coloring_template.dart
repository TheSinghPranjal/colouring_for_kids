import 'dart:ui';

import 'coloring_region.dart';

/// Catalogue entry, available synchronously for galleries and navigation.
class TemplateInfo {
  const TemplateInfo({required this.id, required this.title, required this.categoryId});

  final String id;
  final String title;
  final String categoryId;

  String get assetDir => 'assets/coloring/$categoryId/$id';
  String get outlineAsset => '$assetDir/outline.svg';
  String get regionsAsset => '$assetDir/regions.json';
  String get thumbnailAsset => '$assetDir/thumbnail.png';
  String get metadataAsset => '$assetDir/template.json';
}

/// A stroke or filled shape from the original line art (outline.svg).
class OutlineShape {
  const OutlineShape({required this.path, required this.color, this.strokeWidth});

  final Path path;
  final Color color;

  /// Null means the shape is filled (eye dots, noses); otherwise it is stroked.
  final double? strokeWidth;

  bool get isStroke => strokeWidth != null;
}

/// A fully loaded, immutable template: geometry + line art.
class ColoringTemplate {
  ColoringTemplate({
    required this.info,
    required this.viewBox,
    required List<ColoringRegion> regions,
    required this.outline,
    this.schemaVersion = 1,
  }) : regions = List.unmodifiable(regions..sort((a, b) => a.z.compareTo(b.z))),
       _byId = {for (final r in regions) r.id: r};

  final TemplateInfo info;
  final Rect viewBox;

  /// Back-to-front order.
  final List<ColoringRegion> regions;
  final List<OutlineShape> outline;
  final int schemaVersion;
  final Map<String, ColoringRegion> _byId;

  String get id => info.id;
  String get title => info.title;

  ColoringRegion? region(String id) => _byId[id];

  Iterable<ColoringRegion> get fillableRegions => regions.where((r) => r.fillable);
}
