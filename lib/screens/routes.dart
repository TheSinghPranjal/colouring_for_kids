import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/gallery_save_service.dart';
import '../widgets/kid_dialogs.dart';
import 'artwork_preview_screen.dart';
import 'category_gallery_screen.dart';
import 'coloring_studio_screen.dart';
import 'home_screen.dart';
import 'my_artwork_screen.dart';
import 'parent_settings_screen.dart';
import 'picture_hub_screen.dart';
import 'sketch_selection_screen.dart';

/// Every navigation in the app goes through here, so routes carry names
/// that "Back to Gallery" style buttons can return to.
class AppRoutes {
  AppRoutes._();

  static const home = 'home';
  static const hub = 'hub';
  static const categories = 'categories';
  static const sketches = 'sketches';
  static const studio = 'studio';
  static const myArtwork = 'my_artwork';
  static const preview = 'preview';
  static const parent = 'parent';

  static Route<T> _route<T>(String name, Widget page) => MaterialPageRoute<T>(
    settings: RouteSettings(name: name),
    builder: (_) => page,
  );

  /// Leaves the splash screen for the title screen with a soft fade.
  static void replaceWithHome(BuildContext context) => Navigator.pushReplacement(
    context,
    PageRouteBuilder<void>(
      settings: const RouteSettings(name: home),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, _, _) => const HomeScreen(),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    ),
  );

  static Future<void> hubPage(BuildContext context) =>
      Navigator.push(context, _route(hub, const PictureHubScreen()));

  static Future<void> categoriesPage(BuildContext context) =>
      Navigator.push(context, _route(categories, const CategoryGalleryScreen()));

  static Future<void> sketchesPage(BuildContext context, String categoryId) =>
      Navigator.push(context, _route(sketches, SketchSelectionScreen(categoryId: categoryId)));

  static Future<void> studioPage(BuildContext context, String templateId, {String? artworkId}) =>
      Navigator.push(
        context,
        _route(studio, ColoringStudioScreen(templateId: templateId, artworkId: artworkId)),
      );

  static Future<void> myArtworkPage(BuildContext context) =>
      Navigator.push(context, _route(myArtwork, const MyArtworkScreen()));

  static Future<void> previewPage(
    BuildContext context,
    String artworkId, {
    Uint8List? png,
    SaveResult? saveResult,
    bool replace = false,
  }) {
    final route = _route<void>(
      preview,
      ArtworkPreviewScreen(artworkId: artworkId, png: png, saveResult: saveResult),
    );
    return replace ? Navigator.pushReplacement(context, route) : Navigator.push(context, route);
  }

  static Future<void> parentPage(BuildContext context) async {
    if (!await showParentGate(context) || !context.mounted) return;
    await Navigator.push(context, _route(parent, const ParentSettingsScreen()));
  }

  /// Pops back to the closest route named [name], or replaces the stack
  /// above the title screen with a fresh one if it is not in the history.
  static void backTo(BuildContext context, String name, Widget Function() build) {
    var found = false;
    Navigator.popUntil(context, (r) {
      if (r.settings.name == name) found = true;
      return found || r.isFirst;
    });
    if (!found) Navigator.push(context, _route(name, build()));
  }
}
