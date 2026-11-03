import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/engines/export/artwork_export_service.dart';
import 'package:colouring_for_kids/engines/free_draw/stroke_renderer.dart';
import 'package:colouring_for_kids/engines/region_coloring/canvas_transform.dart';
import 'package:colouring_for_kids/engines/region_coloring/coloring_controller.dart';
import 'package:colouring_for_kids/models/brush_stroke.dart';
import 'package:colouring_for_kids/models/coloring_artwork.dart';
import 'package:colouring_for_kids/models/coloring_template.dart';
import 'package:colouring_for_kids/models/drawing_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const red = Color(0xFFE53935);
const blue = Color(0xFF1E88E5);
const petal1 = Offset(500, 178);
const petal2 = Offset(673, 303);

/// Renders one stroke of [tool] on a transparent 300 x 160 canvas.
Future<ByteData> renderTool(DrawingTool tool, BrushSize size, {Color color = blue}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  StrokeRenderer.paint(
    canvas,
    BrushStroke(
      id: 1,
      tool: tool,
      color: color,
      width: tool.widthFor(size),
      seed: 3,
      points: [for (var x = 30.0; x <= 270; x += 6) Offset(x, 80 + 30 * (x / 60 % 2 - 1))],
    ),
  );
  final image = await recorder.endRecording().toImage(300, 160);
  return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
}

