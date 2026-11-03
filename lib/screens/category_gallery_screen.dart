import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../theme/app_colors.dart';
import '../widgets/gallery_cards.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/screen_header.dart';
import 'routes.dart';

class CategoryGalleryScreen extends StatelessWidget {
  const CategoryGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 1000 ? 5 : (width > 700 ? 3 : 2);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Pick a Picture',
              trailing: RoundIconButton(
                icon: Icons.photo_library_rounded,
                tooltip: 'My Artwork',
                onTap: () => AppRoutes.myArtworkPage(context),
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                crossAxisCount: columns,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
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
    );
  }
}
