import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../models/coloring_artwork.dart';
import '../services/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/artwork_view.dart';
import '../widgets/gallery_cards.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/playful_backdrop.dart';
import 'routes.dart';

/// Pick-a-picture hub: outdoor studio backdrop, Continue strip, category grid.
class PictureHubScreen extends StatelessWidget {
  const PictureHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([services.artworks, services.settings]),
        builder: (context, _) {
          final animate = !services.settings.reducedMotion;
          final inProgress = services.artworks.all
              .where((a) => ColoringCatalog.template(a.templateId) != null)
              .take(8)
              .toList();
          final width = MediaQuery.sizeOf(context).width;
          final columns = width > 1000 ? 5 : (width > 700 ? 4 : 2);
          return PlayfulBackdrop(
            animate: animate,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HubHeader(
                    onBack: () => Navigator.maybePop(context),
                    onArtwork: () => AppRoutes.myArtworkPage(context),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        if (inProgress.isNotEmpty) ...[
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                              child: Center(child: _ContinueChip()),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 168,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: inProgress.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 14),
                                itemBuilder: (context, i) => _ContinueCard(
                                  artwork: inProgress[i],
                                  featured: i == 0,
                                  animate: animate,
                                  onTap: () => AppRoutes.studioPage(
                                    context,
                                    inProgress[i].templateId,
                                    artworkId: inProgress[i].id,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 18)),
                        ] else
                          const SliverToBoxAdapter(child: SizedBox(height: 8)),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                          sliver: SliverGrid.count(
                            crossAxisCount: columns,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.86,
                            children: [
                              for (final c in ColoringCatalog.categories)
                                CategoryCard(
                                  category: c,
                                  onTap: () => AppRoutes.sketchesPage(context, c.id),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({required this.onBack, required this.onArtwork});

  final VoidCallback onBack;
  final VoidCallback onArtwork;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                onTap: onBack,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: RoundIconButton(
                icon: Icons.photo_library_rounded,
                tooltip: 'My Artwork',
                onTap: onArtwork,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White pill with a coral play mark — matches the mock section label.
class _ContinueChip extends StatelessWidget {
  const _ContinueChip();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Continue Coloring',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(color: AppColors.coralDeep, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Continue Coloring',
              style: AppTextStyles.heading.copyWith(fontSize: 20, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.artwork,
    required this.onTap,
    required this.featured,
    required this.animate,
  });

  final ColoringArtwork artwork;
  final VoidCallback onTap;
  final bool featured;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final info = ColoringCatalog.template(artwork.templateId)!;
    return Semantics(
      button: true,
      label: 'Continue ${info.title}',
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 148,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: featured ? 16 : 10,
                    offset: Offset(0, featured ? 7 : 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(child: ArtworkView(templateId: artwork.templateId, artwork: artwork)),
                  const SizedBox(height: 4),
                  Text(
                    info.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
            if (featured)
              Positioned(
                right: -2,
                top: -6,
                child: IgnorePointer(child: _Sparkles(animate: animate)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Sparkles extends StatefulWidget {
  const _Sparkles({required this.animate});

  final bool animate;

  @override
  State<_Sparkles> createState() => _SparklesState();
}

class _SparklesState extends State<_Sparkles> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_Sparkles old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.animate) _c.value = 0.6;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        size: const Size(34, 34),
        painter: _SparklePainter(widget.animate ? _c.value : 0.7),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC94D).withValues(alpha: 0.55 + 0.45 * t)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final origin = Offset(size.width * 0.35, size.height * 0.55);
    final len = 7.0 + 3.0 * t;
    for (final angle in const [-0.55, -1.15, -1.75]) {
      final d = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(origin + d * 4, origin + d * len, paint);
    }
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.22),
      2.2 + t,
      Paint()..color = const Color(0xFFFFC94D),
    );
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.t != t;
}
