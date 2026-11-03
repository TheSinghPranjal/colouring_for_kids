import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import '../engines/export/artwork_export_service.dart';
import '../models/coloring_artwork.dart';
import '../models/coloring_template.dart';
import 'app_scope.dart';
import 'gallery_save_service.dart';

class ExportOutcome {
  const ExportOutcome(this.png, this.result);

  final Uint8List? png;
  final SaveResult result;

  bool get succeeded => result.outcome != SaveOutcome.failed;
}

/// Shared "Save Picture" and "Share" steps. The editable project is saved
/// first and is never modified or removed by exporting.
class ExportFlow {
  ExportFlow._();

  static Future<ExportOutcome> save(AppServices s, ColoringTemplate template, ColoringArtwork artwork) async {
    await s.artworks.save(artwork);
    final Uint8List png;
    try {
      png = await s.exporter.renderPng(template, artwork);
    } on ExportException catch (e) {
      return ExportOutcome(null, SaveResult(SaveOutcome.failed, detail: e.message));
    }
    final result = await s.gallery.savePng(
      png,
      ArtworkExportService.fileNameFor(template.id, DateTime.now()),
    );
    if (result.hasFile) {
      artwork
        ..lastExportedAt = DateTime.now()
        ..lastExportPath = result.filePath;
      await s.artworks.save(artwork);
    }
    return ExportOutcome(png, result);
  }

  /// Shares the most recent export if it is still current, otherwise renders
  /// a fresh PNG first. Returns false if sharing was not possible.
  static Future<bool> share(
    AppServices s,
    ColoringTemplate template,
    ColoringArtwork artwork, {
    Rect? origin,
  }) async {
    var path = artwork.lastExportPath;
    final exportedAt = artwork.lastExportedAt;
    final current =
        path != null &&
        exportedAt != null &&
        !artwork.updatedAt.isAfter(exportedAt) &&
        await File(path).exists();
    if (!current) {
      try {
        final png = await s.exporter.renderPng(template, artwork);
        final file = await s.gallery.writeExport(
          png,
          ArtworkExportService.fileNameFor(template.id, DateTime.now()),
        );
        path = file.path;
      } catch (_) {
        return false;
      }
    }
    return s.share.sharePng(path, title: template.title, origin: origin);
  }

  static String messageFor(SaveOutcome outcome) => switch (outcome) {
    SaveOutcome.savedToGallery => 'Saved to your photos!',
    SaveOutcome.savedInApp => 'Saved in My Artwork!',
    SaveOutcome.permissionDenied => 'Kept safe in My Artwork',
    SaveOutcome.failed => "Oops! That didn't save.",
  };

  static String? detailFor(SaveOutcome outcome) => switch (outcome) {
    SaveOutcome.savedToGallery => null,
    SaveOutcome.savedInApp => 'You can share it from here any time.',
    SaveOutcome.permissionDenied =>
      'Photo access is off, so the picture was not added to the gallery. A grown-up can allow it in Settings, or use Share.',
    SaveOutcome.failed => 'Your picture is still here. Please try again.',
  };
}
