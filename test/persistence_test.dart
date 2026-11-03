import 'dart:io';

import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/engines/region_coloring/coloring_controller.dart';
import 'package:colouring_for_kids/models/coloring_artwork.dart';
import 'package:colouring_for_kids/models/drawing_tool.dart';
import 'package:colouring_for_kids/services/app_settings.dart';
import 'package:colouring_for_kids/services/artwork_persistence_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const red = Color(0xFFE53935);
const blue = Color(0xFF1E88E5);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('persist_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  ArtworkStore store() =>
      ArtworkStore(Directory('${tmp.path}/artworks'), debounce: const Duration(milliseconds: 10));

  test('partial coloring, strokes and studio choices resume after restart', () async {
    final flower = await TemplateRepository().load('flower');
    final s1 = store();
    await s1.load();
    final artwork = s1.openFor('flower');
    final c = ColoringController(template: flower, artwork: artwork, onArtworkChanged: s1.scheduleSave);
    c.fillAt(const Offset(500, 178), color: red);
    c.setTool(DrawingTool.watercolor);
    c.setBrushSize(BrushSize.large);
    c.selectColor(blue);
    c.beginStroke(const Offset(100, 100));
    c.extendStroke(const Offset(150, 160));
    c.extendStroke(const Offset(200, 220));
    c.endStroke();
    await s1.flush();

    // "Close the app": a brand-new store reading the same folder.
    final s2 = store();
    await s2.load();
    final resumed = s2.latestFor('flower')!;
    expect(resumed.id, artwork.id);
    expect(resumed.fills, {'petal_1': red});
    expect(resumed.strokes.single.tool, DrawingTool.watercolor);
    expect(resumed.strokes.single.points.length, 3);
    expect(resumed.strokes.single.color, blue);
    final c2 = ColoringController(template: flower, artwork: resumed);
    expect(c2.selectedColor, blue);
    expect(c2.tool, DrawingTool.watercolor);
    expect(c2.brushSize, BrushSize.large);
    expect(c2.mode, StudioMode.draw);
  });

  test('debounced saves write once per burst, not per pointer move', () async {
    final s = store();
    final a = ColoringArtwork(id: 'burst', templateId: 'flower', fills: {'center': red});
    for (var i = 0; i < 50; i++) {
      s.scheduleSave(a);
    }
    final file = File('${tmp.path}/artworks/burst.json');
    expect(file.existsSync(), isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(file.existsSync(), isTrue);
  });

  test('deleting one project leaves the others alone', () async {
    final s = store();
    await s.save(ColoringArtwork(id: 'a', templateId: 'flower', fills: {'center': red}));
    await s.save(ColoringArtwork(id: 'b', templateId: 'cat', fills: {'head': blue}));
    await s.delete('a');
    final reloaded = store();
    await reloaded.load();
    expect(reloaded.all.map((x) => x.id), ['b']);
  });

  test('empty projects are not kept; reset removes the saved file', () async {
    final s = store();
    final a = ColoringArtwork(id: 'r', templateId: 'flower', fills: {'center': red});
    await s.save(a);
    a.fills.clear();
    await s.save(a);
    expect(File('${tmp.path}/artworks/r.json').existsSync(), isFalse);
  });

  test('invalid or future-version data is skipped without crashing', () async {
    final dir = Directory('${tmp.path}/artworks')..createSync(recursive: true);
    File('${dir.path}/broken.json').writeAsStringSync('{not json');
    File(
      '${dir.path}/future.json',
    ).writeAsStringSync('{"schemaVersion": 99, "id": "f", "templateId": "flower"}');
    File('${dir.path}/noid.json').writeAsStringSync('{"schemaVersion": 1}');
    final s = store();
    await s.save(ColoringArtwork(id: 'ok', templateId: 'flower', fills: {'center': red}));
    await s.load();
    expect(s.all.map((a) => a.id), ['ok']);
    expect(s.damaged, hasLength(3));
  });

  test('fills for regions removed in an app update are dropped gracefully', () async {
    final flower = await TemplateRepository().load('flower');
    final a = ColoringArtwork(id: 'old', templateId: 'flower', fills: {'center': red, 'petal_99': blue});
    final c = ColoringController(template: flower, artwork: a);
    expect(c.artwork.fills, {'center': red});
  });

  test('settings persist and fall back to defaults when unreadable', () async {
    final file = File('${tmp.path}/settings.json');
    final s = await AppSettings.load(file);
    expect(s.soundEffects, isTrue);
    s.update((x) {
      x.ageMode = AgeMode.littleArtist;
      x.soundEffects = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final again = await AppSettings.load(file);
    expect(again.ageMode, AgeMode.littleArtist);
    expect(again.soundEffects, isFalse);
    file.writeAsStringSync('garbage');
    final fallback = await AppSettings.load(file);
    expect(fallback.ageMode, AgeMode.creativeExplorer);
  });
}
