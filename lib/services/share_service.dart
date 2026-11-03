import 'dart:ui';

import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet for an exported PNG.
class ShareService {
  const ShareService();

  /// Returns false if the platform could not show a share sheet.
  Future<bool> sharePng(String path, {String? title, Rect? origin}) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'image/png')],
          subject: title,
          sharePositionOrigin: origin,
        ),
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (_) {
      return false;
    }
  }
}
