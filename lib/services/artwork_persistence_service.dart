import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/coloring_artwork.dart';

/// Stores editable projects as one small JSON file each in
/// `<documents>/artworks/`. Exported PNGs live elsewhere, so exporting,
/// sharing or a refused gallery permission never affects a project.
///
/// Writes are debounced: a completed stroke or fill schedules a save, and
/// rapid actions collapse into one write.
class ArtworkStore extends ChangeNotifier {
  ArtworkStore(this.directory, {this.debounce = const Duration(milliseconds: 600)});

  final Directory directory;
  final Duration debounce;
  final Map<String, ColoringArtwork> _artworks = {};
  final Map<String, Timer> _pending = {};

  /// Ids of files that could not be read (kept on disk, never shown).
  final List<String> damaged = [];

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    _artworks.clear();
    damaged.clear();
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;
        try {
          final json = jsonDecode(await entity.readAsString()) as Map<String, dynamic>;
          final artwork = ColoringArtwork.fromJson(json);
          _artworks[artwork.id] = artwork;
        } catch (e) {
          damaged.add(entity.uri.pathSegments.last);
          debugPrint('Skipping unreadable artwork ${entity.path}: $e');
        }
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Newest first.
  List<ColoringArtwork> get all =>
      _artworks.values.where((a) => !a.isEmpty).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  ColoringArtwork? byId(String id) => _artworks[id];

  /// The project a child continues when they open [templateId] again.
  ColoringArtwork? latestFor(String templateId) {
    ColoringArtwork? best;
    for (final a in _artworks.values) {
      if (a.templateId != templateId || a.isEmpty) continue;
      if (best == null || a.updatedAt.isAfter(best.updatedAt)) best = a;
    }
    return best;
  }

  /// Returns the existing project for a template, or a new (unsaved) one.
  ColoringArtwork openFor(String templateId) =>
      latestFor(templateId) ??
      ColoringArtwork(id: '${templateId}_${DateTime.now().microsecondsSinceEpoch}', templateId: templateId);

  /// Schedules a debounced save of [artwork].
  void scheduleSave(ColoringArtwork artwork) {
    _artworks[artwork.id] = artwork;
    _pending.remove(artwork.id)?.cancel();
    _pending[artwork.id] = Timer(debounce, () => save(artwork));
  }

  /// Writes immediately. Empty projects are removed rather than stored.
  Future<void> save(ColoringArtwork artwork) async {
    _pending.remove(artwork.id)?.cancel();
    _artworks[artwork.id] = artwork;
    final file = _fileFor(artwork.id);
    try {
      if (artwork.isEmpty) {
        if (await file.exists()) await file.delete();
      } else {
        await directory.create(recursive: true);
        // Write to a temp file and rename, so a crash mid-write can never
        // leave a half-written project behind.
        final tmp = File('${file.path}.tmp');
        await tmp.writeAsString(jsonEncode(artwork.toJson()), flush: true);
        await tmp.rename(file.path);
      }
    } catch (e) {
      debugPrint('Could not save artwork ${artwork.id}: $e');
    }
    notifyListeners();
  }

  /// Writes every pending save now (app paused, studio closed).
  Future<void> flush() async {
    final ids = _pending.keys.toList();
    await Future.wait([
      for (final id in ids)
        if (_artworks[id] != null) save(_artworks[id]!),
    ]);
  }

  Future<void> delete(String id) async {
    _pending.remove(id)?.cancel();
    _artworks.remove(id);
    final file = _fileFor(id);
    try {
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Could not delete artwork $id: $e');
    }
    notifyListeners();
  }

  Future<void> deleteAll() async {
    for (final id in _artworks.keys.toList()) {
      await delete(id);
    }
  }

  File _fileFor(String id) {
    final safe = id.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    return File('${directory.path}${Platform.pathSeparator}$safe.json');
  }

  @override
  void dispose() {
    for (final t in _pending.values) {
      t.cancel();
    }
    super.dispose();
  }
}
