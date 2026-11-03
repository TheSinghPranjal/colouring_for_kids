import 'package:flutter/widgets.dart';

import '../data/template_repository.dart';
import '../engines/export/artwork_export_service.dart';
import 'app_settings.dart';
import 'artwork_persistence_service.dart';
import 'gallery_save_service.dart';
import 'share_service.dart';
import 'sound_service.dart';

/// Everything the screens need, created once in main() (or by a test).
class AppServices {
  AppServices({
    required this.settings,
    required this.artworks,
    required this.templates,
    required this.gallery,
    required this.sound,
    this.exporter = const ArtworkExportService(),
    this.share = const ShareService(),
  });

  final AppSettings settings;
  final ArtworkStore artworks;
  final TemplateRepository templates;
  final GallerySaveService gallery;
  final SoundService sound;
  final ArtworkExportService exporter;
  final ShareService share;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.services != services;
}
