import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/template_repository.dart';
import 'services/app_scope.dart';
import 'services/app_settings.dart';
import 'services/artwork_persistence_service.dart';
import 'services/gallery_save_service.dart';
import 'services/sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  final docs = await getApplicationDocumentsDirectory();
  final support = await getApplicationSupportDirectory();
  String sub(Directory d, String name) => '${d.path}${Platform.pathSeparator}$name';

  final settings = await AppSettings.load(File(sub(support, 'settings.json')));
  final artworks = ArtworkStore(Directory(sub(docs, 'artworks')));
  await artworks.load();

  runApp(
    ColoringApp(
      services: AppServices(
        settings: settings,
        artworks: artworks,
        templates: TemplateRepository(),
        gallery: GallerySaveService(exportsDirectory: Directory(sub(docs, 'exports'))),
        sound: SoundService(settings),
      ),
    ),
  );
}