int inkedPixels(ByteData d) {
  var n = 0;
  for (var i = 3; i < d.lengthInBytes; i += 4) {
    if (d.getUint8(i) > 20) n++;
  }
  return n;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ColoringTemplate flower;
  setUpAll(() async => flower = await TemplateRepository().load('flower'));

  ColoringController newController() => ColoringController(
    template: flower,
    artwork: ColoringArtwork(id: 'd', templateId: 'flower'),
  );

  void drawLine(ColoringController c, Offset from, Offset to, {int steps = 20}) {
    c.beginStroke(from);
    for (var i = 1; i <= steps; i++) {
      c.extendStroke(Offset.lerp(from, to, i / steps)!);
    }
    c.endStroke();
  }

  group('tools', () {
    test('pencil, crayon, marker and watercolor render distinctly', () async {
      final tools = [DrawingTool.pencil, DrawingTool.crayon, DrawingTool.marker, DrawingTool.watercolor];
      final images = [for (final t in tools) await renderTool(t, BrushSize.medium)];
      for (var i = 0; i < images.length; i++) {
        for (var j = i + 1; j < images.length; j++) {
          expect(
            images[i].buffer.asUint8List(),
            isNot(equals(images[j].buffer.asUint8List())),
            reason: '${tools[i]} vs ${tools[j]}',
          );
        }
      }
      // Characteristic looks: pencil is thinnest, the marker is opaque,
      // watercolor is translucent, crayon has paper-grain gaps.
      final ink = [for (final d in images) inkedPixels(d)];
      expect(ink[0], lessThan(ink[1]));
      expect(ink[0], lessThan(ink[2]));
      int maxAlpha(ByteData d) {
        var m = 0;
        for (var i = 3; i < d.lengthInBytes; i += 4) {
          if (d.getUint8(i) > m) m = d.getUint8(i);
        }
        return m;
      }

      expect(maxAlpha(images[2]), 255, reason: 'marker is opaque');
      expect(maxAlpha(images[3]), lessThan(200), reason: 'watercolor is translucent');
      // Crayon: more partially-transparent pixels than the solid marker.
      int partial(ByteData d) {
        var n = 0;
        for (var i = 3; i < d.lengthInBytes; i += 4) {
          final a = d.getUint8(i);
          if (a > 20 && a < 235) n++;
        }
        return n;
      }

      expect(partial(images[1]), greaterThan(partial(images[2]) * 2));
    });

    test('brush sizes grow consistently for every tool', () async {
      for (final tool in DrawingTool.values.where((t) => !t.isEraser)) {
        final s = await renderTool(tool, BrushSize.small);
        final m = await renderTool(tool, BrushSize.medium);
        final l = await renderTool(tool, BrushSize.large);
        expect(inkedPixels(s), lessThan(inkedPixels(m)), reason: '$tool small < medium');
        expect(inkedPixels(m), lessThan(inkedPixels(l)), reason: '$tool medium < large');
        expect(tool.widthFor(BrushSize.small), lessThan(tool.widthFor(BrushSize.large)));
      }
    });

    test('strokes render identically every time (seeded texture)', () async {
      final a = await renderTool(DrawingTool.crayon, BrushSize.large);
      final b = await renderTool(DrawingTool.crayon, BrushSize.large);
      expect(a.buffer.asUint8List(), equals(b.buffer.asUint8List()));
    });
  });

  group('drawing layer', () {
    test('drawing over a region never fills it', () {
      final c = newController()..setTool(DrawingTool.marker);
      expect(c.mode, StudioMode.draw);
      drawLine(c, petal1, petal2);
      expect(c.artwork.fills, isEmpty);
      expect(c.artwork.strokes, hasLength(1));
      expect(c.artwork.strokes.single.points.length, greaterThan(5));
    });

    test('eraser removes only marks, partially, and is undoable', () async {
      final c = newController();
      c.fillAt(petal1, color: red);
      c.setTool(DrawingTool.pencil);
      c.selectColor(blue);
      c.setBrushSize(BrushSize.large);
      drawLine(c, const Offset(420, 178), const Offset(580, 178), steps: 30);
      c.setTool(DrawingTool.eraser);
      // Erase only the middle of the line.
      drawLine(c, const Offset(500, 120), const Offset(500, 240));

      expect(c.artwork.fills, {'petal_1': red}, reason: 'fills untouched');
      expect(c.artwork.strokes.map((s) => s.tool), [DrawingTool.pencil, DrawingTool.eraser]);

      final img = await const ArtworkExportService(
        longestSide: 1000,
        marginFraction: 0,
      ).renderImage(flower, c.artwork);
      final data = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      Future<Color> at(Offset p) => pixelAt(img, p.dx.round(), p.dy.round(), cache: data);
      expect(closeColor(await at(petal1), red), isTrue, reason: 'erased spot shows the fill again');
      expect(closeColor(await at(const Offset(440, 178)), red), isFalse, reason: 'rest of stroke remains');
      // The petal's original outline at its top tip is still dark.
      final tip = flower.region('petal_1')!.bounds.topCenter;
      expect((await at(tip + const Offset(0, 1))).computeLuminance(), lessThan(0.1));

      c.undo(); // undo the eraser pass
      expect(c.artwork.strokes, hasLength(1));
      final restored = await const ArtworkExportService(
        longestSide: 1000,
        marginFraction: 0,
      ).renderImage(flower, c.artwork);
      final rd = (await restored.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      expect(closeColor(await pixelAt(restored, 500, 178, cache: rd), red), isFalse, reason: 'mark is back');
    });

    test('undo and redo across a fill, a stroke and an erase', () {
      final c = newController();
      c.fillAt(petal1, color: red);
      c.setTool(DrawingTool.crayon);
      drawLine(c, const Offset(100, 100), const Offset(200, 200));
      c.setTool(DrawingTool.eraser);
      drawLine(c, const Offset(150, 100), const Offset(150, 200));

      c.undo();
      expect(c.artwork.strokes.map((s) => s.tool), [DrawingTool.crayon]);
      c.undo();
      expect(c.artwork.strokes, isEmpty);
      expect(c.artwork.fills, {'petal_1': red});
      c.undo();
      expect(c.artwork.fills, isEmpty);
      expect(c.canUndo, isFalse);

      c.redo();
      expect(c.artwork.fills, {'petal_1': red});
      c.redo();
      c.redo();
      expect(c.artwork.strokes.map((s) => s.tool), [DrawingTool.crayon, DrawingTool.eraser]);
      expect(c.canRedo, isFalse);

      // A new action clears the redo stack.
      c.undo();
      c.fillAt(petal2, color: blue);
      expect(c.canRedo, isFalse);
    });

    test('clear drawing keeps fills and outline; reset returns to blank', () {
      final c = newController();
      c.fillAt(petal1, color: red);
      c.setTool(DrawingTool.marker);
      drawLine(c, const Offset(100, 100), const Offset(300, 300));
      c.addSticker(const Offset(800, 800));
      final outline = flower.outline.length;

      c.clearDrawing();
      expect(c.artwork.strokes, isEmpty);
      expect(c.artwork.stickers, isEmpty);
      expect(c.artwork.fills, {'petal_1': red});
      expect(flower.outline.length, outline);
      c.undo();
      expect(c.artwork.strokes, hasLength(1));
      expect(c.artwork.stickers, hasLength(1));

      c.resetPicture();
      expect(c.artwork.isEmpty, isTrue);
      expect(flower.outline.length, outline);
      c.undo();
      expect(c.artwork.fills, {'petal_1': red}, reason: 'reset is undoable as a safety net');
    });

    test('history is bounded', () {
      final c = ColoringController(
        template: flower,
        artwork: ColoringArtwork(id: 'h', templateId: 'flower'),
        historyLimit: 10,
      );
      for (var i = 0; i < 30; i++) {
        c.fillAt(petal1, color: i.isEven ? red : blue);
      }
      expect(c.history.undoDepth, 10);
    });

    test('stickers move and are removed when dragged off the picture', () {
      final c = newController();
      final s = c.addSticker(const Offset(300, 300));
      c.dragSticker(s.id, const Offset(400, 420));
      c.endStickerDrag(s.id, const Offset(300, 300));
      expect(c.artwork.stickers.single.position, const Offset(400, 420));
      c.dragSticker(s.id, const Offset(1300, 420));
      c.endStickerDrag(s.id, const Offset(400, 420));
      expect(c.artwork.stickers, isEmpty);
      c.undo();
      expect(c.artwork.stickers.single.position, const Offset(400, 420));
    });

    test('strokes stay in template space at any canvas size', () {
      final c = newController()..setTool(DrawingTool.marker);
      final small = CanvasTransform.fit(const Size(320, 320), flower.viewBox);
      final big = CanvasTransform.fit(const Size(1280, 900), flower.viewBox);
      c.beginStroke(small.toTemplate(const Offset(160, 160)));
      c.endStroke();
      final p = c.artwork.strokes.single.points.single;
      expect((big.toTemplate(big.toLocal(p)) - const Offset(500, 500)).distance, lessThan(1e-6));
      expect(c.artwork.strokes.single.width, DrawingTool.marker.widthFor(c.brushSize));
    });
  });
}
