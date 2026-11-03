import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../services/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/gallery_cards.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/playful_backdrop.dart';
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
        builder: (context, _) => PlayfulBackdrop(
          animate: !services.settings.reducedMotion,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
                  child: SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Pick a Picture',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 28,
                            color: AppColors.ink,
                            shadows: const [
                              Shadow(color: Colors.white, offset: Offset(0, 2), blurRadius: 0),
                              Shadow(color: Colors.white, offset: Offset(0, -1), blurRadius: 0),
                              Shadow(color: Colors.white, offset: Offset(1.5, 0), blurRadius: 0),
                              Shadow(color: Colors.white, offset: Offset(-1.5, 0), blurRadius: 0),
                            ],
                          ),
                          semanticsLabel: 'Pick a Picture',
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RoundIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Back',
                            onTap: () => Navigator.maybePop(context),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: RoundIconButton(
                            icon: Icons.photo_library_rounded,
                            tooltip: 'My Artwork',
                            onTap: () => AppRoutes.myArtworkPage(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.86,
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
