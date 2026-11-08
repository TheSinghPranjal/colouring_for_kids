import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../services/app_scope.dart';
import '../widgets/gallery_cards.dart';
import '../widgets/meadow_backdrop.dart';
import '../widgets/pick_header.dart';
import 'routes.dart';

/// Standalone category grid (e.g. from My Artwork → Start Coloring).
/// Matches the Pick a Picture hub look.
class CategoryGalleryScreen extends StatelessWidget {
  const CategoryGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 1000 ? 5 : (width > 700 ? 3 : 2);
    return Scaffold(
      body: ListenableBuilder(
        listenable: services.settings,
        builder: (context, _) => MeadowBackdrop(
          animate: !services.settings.reducedMotion,
          horizon: 0.3,
          child: SafeArea(
            child: Column(
              children: [
                PickHeader(
                  onBack: () => Navigator.maybePop(context),
                  onArtwork: () => AppRoutes.myArtworkPage(context),
                ),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    crossAxisCount: columns,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.88,
                    children: [
                      for (final c in ColoringCatalog.categories)
                        CategoryCard(category: c, onTap: () => AppRoutes.sketchesPage(context, c.id)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
