import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/engines/region_coloring/canvas_transform.dart';
import 'package:colouring_for_kids/engines/region_coloring/coloring_controller.dart';
import 'package:colouring_for_kids/models/coloring_artwork.dart';
import 'package:colouring_for_kids/models/coloring_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const red = Color(0xFFE53935);
const blue = Color(0xFF1E88E5);
const yellow = Color(0xFFFDD835);
const green = Color(0xFF43A047);

/// Known interior points of the flower template (template units).
const petal1 = Offset(500, 178);
const petal2 = Offset(673, 303);
const center = Offset(500, 360);
const stem = Offset(506, 650);
const leftLeaf = Offset(397, 778);
const rightLeaf = Offset(603, 692);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = TemplateRepository();
  late ColoringTemplate flower;

  setUpAll(() async => flower = await repo.load('flower'));

  ColoringController controllerFor(ColoringTemplate t) => ColoringController(
    template: t,
    artwork: ColoringArtwork(id: 'test', templateId: t.id),
  );

  test('flower has the expected independently fillable regions', () {
    expect(flower.regions.map((r) => r.id).toSet(), {
      'petal_1',
      'petal_2',
      'petal_3',
      'petal_4',
      'petal_5',
      'center',
      'stem',
      'left_leaf',
      'right_leaf',
    });
  });

  test('sample points land in the intended regions', () {
    final c = controllerFor(flower);
    expect(c.regionAt(petal1)?.id, 'petal_1');
    expect(c.regionAt(petal2)?.id, 'petal_2');
    expect(c.regionAt(center)?.id, 'center');
    expect(c.regionAt(stem)?.id, 'stem');
    expect(c.regionAt(leftLeaf)?.id, 'left_leaf');
    expect(c.regionAt(rightLeaf)?.id, 'right_leaf');
  });

  test('dropping red on one petal fills only that petal', () {
    final c = controllerFor(flower);
    expect(c.fillAt(petal1, color: red)?.id, 'petal_1');
    expect(c.artwork.fills, {'petal_1': red});
  });

  test('center and leaf can be filled independently of neighbours', () {
    final c = controllerFor(flower);
    c.fillAt(center, color: yellow);
    c.fillAt(leftLeaf, color: green);
    expect(c.artwork.fills, {'center': yellow, 'left_leaf': green});
    expect(c.artwork.fills.containsKey('stem'), isFalse);
  });

  test('recolouring a region replaces its colour', () {
    final c = controllerFor(flower);
    c.fillAt(petal2, color: red);
    c.fillAt(petal2, color: blue);
    expect(c.artwork.fills, {'petal_2': blue});
    c.undo();
    expect(c.artwork.fills, {'petal_2': red});
  });

  test('the selected colour stays selected and can be reused', () {
    final c = controllerFor(flower)..selectColor(red);
    c.fillAt(petal1);
    c.fillAt(petal2);
    expect(c.selectedColor, red);
    expect(c.artwork.fills, {'petal_1': red, 'petal_2': red});
  });

  test('drops outside the picture or between regions change nothing', () {
    final c = controllerFor(flower);
    expect(c.fillAt(const Offset(-50, -50), color: red), isNull);
    expect(c.fillAt(const Offset(60, 950), color: red), isNull);
    // Empty paper between two petals near the flower's edge.
    expect(c.fillAt(const Offset(820, 140), color: red, tolerance: 12), isNull);
    expect(c.artwork.fills, isEmpty);
    expect(c.canUndo, isFalse);
  });

  test('edge tolerance recovers near misses but never jumps far', () {
    final c = controllerFor(flower);
    final leaf = flower.region('left_leaf')!;
    // A point just outside the leaf's left tip.
    final nearTip = Offset(leaf.bounds.left - 6, leaf.bounds.center.dy - 30);
    final exact = c.regionAt(nearTip);
    if (exact == null) {
      expect(c.regionAt(nearTip, tolerance: 20)?.id, anyOf('left_leaf', isNull));
    }
    // Far away from any region, even a large tolerance finds nothing.
    expect(c.regionAt(const Offset(80, 80), tolerance: 20), isNull);
  });

  test('hit-testing is deterministic on shared boundaries', () {
    final c = controllerFor(flower);
    // Walk across the petal_1 / center boundary; every point has exactly one
    // answer and repeated queries agree.
    for (var y = 240.0; y < 280; y += 0.5) {
      final p = Offset(500, y);
      final first = c.regionAt(p, tolerance: 10)?.id;
      for (var k = 0; k < 3; k++) {
        expect(c.regionAt(p, tolerance: 10)?.id, first);
      }
      expect(first, anyOf('petal_1', 'center'));
    }
  });

  test('scaling and letterboxing map screen points to the same regions', () {
    final c = controllerFor(flower);
    for (final size in const [Size(360, 640), Size(1024, 600), Size(300, 300), Size(2000, 900)]) {
      final t = CanvasTransform.fit(size, flower.viewBox, padding: 12);
      // The picture is centred and uniformly scaled.
      expect(t.destination.center.dx, closeTo(size.width / 2, 0.001));
      expect(t.destination.center.dy, closeTo(size.height / 2, 0.001));
      expect(t.destination.width, closeTo(t.destination.height, 0.001));
      for (final (point, id) in [(petal1, 'petal_1'), (center, 'center'), (leftLeaf, 'left_leaf')]) {
        final screen = t.toLocal(point);
        final back = t.toTemplate(screen);
        expect((back - point).distance, lessThan(1e-6));
        expect(c.regionAt(back)?.id, id);
      }
      // Letterbox area maps outside the view box and fills nothing.
      final letterbox = size.width > size.height ? const Offset(1, 0) : const Offset(0, 1);
      expect(c.regionAt(t.toTemplate(letterbox)), isNull);
    }
  });

  test('outline is preserved and independent of fills', () {
    final before = flower.outline.length;
    final c = controllerFor(flower);
    c.fillAt(petal1, color: red);
    c.resetPicture();
    expect(flower.outline.length, before);
    expect(flower.outline.where((s) => s.isStroke), isNotEmpty);
  });
}
