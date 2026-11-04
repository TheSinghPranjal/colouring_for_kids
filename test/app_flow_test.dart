import 'dart:io';

import 'package:colouring_for_kids/app.dart';
import 'package:colouring_for_kids/data/coloring_catalog.dart';
import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/engines/region_coloring/canvas_transform.dart';
import 'package:colouring_for_kids/engines/region_coloring/coloring_canvas.dart';
import 'package:colouring_for_kids/models/drawing_tool.dart';
import 'package:colouring_for_kids/screens/artwork_preview_screen.dart';
import 'package:colouring_for_kids/screens/coloring_studio_screen.dart';
import 'package:colouring_for_kids/screens/home_screen.dart';
import 'package:colouring_for_kids/screens/splash_screen.dart';
import 'package:colouring_for_kids/services/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const red = Color(0xFFE53935);
const blue = Color(0xFF1E88E5);
const petal1 = Offset(500, 178);
const petal2 = Offset(673, 303);

void main() {
  late Directory tmp;
  late TemplateRepository repo;

  setUp(() => tmp = Directory.systemTemp.createTempSync('flow_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<AppServices> boot(WidgetTester tester, FakeGallery gallery) async {
    repo = TemplateRepository();
    final services = testServices(tmp, gallery: gallery, templates: repo);
    await tester.runAsync(() async {
      await loadAppFonts();
      for (final t in ColoringCatalog.allTemplates) {
        await repo.load(t.id);
      }
      await services.artworks.load();
    });
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ColoringApp(services: services));
    await tester.pumpAndSettle();
    return services;
  }

  /// Global screen position of a template point on the studio canvas.
  Offset onCanvas(WidgetTester tester, Offset templatePoint) {
    final paint = find.descendant(of: find.byType(ColoringCanvas), matching: find.byType(CustomPaint)).first;
    final box = tester.renderObject<RenderBox>(paint);
    final t = CanvasTransform.fit(box.size, const Rect.fromLTWH(0, 0, 1000, 1000), padding: 10);
    return box.localToGlobal(t.toLocal(templatePoint));
  }

  Finder swatch(String name) => find.bySemanticsLabel(name);

  testWidgets('full acceptance flow on the real app', (tester) async {
    final gallery = FakeGallery();
    final services = await boot(tester, gallery);

    // Splash → Title → Picture hub → Flowers & Garden → Flower.
    expect(find.byType(HomeScreen), findsOneWidget, reason: 'splash hands over to the title screen');
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.bySemanticsLabel(RegExp('^Keep Coloring')), findsNothing, reason: 'nothing to continue yet');
    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a Picture'), findsOneWidget);
    for (final c in ColoringCatalog.categories) {
      await tester.scrollUntilVisible(
        find.bySemanticsLabel('${c.title}, 10 pictures'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Flowers & Garden, 10 pictures').last);
    await tester.pumpAndSettle();
    for (final id in ColoringCatalog.category('flowers_garden')!.templateIds) {
      final title = ColoringCatalog.template(id)!.title;
      await tester.scrollUntilVisible(
        find.bySemanticsLabel(title),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.bySemanticsLabel(title), findsWidgets);
    }
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Flower').first);
    await tester.pumpAndSettle();
    expect(find.byType(ColoringStudioScreen), findsOneWidget);
    final studio = tester.state(find.byType(ColoringStudioScreen));
    expect(studio.widget, isA<ColoringStudioScreen>().having((s) => s.templateId, 'template', 'flower'));

    // 1. Drag red from the palette onto petal 1.
    final start = tester.getCenter(swatch('Red'));
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(0, -40)); // vertical: a drag, not a palette scroll
    await tester.pump();
    await gesture.moveTo(onCanvas(tester, petal1));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    final artwork = services.artworks.all.single;
    expect(artwork.fills, {'petal_1': red}, reason: 'only the dropped-on petal turns red');

    // 2. Tap blue, then tap another petal (tap-to-fill).
    await tester.tap(swatch('Blue'));
    await tester.pump();
    await tester.tapAt(onCanvas(tester, petal2));
    await tester.pumpAndSettle();
    expect(artwork.fills, {'petal_1': red, 'petal_2': blue});

    // A drop on empty paper paints the canvas background (not a petal).
    final paper = await tester.startGesture(tester.getCenter(swatch('Green')));
    await paper.moveBy(const Offset(0, -40));
    await tester.pump();
    await paper.moveTo(onCanvas(tester, const Offset(60, 60)));
    await tester.pump();
    await paper.up();
    await tester.pumpAndSettle();
    expect(artwork.fills, {'petal_1': red, 'petal_2': blue});
    expect(artwork.backgroundColor, const Color(0xFF43A047));

    // A drop completely off the picture still changes nothing and returns the swatch.
    final miss = await tester.startGesture(tester.getCenter(swatch('Yellow')));
    await miss.moveBy(const Offset(0, -40));
    await tester.pump();
    await miss.moveTo(onCanvas(tester, const Offset(-80, -80)));
    await tester.pump();
    await miss.up();
    await tester.pumpAndSettle();
    expect(artwork.fills, {'petal_1': red, 'petal_2': blue});
    expect(artwork.backgroundColor, const Color(0xFF43A047));

    // 3. Blue pencil mark across the flower (never fills). Dragging green
    // above selected it, so pick blue again.
    await tester.tap(swatch('Blue'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Draw mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Pencil'));
    await tester.pumpAndSettle();
    await tester.dragFrom(onCanvas(tester, const Offset(150, 600)), const Offset(160, 30));
    await tester.pumpAndSettle();
    expect(artwork.strokes.single.tool, DrawingTool.pencil);
    expect(artwork.strokes.single.color, blue);
    expect(artwork.fills, {'petal_1': red, 'petal_2': blue});

    // 4. Erase that mark; fills and outline untouched.
    await tester.tap(find.bySemanticsLabel('Eraser'));
    await tester.pumpAndSettle();
    await tester.dragFrom(onCanvas(tester, const Offset(150, 600)), const Offset(160, 30));
    await tester.pumpAndSettle();
    expect(artwork.strokes.map((s) => s.tool), [DrawingTool.pencil, DrawingTool.eraser]);
    expect(artwork.fills, {'petal_1': red, 'petal_2': blue});

    // 5. Undo the erase.
    await tester.tap(find.bySemanticsLabel('Undo'));
    await tester.pumpAndSettle();
    expect(artwork.strokes.map((s) => s.tool), [DrawingTool.pencil]);

    // 5b. Stickers: tap the picture on a filled petal (semantics must not block).
    await tester.tap(find.bySemanticsLabel('Stickers mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Heart sticker'));
    await tester.pump();
    await tester.tapAt(onCanvas(tester, petal1));
    await tester.pumpAndSettle();
    expect(artwork.stickers, hasLength(1));

    // 6. Save as PNG.
    await tester.runAsync(() async {
      await tester.tap(find.bySemanticsLabel('Save'));
      for (var i = 0; i < 100 && find.byType(ArtworkPreviewScreen).evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    expect(find.byType(ArtworkPreviewScreen), findsOneWidget);
    expect(find.text('Saved to your photos!'), findsOneWidget);
    expect(gallery.saved, hasLength(1));
    final png = File(gallery.saved.single).readAsBytesSync();
    expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    expect(find.bySemanticsLabel('Color Another Picture'), findsOneWidget);
    expect(find.bySemanticsLabel('Back to Gallery'), findsOneWidget);
    expect(find.bySemanticsLabel('Share'), findsOneWidget);

    // 7. "Close the app" and start again from disk.
    await tester.runAsync(() => services.artworks.flush());
    await tester.pumpWidget(const SizedBox());
    final relaunched = testServices(tmp, gallery: gallery, templates: repo);
    await tester.runAsync(() => relaunched.artworks.load());
    await tester.pumpWidget(ColoringApp(services: relaunched));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Keep Coloring Flower'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Continue Coloring'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Continue Flower'));
    await tester.pumpAndSettle();
    final resumed = relaunched.artworks.all.single;
    expect(resumed.fills, {'petal_1': red, 'petal_2': blue});
    expect(resumed.strokes.map((s) => s.tool), [DrawingTool.pencil]);
    // Still editable after resuming.
    await tester.tap(swatch('Yellow'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Fill mode'));
    await tester.pumpAndSettle();
    await tester.tapAt(onCanvas(tester, const Offset(500, 360)));
    await tester.pumpAndSettle();
    expect(resumed.fills['center'], const Color(0xFFFDD835));
  });

  testWidgets('every gallery card opens its own template', (tester) async {
    await boot(tester, FakeGallery());
    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pumpAndSettle();
    for (final category in ColoringCatalog.categories) {
      final card = find.bySemanticsLabel('${category.title}, 10 pictures');
      await tester.scrollUntilVisible(card, 150, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      await tester.tap(card.first);
      await tester.pumpAndSettle();
      for (final id in category.templateIds) {
        final title = ColoringCatalog.template(id)!.title;
        await tester.scrollUntilVisible(
          find.bySemanticsLabel(title),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel(title).first);
        await tester.pumpAndSettle();
        final screen = tester.widget<ColoringStudioScreen>(find.byType(ColoringStudioScreen));
        expect(screen.templateId, id);
        expect(
          find.bySemanticsLabel('Coloring picture: $title'),
          findsOneWidget,
        );
        await tester.tap(find.bySemanticsLabel('Back'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('title screen: Keep Coloring resumes, hub Back returns, small phone fits', (tester) async {
    final services = await boot(tester, FakeGallery());
    // Hub back button returns to the title screen.
    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a Picture'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.bySemanticsLabel('My Artwork'), findsOneWidget);
    expect(find.bySemanticsLabel('Grown-ups settings'), findsOneWidget);

    // Start a picture, come back, and resume it from the title screen.
    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Flowers & Garden, 10 pictures').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Flower'));
    await tester.pumpAndSettle();
    await tester.tap(swatch('Red'));
    await tester.pump();
    await tester.tapAt(onCanvas(tester, petal1));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(ColoringStudioScreen))).popUntil((r) => r.isFirst);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Keep Coloring Flower'));
    await tester.pumpAndSettle();
    final studio = tester.widget<ColoringStudioScreen>(find.byType(ColoringStudioScreen));
    expect(studio.artworkId, services.artworks.all.single.id);

    // Splash and title lay out on a small phone and a landscape tablet.
    for (final size in const [Size(320, 568), Size(1366, 1024)]) {
      await tester.pumpWidget(const SizedBox());
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(ColoringApp(services: services));
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'splash at $size');
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'title at $size');
      expect(find.bySemanticsLabel('Play'), findsOneWidget);
    }
  });

  testWidgets('studio fits a small phone and a landscape tablet without overflow', (tester) async {
    for (final size in const [Size(320, 568), Size(1366, 1024)]) {
      await tester.pumpWidget(const SizedBox());
      repo = TemplateRepository();
      final services = testServices(tmp, templates: repo);
      await tester.runAsync(() async {
        await loadAppFonts();
        await repo.load('car');
        await services.artworks.load();
      });
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        AppScope(
          services: services,
          child: const MaterialApp(home: ColoringStudioScreen(templateId: 'car')),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'layout at $size');
      expect(find.bySemanticsLabel('Save'), findsOneWidget);
      expect(find.bySemanticsLabel('Undo'), findsOneWidget);
      expect(find.bySemanticsLabel('Red'), findsOneWidget);
    }
  });
}
