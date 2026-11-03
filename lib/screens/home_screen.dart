import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../services/app_scope.dart';
import '../theme/app_text_styles.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/studio_background.dart';
import 'routes.dart';

/// Title screen: studio background (logo baked into the art), Grown-ups chip,
/// and three glossy menu pills over the open floor.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Hot pink Play button from the reference mock.
  static const _playPink = Color(0xFFFF4D9A);

  /// Bright green Keep Coloring button.
  static const _keepGreen = Color(0xFF3DCF6A);

  /// Violet My Artwork / Grown-ups.
  static const _violet = Color(0xFF8B6BE8);

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
          return Stack(
            fit: StackFit.expand,
            children: [
              // Full-bleed studio art (character, easel, and Color Sprout title).
              const Positioned.fill(
                child: StudioBackgroundImage(semanticsLabel: 'Color Sprout'),
              ),
              SafeArea(
                child: Stack(
                  children: [
                    // Menu pills sit in the open floor area.
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: StudioBackground.overlayPadding,
                        child: _MenuButtons(
                          animate: animate,
                          onPlay: () => AppRoutes.hubPage(context),
                          onContinue: latest == null
                              ? null
                              : () => AppRoutes.studioPage(
                                    context,
                                    latest.templateId,
                                    artworkId: latest.id,
                                  ),
                          continueLabel: latest == null
                              ? null
                              : 'Keep Coloring ${ColoringCatalog.template(latest.templateId)!.title}',
                          onMyArtwork: () => AppRoutes.myArtworkPage(context),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, StudioBackground.overlayHorizontal, 0),
                        child: _GrownUpsChip(onTap: () => AppRoutes.parentPage(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GrownUpsChip extends StatelessWidget {
  const _GrownUpsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Grown-ups settings',
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: HomeScreen._violet,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: HomeScreen._violet.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                'Grown-ups',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
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
      constraints: const BoxConstraints(maxWidth: StudioBackground.menuMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Pulse(
            animate: animate,
            child: _SparkleAccent(
              animate: animate,
              child: _GlossyPillButton(
                icon: Icons.play_arrow_rounded,
                label: 'Play',
                color: HomeScreen._playPink,
                height: 78,
                onTap: onPlay,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (onContinue != null) ...[
            Semantics(
              label: continueLabel,
              button: true,
              excludeSemantics: true,
              child: _GlossyPillButton(
                icon: Icons.brush_rounded,
                label: 'Keep Coloring',
                color: HomeScreen._keepGreen,
                height: 58,
                onTap: onContinue,
              ),
            ),
            const SizedBox(height: 14),
          ],
          _GlossyPillButton(
            icon: Icons.image_rounded,
            label: 'My Artwork',
            color: HomeScreen._violet,
            height: 58,
            onTap: onMyArtwork,
          ),
        ],
      ),
    );
  }
}

/// Glossy 3D pill matching the mock: top highlight, soft shadow, rounded type.
class _GlossyPillButton extends StatelessWidget {
  const _GlossyPillButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.height,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(color, Colors.white, 0.22)!,
                color,
                Color.lerp(color, Colors.black, 0.08)!,
              ],
              stops: const [0, 0.55, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Soft white rim for plastic depth.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
              // Top sheen strip.
              Positioned(
                left: height * 0.22,
                right: height * 0.22,
                top: 5,
                height: height * 0.22,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: height * 0.48),
                    SizedBox(width: height * 0.14),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: height * 0.36,
                        letterSpacing: 0.2,
                        shadows: const [
                          Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Little sparkle ticks radiating off the Play button, as in the mock.
class _SparkleAccent extends StatelessWidget {
  const _SparkleAccent({required this.animate, required this.child});

  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -2,
          top: -6,
          child: IgnorePointer(
            child: _Sparkles(animate: animate),
          ),
        ),
      ],
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
    duration: const Duration(milliseconds: 1400),
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
    if (!widget.animate) _c.value = 0.5;
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
      builder: (context, _) {
        final t = widget.animate ? _c.value : 0.7;
        return CustomPaint(
          size: const Size(36, 36),
          painter: _SparklePainter(t),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 + 0.45 * t)
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
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.t != t;
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
