import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/engines/export/artwork_export_service.dart';
import 'package:colouring_for_kids/engines/region_coloring/canvas_transform.dart';
import 'package:colouring_for_kids/models/brush_stroke.dart';
import 'package:colouring_for_kids/models/coloring_artwork.dart';
import 'package:colouring_for_kids/models/coloring_template.dart';
import 'package:colouring_for_kids/models/drawing_tool.dart';
import 'package:colouring_for_kids/services/export_flow.dart';
import 'package:colouring_for_kids/services/gallery_save_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const red = Color(0xFFE53935);
const white = Color(0xFFFFFFFF);
const darkBlue = Color(0xFF283593);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ColoringTemplate flower;
  late Directory tmp;

  setUpAll(() async => flower = await TemplateRepository().load('flower'));
  setUp(() => tmp = Directory.systemTemp.createTempSync('export_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  ColoringArtwork sample() => ColoringArtwork(
    id: 'flower_1',
    templateId: 'flower',
    fills: {'petal_1': red, 'center': white},
    strokes: [
      BrushStroke(
        id: 1,
        tool: DrawingTool.marker,
        color: darkBlue,
        width: 40,
        seed: 1,
        points: const [Offset(80, 900), Offset(250, 900)],
      ),
    ],
  );

  test('exports a valid, high-resolution PNG with fills, outline and strokes', () async {
    const service = ArtworkExportService();
    final png = await service.renderPng(flower, sample());
    expect(png.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

    final image = await decodePng(png);
    expect(image.width, 2048);
    expect(image.height, 2048, reason: 'square template keeps its aspect ratio');
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final t = CanvasTransform.fit(const Size(2048, 2048), flower.viewBox, padding: 2048 * 0.04);
    Future<Color> at(Offset templatePoint) {
      final p = t.toLocal(templatePoint);
      return pixelAt(image, p.dx.round(), p.dy.round(), cache: data);
    }

    expect(closeColor(await pixelAt(image, 2, 2, cache: data), white), isTrue, reason: 'white background');
    expect(closeColor(await at(const Offset(500, 178)), red), isTrue, reason: 'petal fill');
    expect(closeColor(await at(const Offset(673, 303)), white), isTrue, reason: 'unfilled petal stays white');
    expect(closeColor(await at(const Offset(160, 900)), darkBlue), isTrue, reason: 'drawn stroke');
    // Outline over the white-filled centre is still visible (dark).
    final centre = flower.region('center')!;
    final edge = await at(Offset(centre.bounds.right - 3, centre.bounds.center.dy));
    expect(edge.computeLuminance(), lessThan(0.15), reason: 'outline visible next to a white region');
  });

  test('export contains only the artwork: no UI, same result every time', () async {
    const service = ArtworkExportService(longestSide: 512);
    final a = await service.renderPng(flower, sample());
    final b = await service.renderPng(flower, sample());
    expect(a, equals(b));
    final blank = await service.renderPng(flower, ColoringArtwork(id: 'x', templateId: 'flower'));
    final image = await decodePng(blank);
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    // A blank export is white paper plus black line art and nothing else.
    for (var i = 0; i < data.lengthInBytes; i += 4 * 97) {
      final r = data.getUint8(i), g = data.getUint8(i + 1), bl = data.getUint8(i + 2);
      final grey = (r - g).abs() < 20 && (g - bl).abs() < 30;
      expect(grey, isTrue, reason: 'unexpected colour in blank export at byte $i');
    }
  });

  test('file names are simple and contain no personal data', () {
    expect(
      ArtworkExportService.fileNameFor('flower', DateTime(2026, 10, 21)),
      'flower_coloring_2026-10-21.png',
    );
    expect(
      ArtworkExportService.fileNameFor('flower', DateTime(2026, 1, 2), copy: 3),
      'flower_coloring_2026-01-02_3.png',
    );
  });

  group('gallery saving', () {
    final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 1, 2, 3]);

    test('saves to the gallery and keeps a local copy', () async {
      final gallery = FakeGallery();
      final svc = GallerySaveService(exportsDirectory: Directory('${tmp.path}/exports'), gallery: gallery);
      final r = await svc.savePng(png, 'flower_coloring_2026-10-21.png');
      expect(r.outcome, SaveOutcome.savedToGallery);
      expect(File(r.filePath!).existsSync(), isTrue);
      expect(gallery.saved, [r.filePath]);
      // A second export never overwrites the first.
      final r2 = await svc.savePng(png, 'flower_coloring_2026-10-21.png');
      expect(r2.filePath, endsWith('flower_coloring_2026-10-21_2.png'));
    });

    test('permission denied is reported honestly and the file is kept', () async {
      final svc = GallerySaveService(
        exportsDirectory: Directory('${tmp.path}/exports'),
        gallery: FakeGallery(grant: false),
      );
      final r = await svc.savePng(png, 'a.png');
      expect(r.outcome, SaveOutcome.permissionDenied);
      expect(File(r.filePath!).existsSync(), isTrue);
      expect(ExportFlow.messageFor(r.outcome), isNot(contains('photos')));
    });

    test('a write failure is a failure, never a success', () async {
      final blocker = File('${tmp.path}/not_a_dir')..writeAsStringSync('x');
      final svc = GallerySaveService(exportsDirectory: Directory(blocker.path), gallery: FakeGallery());
      final r = await svc.savePng(png, 'a.png');
      expect(r.outcome, SaveOutcome.failed);
      expect(r.hasFile, isFalse);
    });

    test('unsupported platforms keep the PNG in the app; gallery errors fall back', () async {
      final none = GallerySaveService(
        exportsDirectory: Directory('${tmp.path}/e1'),
        gallery: FakeGallery(supported: false),
      );
      expect((await none.savePng(png, 'a.png')).outcome, SaveOutcome.savedInApp);
      final broken = GallerySaveService(
        exportsDirectory: Directory('${tmp.path}/e2'),
        gallery: FakeGallery(throwOnPut: true),
      );
      final r = await broken.savePng(png, 'a.png');
      expect(r.outcome, SaveOutcome.savedInApp);
      expect(ExportFlow.messageFor(r.outcome), isNot(contains('photos')));
    });
  });

  test('saving a picture keeps the editable project', () async {
    final services = testServices(tmp);
    final artwork = sample();
    final outcome = await ExportFlow.save(services, flower, artwork);
    expect(outcome.succeeded, isTrue);
    expect(outcome.png, isNotNull);
    expect(artwork.lastExportPath, isNotNull);
    // The project is still editable and on disk, separate from the PNG.
    await services.artworks.load();
    final reloaded = services.artworks.byId('flower_1')!;
    expect(reloaded.fills, {'petal_1': red, 'center': white});
    File(artwork.lastExportPath!).deleteSync();
    await services.artworks.load();
    expect(services.artworks.byId('flower_1'), isNotNull, reason: 'deleting a PNG never deletes the project');
  });
}
