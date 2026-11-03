import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

enum SaveOutcome {
  /// In the device photo gallery (and kept in the app).
  savedToGallery,

  /// Kept in the app's own folder; this platform has no photo gallery.
  savedInApp,

  /// The parent declined photo access; the PNG is kept in the app.
  permissionDenied,

  /// Nothing could be written.
  failed,
}

class SaveResult {
  const SaveResult(this.outcome, {this.filePath, this.detail});

  final SaveOutcome outcome;

  /// Local copy of the PNG, usable for sharing. Null only when [failed].
  final String? filePath;
  final String? detail;

  bool get hasFile => filePath != null;
}

/// Abstracts the photo-gallery plugin so tests and unsupported platforms can
/// substitute their own behaviour.
abstract class PhotoGallery {
  bool get isSupported;
  Future<bool> hasAccess();
  Future<bool> requestAccess();
  Future<void> putImage(String path);
}

class GalPhotoGallery implements PhotoGallery {
  const GalPhotoGallery();

  @override
  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  // No album is used: on iOS that keeps the request to the add-only photo
  // permission instead of full library access.
  @override
  Future<bool> hasAccess() => Gal.hasAccess();

  @override
  Future<bool> requestAccess() => Gal.requestAccess();

  @override
  Future<void> putImage(String path) => Gal.putImage(path);
}

/// Saves exported PNGs: always to the app's exports folder first, then to
/// the device gallery where supported. Success is reported only after the
/// platform call returns without error.
class GallerySaveService {
  GallerySaveService({required this.exportsDirectory, PhotoGallery? gallery})
    : gallery = gallery ?? const GalPhotoGallery();

  final Directory exportsDirectory;
  final PhotoGallery gallery;

  Future<SaveResult> savePng(Uint8List bytes, String fileName) async {
    final File file;
    try {
      file = await writeExport(bytes, fileName);
    } catch (e) {
      return SaveResult(SaveOutcome.failed, detail: 'Could not write the file ($e)');
    }
    if (!gallery.isSupported) return SaveResult(SaveOutcome.savedInApp, filePath: file.path);
    try {
      var access = await gallery.hasAccess();
      if (!access) access = await gallery.requestAccess();
      if (!access) return SaveResult(SaveOutcome.permissionDenied, filePath: file.path);
      await gallery.putImage(file.path);
      return SaveResult(SaveOutcome.savedToGallery, filePath: file.path);
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied) {
        return SaveResult(SaveOutcome.permissionDenied, filePath: file.path);
      }
      return SaveResult(SaveOutcome.savedInApp, filePath: file.path, detail: e.type.message);
    } catch (e) {
      return SaveResult(SaveOutcome.savedInApp, filePath: file.path, detail: '$e');
    }
  }

  /// Writes the PNG into the app's exports folder without touching the
  /// gallery (used for sharing). Never overwrites an earlier export.
  Future<File> writeExport(Uint8List bytes, String fileName) async {
    await exportsDirectory.create(recursive: true);
    final dot = fileName.lastIndexOf('.');
    final stem = dot > 0 ? fileName.substring(0, dot) : fileName;
    final ext = dot > 0 ? fileName.substring(dot) : '.png';
    var candidate = File('${exportsDirectory.path}${Platform.pathSeparator}$fileName');
    var n = 2;
    while (await candidate.exists()) {
      candidate = File('${exportsDirectory.path}${Platform.pathSeparator}${stem}_$n$ext');
      n++;
    }
    await candidate.writeAsBytes(bytes, flush: true);
    return candidate;
  }
}
