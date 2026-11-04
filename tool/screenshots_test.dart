// Renders key screens to PNGs for visual review:
//   SHOTS=/some/dir flutter test tool/screenshots_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:colouring_for_kids/app.dart';
import 'package:colouring_for_kids/data/coloring_catalog.dart';
import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/models/coloring_artwork.dart';
import 'package:colouring_for_kids/models/drawing_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers.dart';

void main() {
  final out = Platform.environment['SHOTS'] ?? 'build/screenshots';

  testWidgets('screenshots', (tester) async {
    final tmp = Directory.systemTemp.createTempSync('shots');
    final repo = TemplateRepository();
    final services = testServices(tmp, templates: repo);
    await tester.runAsync(() async {
      await loadAppFonts();
      final icons = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      for (final t in ColoringCatalog.allTemplates) {
        await repo.load(t.id);
      }
      await services.artworks.save(
        ColoringArtwork(
          id: 'cat_1',
          templateId: 'cat',
          fills: {
            'head': const Color(0xFFFB8C00),
            'body': const Color(0xFFFB8C00),
            'muzzle': const Color(0xFFFFCCBC),
          },
        ),
      );
      Directory(out).createSync(recursive: true);
    });
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.5);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    await tester.pumpWidget(RepaintBoundary(child: ColoringApp(services: services)));
    await shot('1_home');
    await tester.tap(find.bySemanticsLabel('Play'));
    await shot('2_categories');
    await tester.tap(find.bySemanticsLabel('Flowers & Garden, 10 pictures').first);
    await shot('3_sketches');
    await tester.tap(find.bySemanticsLabel('Flower'));
    await tester.pumpAndSettle();
    final c = services.artworks;
    await shot('4_studio_fill');
    await tester.tap(find.bySemanticsLabel('Red'));
    await tester.pump();
    // Colour a few parts via the real canvas.
    final paint = find.descendant(
      of: find.bySemanticsLabel('Coloring picture: Flower'),
      matching: find.byType(CustomPaint),
    );
    final box = tester.renderObject<RenderBox>(paint.first);
    Offset at(Offset p) {
      final s = box.size;
      final scale = (s.shortestSide - 20) / 1000;
      final off = Offset((s.width - 1000 * scale) / 2, (s.height - 1000 * scale) / 2);
      return box.localToGlobal(off + p * scale);
    }

    for (final (label, p) in [
      ('Red', const Offset(500, 178)),
      ('Orange', const Offset(673, 303)),
      ('Yellow', const Offset(500, 360)),
      ('Green', const Offset(397, 778)),
    ]) {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pump();
      await tester.tapAt(at(p));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.bySemanticsLabel('Draw mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Watercolor'));
    await tester.tap(find.bySemanticsLabel('Blue'));
    await tester.pump();
    await tester.dragFrom(at(const Offset(120, 120)), const Offset(80, 60));
    await tester.pumpAndSettle();
    expect(c.latestFor('flower')!.strokes.single.tool, DrawingTool.watercolor);
    await shot('5_studio_draw');
    await tester.tap(find.bySemanticsLabel('Stickers mode'));
    await tester.pumpAndSettle();
    await tester.tapAt(at(const Offset(820, 850)));
    await shot('6_studio_stickers');
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('My Artwork'));
    await shot('7_my_artwork');
  });
}
