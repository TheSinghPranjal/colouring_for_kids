import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../services/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/mascot.dart';
import '../widgets/playful_backdrop.dart';
import 'routes.dart';

/// The game's title screen: Sprout, the logo and a big bouncing Play
/// button, plus shortcuts to keep coloring or see saved artwork.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([services.artworks, services.settings]),
        builder: (context, _) {
          final animate = !services.settings.reducedMotion;
          final latest = services.artworks.all
              .where((a) => ColoringCatalog.template(a.templateId) != null)
              .firstOrNull;
          return PlayfulBackdrop(
            animate: animate,
            child: SafeArea(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, box) {
                      final wide = box.maxWidth > box.maxHeight * 1.15 && box.maxWidth > 600;
                      final mascotSize = (box.maxHeight * (wide ? 0.38 : 0.22)).clamp(90.0, 200.0);
                      final branding = _Branding(mascotSize: mascotSize, animate: animate);
                      final buttons = _MenuButtons(
                        animate: animate,
                        onPlay: () => AppRoutes.hubPage(context),
                        onContinue: latest == null
                            ? null
                            : () => AppRoutes.studioPage(context, latest.templateId, artworkId: latest.id),
                        continueLabel: latest == null
                            ? null
                            : 'Keep Coloring ${ColoringCatalog.template(latest.templateId)!.title}',
                        onMyArtwork: () => AppRoutes.myArtworkPage(context),
                      );
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: box.maxHeight - 80),
                          child: Center(
                            child: wide
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(child: branding),
                                      const SizedBox(width: 40),
                                      Flexible(child: buttons),
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [branding, const SizedBox(height: 28), buttons],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                      child: Semantics(
                        button: true,
                        label: 'Grown-ups settings',
                        excludeSemantics: true,
                        child: Opacity(
                          opacity: 0.75,
                          child: TextButton.icon(
                            onPressed: () => AppRoutes.parentPage(context),
                            icon: const Icon(Icons.lock_rounded, size: 18, color: AppColors.inkSoft),
                            label: Text('Grown-ups', style: AppTextStyles.caption),
                          ),
                        ),
                      ),
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

class _Branding extends StatelessWidget {
  const _Branding({required this.mascotSize, required this.animate});

  final double mascotSize;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Mascot(size: mascotSize, animate: animate),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: mascotSize * 2.6),
          child: AppLogo(size: (mascotSize * 0.42).clamp(48.0, 84.0), centered: true),
        ),
      ],
    );
  }
}

class _MenuButtons extends StatelessWidget {
  const _MenuButtons({
    required this.animate,
    required this.onPlay,
    required this.onContinue,
    required this.continueLabel,
    required this.onMyArtwork,
  });

  final bool animate;
  final VoidCallback onPlay;
  final VoidCallback? onContinue;
  final String? continueLabel;
  final VoidCallback onMyArtwork;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Pulse(
            animate: animate,
            child: BigPillButton(
              icon: Icons.play_arrow_rounded,
              label: 'Play',
              height: 92,
              expand: true,
              onTap: onPlay,
            ),
          ),
          const SizedBox(height: 18),
          if (onContinue != null) ...[
            Semantics(
              label: continueLabel,
              button: true,
              excludeSemantics: true,
              child: BigPillButton(
                icon: Icons.brush_rounded,
                label: 'Keep Coloring',
                color: AppColors.mintDeep,
                height: 62,
                expand: true,
                onTap: onContinue,
              ),
            ),
            const SizedBox(height: 14),
          ],
          BigPillButton(
            icon: Icons.photo_library_rounded,
            label: 'My Artwork',
            color: AppColors.lavenderDeep,
            height: 62,
            expand: true,
            onTap: onMyArtwork,
          ),
        ],
      ),
    );
  }
}

/// Gently breathes in and out to invite a tap.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.animate, required this.child});

  final bool animate;
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_Pulse old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.animate) _c.value = 0;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
