import 'dart:io';
import 'dart:ui' as ui;

import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/models/coloring_region.dart';
import 'package:colouring_for_kids/services/app_scope.dart';
import 'package:colouring_for_kids/services/app_settings.dart';
import 'package:colouring_for_kids/services/artwork_persistence_service.dart';
import 'package:colouring_for_kids/services/gallery_save_service.dart';
import 'package:colouring_for_kids/services/sound_service.dart';
import 'package:flutter/services.dart';

/// A photo gallery double that records what was saved.
class FakeGallery implements PhotoGallery {
  FakeGallery({this.supported = true, this.grant = true, this.throwOnPut = false});

  bool supported;
  bool grant;
  bool throwOnPut;
  final List<String> saved = [];

  @override
  bool get isSupported => supported;

  @override
  Future<bool> hasAccess() async => grant;

  @override
  Future<bool> requestAccess() async => grant;

  @override
  Future<void> putImage(String path) async {
    if (throwOnPut) throw StateError('gallery unavailable');
    saved.add(path);
  }
}

/// Services backed by a temporary folder, with sound silenced and motion
/// reduced so widget tests can settle.
AppServices testServices(Directory root, {FakeGallery? gallery, TemplateRepository? templates}) {
  final settings = AppSettings()
    ..reducedMotion = true
    ..hints = false
    ..demonstrations = false;
  return AppServices(
    settings: settings,
    artworks: ArtworkStore(Directory('${root.path}/artworks'), debounce: Duration.zero),
    templates: templates ?? TemplateRepository(),
    gallery: GallerySaveService(
      exportsDirectory: Directory('${root.path}/exports'),
      gallery: gallery ?? FakeGallery(),
    ),
    sound: SoundService.silent(settings),
  );
}

/// Finds a point that lies inside [region] (not just inside its bounds),
/// preferring one far from the edge, by scanning a grid over its bounds.
ui.Offset interiorPoint(ColoringRegion region, {double step = 4}) {
  final b = region.bounds;
  ui.Offset? best;
  var bestScore = -1.0;
  for (var y = b.top + step / 2; y < b.bottom; y += step) {
    for (var x = b.left + step / 2; x < b.right; x += step) {
      final p = ui.Offset(x, y);
      if (!region.contains(p)) continue;
      // Score: distance to the nearest outside sample on 8 rays (cheap).
      var score = 0.0;
      for (var r = step; r < 60; r += step) {
        var allIn = true;
        for (final d in const [
          ui.Offset(1, 0),
          ui.Offset(-1, 0),
          ui.Offset(0, 1),
          ui.Offset(0, -1),
          ui.Offset(0.7, 0.7),
          ui.Offset(-0.7, 0.7),
          ui.Offset(0.7, -0.7),
          ui.Offset(-0.7, -0.7),
        ]) {
          if (!region.contains(p + d * r)) {
            allIn = false;
            break;
          }
        }
        if (!allIn) break;
        score = r;
      }
      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }
  }
  if (best == null) throw StateError('No interior point for ${region.templateId}/${region.id}');
  return best;
}

/// RGBA of one pixel of a decoded image.
Future<ui.Color> pixelAt(ui.Image image, int x, int y, {ByteData? cache}) async {
  final data = cache ?? (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final i = (y * image.width + x) * 4;
  return ui.Color.fromARGB(
    data.getUint8(i + 3),
    data.getUint8(i),
    data.getUint8(i + 1),
    data.getUint8(i + 2),
  );
}

Future<ui.Image> decodePng(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

bool closeColor(ui.Color a, ui.Color b, {int tolerance = 12}) =>
    ((a.r - b.r) * 255).abs() <= tolerance &&
    ((a.g - b.g) * 255).abs() <= tolerance &&
    ((a.b - b.b) * 255).abs() <= tolerance;

/// Loads the bundled Baloo 2 font so widget tests measure real text widths
/// (the default test font is much wider than real glyphs).
Future<void> loadAppFonts() async {
  final loader = FontLoader('Baloo2')..addFont(rootBundle.load('assets/fonts/Baloo2.ttf'));
  await loader.load();
}
