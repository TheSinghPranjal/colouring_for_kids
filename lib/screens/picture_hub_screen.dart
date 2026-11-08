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
import '../widgets/mascot.dart';
import '../widgets/meadow_backdrop.dart';
import '../widgets/pick_header.dart';
import 'routes.dart';

/// Pick-a-picture hub: a sunny garden, a big Continue Coloring button with
/// the latest picture and Sprout holding a crayon, then every category.
class PictureHubScreen extends StatelessWidget {
  const PictureHubScreen({super.key});

  static const _headerHeight = 88.0;
  static const _continueHeight = 84.0;

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
          final media = MediaQuery.of(context);
          final width = media.size.width;
          final columns = width > 1000 ? 5 : (width > 700 ? 4 : 2);
          final featuredWidth = math.min(width * 0.46, 250.0);
          final featuredHeight = featuredWidth / 0.86;
          // Put the meadow's horizon just behind the featured card's feet.
          final horizonPx = inProgress.isEmpty
              ? media.padding.top + _headerHeight + 60
              : media.padding.top + _headerHeight + _continueHeight + featuredHeight * 0.72;
          void open(ColoringArtwork a) => AppRoutes.studioPage(context, a.templateId, artworkId: a.id);

          return MeadowBackdrop(
            animate: animate,
            horizon: (horizonPx / media.size.height).clamp(0.2, 0.6),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PickHeader(
                    onBack: () => Navigator.maybePop(context),
                    onArtwork: () => AppRoutes.myArtworkPage(context),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        if (inProgress.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: _continueHeight,
                              child: Center(child: _ContinueButton(onTap: () => open(inProgress.first))),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: SizedBox(
                                  width: math.min(width - 40, 560),
                                  height: featuredHeight,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        width: featuredWidth,
                                        child: _FeaturedCard(
                                          artwork: inProgress.first,
                                          onTap: () => open(inProgress.first),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: const Alignment(0.1, 0.7),
                                          child: _CrayonMascot(size: featuredHeight * 0.8, animate: animate),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (inProgress.length > 1)
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 128,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                                  itemCount: inProgress.length - 1,
                                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                                  itemBuilder: (context, i) =>
                                      _MiniCard(artwork: inProgress[i + 1], onTap: () => open(inProgress[i + 1])),
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 22)),
                        ] else
                          const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          sliver: SliverGrid.count(
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Raspberry pill that jumps back into the most recent picture.
class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue Coloring',
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Container(
          height: 64,
          padding: const EdgeInsets.fromLTRB(8, 0, 28, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 4),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.berryLight, AppColors.berry],
            ),
            boxShadow: [
              BoxShadow(color: AppColors.berry.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC2105F),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2.5),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Continue Coloring',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 24,
                    color: Colors.white,
                    shadows: const [Shadow(color: Color(0x55800040), offset: Offset(0, 2), blurRadius: 2)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The latest picture in a golden frame with a star ribbon.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.artwork, required this.onTap});

  final ColoringArtwork artwork;
  final VoidCallback onTap;

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
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.goldLight, AppColors.gold, Color(0xFFFFD54F)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD83D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ArtworkView(templateId: artwork.templateId, artwork: artwork),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          info.title,
                          maxLines: 1,
                          style: AppTextStyles.title.copyWith(fontSize: 22, color: AppColors.grape),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(top: -10, right: -10, child: _StarBadge()),
          ],
        ),
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  const _StarBadge();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.12,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 3),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB74D), Color(0xFFFF8F00)],
          ),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: const Icon(Icons.star_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

/// A smaller card for the other pictures in progress.
class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.artwork, required this.onTap});

  final ColoringArtwork artwork;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = ColoringCatalog.template(artwork.templateId)!;
    return Semantics(
      button: true,
      label: 'Continue ${info.title}',
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: AppColors.grape.withValues(alpha: 0.16), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ArtworkView(templateId: artwork.templateId, artwork: artwork),
              ),
              Text(
                info.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.grape),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sprout peeking up from the meadow with a big purple crayon.
class _CrayonMascot extends StatelessWidget {
  const _CrayonMascot({required this.size, required this.animate});

  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size * 1.05,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: Mascot(size: size, animate: animate),
            ),
            // Held against Sprout's left side, tip up and outwards.
            Positioned(
              left: size * 0.12,
              bottom: size * 0.04,
              child: Transform.rotate(
                angle: -0.4,
                child: CustomPaint(size: Size(size * 0.17, size * 0.55), painter: _CrayonPainter()),
              ),
            ),
            Positioned(
              left: -size * 0.04,
              top: size * 0.2,
              child: CustomPaint(size: Size.square(size * 0.26), painter: _BurstPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrayonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const body = Color(0xFF9C3FE0), dark = Color(0xFF6E22B0), light = Color(0xFFC07CF5);
    final outline = Paint()
      ..color = const Color(0xFF2B2440)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeJoin = StrokeJoin.round;
    final tipH = h * 0.2;
    final tip = Path()
      ..moveTo(w * 0.12, tipH)
      ..lineTo(w * 0.42, h * 0.02)
      ..quadraticBezierTo(w * 0.5, 0, w * 0.58, h * 0.02)
      ..lineTo(w * 0.88, tipH)
      ..close();
    canvas.drawPath(tip, Paint()..color = dark);
    canvas.drawPath(tip, outline);
    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, tipH, w, h - tipH),
      bottomLeft: Radius.circular(w * 0.2),
      bottomRight: Radius.circular(w * 0.2),
    );
    canvas.drawRRect(rect, Paint()..color = body);
    canvas.drawRect(Rect.fromLTWH(w * 0.12, tipH + 2, w * 0.18, h - tipH - 6), Paint()..color = light);
    for (final y in [tipH + h * 0.08, h - h * 0.14]) {
      canvas.drawRect(Rect.fromLTWH(0, y, w, h * 0.05), Paint()..color = dark);
    }
    canvas.drawRRect(rect, outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC21A)
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;
    final o = Offset(size.width * 0.85, size.height * 0.95);
    for (final a in const [-2.0, -1.5, -2.6]) {
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(o + d * size.width * 0.45, o + d * size.width * 0.85, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
