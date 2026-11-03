import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../services/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/artwork_view.dart';
import '../widgets/gallery_cards.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/mascot.dart';
import 'routes.dart';

/// The picture hub behind the title screen's Play button: Start Coloring,
/// My Artwork, pictures in progress and every category.
class PictureHubScreen extends StatelessWidget {
  const PictureHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBFE6FF), AppColors.cream],
            stops: [0, 0.55],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: Listenable.merge([services.artworks, services.settings]),
            builder: (context, _) {
              final inProgress = services.artworks.all.take(8).toList();
              final width = MediaQuery.sizeOf(context).width;
              final columns = width > 1000 ? 5 : (width > 700 ? 4 : 2);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Header(animate: !services.settings.reducedMotion)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: [
                          BigPillButton(
                            icon: Icons.palette_rounded,
                            label: 'Start Coloring',
                            height: 76,
                            onTap: () => AppRoutes.categoriesPage(context),
                          ),
                          BigPillButton(
                            icon: Icons.photo_library_rounded,
                            label: 'My Artwork',
                            color: AppColors.lavenderDeep,
                            height: 64,
                            onTap: () => AppRoutes.myArtworkPage(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (inProgress.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: _SectionTitle(Icons.play_circle_rounded, 'Continue Coloring'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: inProgress.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, i) {
                            final a = inProgress[i];
                            final info = ColoringCatalog.template(a.templateId);
                            if (info == null) return const SizedBox.shrink();
                            return Semantics(
                              button: true,
                              label: 'Continue ${info.title}',
                              excludeSemantics: true,
                              child: Squishy(
                                onTap: () => AppRoutes.studioPage(context, a.templateId, artworkId: a.id),
                                child: Container(
                                  width: 130,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ArtworkView(templateId: a.templateId, artwork: a),
                                      ),
                                      Text(info.title, style: AppTextStyles.label),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: _SectionTitle(Icons.auto_awesome_rounded, 'Pick a Picture'),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverGrid.count(
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: RoundIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: () => Navigator.maybePop(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Mascot(size: 88, animate: animate),
                const SizedBox(width: 12),
                const Flexible(child: AppLogo(size: 38)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.coralDeep, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(fontSize: 24),
              semanticsLabel: text,
            ),
          ),
        ],
      ),
    );
  }
}
