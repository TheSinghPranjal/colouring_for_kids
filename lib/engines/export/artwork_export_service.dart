import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../models/coloring_artwork.dart';
import '../../models/coloring_template.dart';
import '../region_coloring/canvas_transform.dart';
import '../region_coloring/region_renderer.dart';

class ExportException implements Exception {
  const ExportException(this.message);

  final String message;

  @override
  String toString() => 'ExportException: $message';
}

/// Renders an artwork to a PNG offscreen, using the same [ArtworkRenderer]
/// as the studio canvas. No widgets, palettes or touch indicators are
/// involved, so they can never leak into the saved picture.
class ArtworkExportService {
  const ArtworkExportService({this.longestSide = 2048, this.marginFraction = 0.04});

  /// Pixel length of the longest side of the exported image.
  final int longestSide;

  /// White border around the picture, as a fraction of the image size.
  final double marginFraction;

  ui.Size exportSize(ColoringTemplate template) {
    final vb = template.viewBox;
    final ratio = vb.width / vb.height;
    return ratio >= 1
        ? ui.Size(longestSide.toDouble(), (longestSide / ratio).roundToDouble())
        : ui.Size((longestSide * ratio).roundToDouble(), longestSide.toDouble());
  }

  /// Renders the artwork to a GPU image. The caller must dispose it.
  Future<ui.Image> renderImage(ColoringTemplate template, ColoringArtwork artwork) async {
    final size = exportSize(template);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Offset.zero & size);
    canvas.drawRect(ui.Offset.zero & size, ui.Paint()..color = const ui.Color(0xFFFFFFFF));
    final transform = CanvasTransform.fit(
      size,
      template.viewBox,
      padding: size.shortestSide * marginFraction,
    );
    final renderer = ArtworkRenderer(template);
    renderer.paint(
      canvas,
      transform,
      fills: artwork.fills,
      strokes: artwork.strokes,
      stickers: artwork.stickers,
      background: artwork.backgroundColor ?? const ui.Color(0xFFFFFFFF),
    );
    renderer.dispose();
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(size.width.toInt(), size.height.toInt());
    } finally {
      picture.dispose();
    }
  }

  Future<Uint8List> renderPng(ColoringTemplate template, ColoringArtwork artwork) async {
    final ui.Image image;
    try {
      image = await renderImage(template, artwork);
    } catch (e) {
      throw ExportException('Could not draw the picture ($e)');
    }
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null || data.lengthInBytes == 0) {
        throw const ExportException('PNG encoding returned no data');
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }

  /// A friendly, private-data-free file name such as
  /// `flower_coloring_2026-10-21.png`.
  static String fileNameFor(String templateId, DateTime when, {int copy = 1}) {
    final d =
        '${when.year.toString().padLeft(4, '0')}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
    final suffix = copy > 1 ? '_$copy' : '';
    return '${templateId}_coloring_$d$suffix.png';
  }
}
