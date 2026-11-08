// Renders assets/coloring/<category>/<id>/thumbnail.png for every template
// with the app's own ArtworkRenderer:
//
//   flutter test tool/render_thumbnails_test.dart
//
// Set CONTACT_SHEET=/path/sheet.png to also write a demo-coloured overview
// of all templates for visual review.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:colouring_for_kids/data/coloring_catalog.dart';
import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/engines/region_coloring/canvas_transform.dart';
import 'package:colouring_for_kids/engines/region_coloring/region_renderer.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const thumbSize = 384.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render thumbnails', () async {
    final repo = TemplateRepository();
    final sheetPath = Platform.environment['CONTACT_SHEET'];
    final sheetRecorder = ui.PictureRecorder();
    final sheet = ui.Canvas(sheetRecorder);
    const cell = 220.0;
    sheet.drawRect(const Rect.fromLTWH(0, 0, cell * 15, cell * 20), Paint()..color = const Color(0xFFFFFFFF));

    final templates = ColoringCatalog.allTemplates;
    for (var i = 0; i < templates.length; i++) {
      final info = templates[i];
      final t = await repo.load(info.id);
      final renderer = ArtworkRenderer(t);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      renderer.paint(
        canvas,
        CanvasTransform.fit(const Size(thumbSize, thumbSize), t.viewBox, padding: 8),
        fills: const {},
        strokes: const [],
        stickers: const [],
        background: null,
      );
      final image = await recorder.endRecording().toImage(thumbSize.toInt(), thumbSize.toInt());
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(info.thumbnailAsset).writeAsBytes(png!.buffer.asUint8List());

      final col = i % 15, row = i ~/ 15;
      sheet.save();
      sheet.translate(col * cell, row * cell);
      renderer.paint(
        sheet,
        CanvasTransform.fit(const Size(cell, cell), t.viewBox, padding: 6),
        fills: {for (final r in t.regions) r.id: r.demoColor},
        strokes: const [],
        stickers: const [],
      );
      sheet.restore();
      renderer.dispose();
    }
    if (sheetPath != null) {
      final img = await sheetRecorder.endRecording().toImage((cell * 15).toInt(), (cell * 20).toInt());
      final png = await img.toByteData(format: ui.ImageByteFormat.png);
      await File(sheetPath).writeAsBytes(png!.buffer.asUint8List());
    }
  });
}
