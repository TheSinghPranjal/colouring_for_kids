import 'package:flutter/material.dart';

import '../services/app_scope.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/mascot.dart';
import '../widgets/playful_backdrop.dart';
import 'routes.dart';

/// Sprout bounces in, the logo letters pop up one by one, then the title
/// screen fades in. A tap anywhere skips ahead.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const duration = Duration(milliseconds: 2800);
  static const reducedMotionDuration = Duration(milliseconds: 1200);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  late bool _reducedMotion;
  late AppServices _services;
  bool _landed = false;
  bool _done = false;

  Animation<double> _phase(double begin, double end, [Curve curve = Curves.linear]) =>
      CurvedAnimation(parent: _c, curve: Interval(begin, end, curve: curve));

  late final _drop = _phase(0, 0.32, Curves.bounceOut);
  late final _letters = _phase(0.18, 0.7);
  late final _tagline = _phase(0.55, 0.72, Curves.easeOut);
  late final _dots = _phase(0.6, 1);

  @override
  void initState() {
    super.initState();
    _c.addListener(_onTick);
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppScope.of(context);
    if (_c.duration != null) return;
    _reducedMotion = _services.settings.reducedMotion;
    _c.duration = _reducedMotion ? SplashScreen.reducedMotionDuration : SplashScreen.duration;
    _c.forward();
  }

  void _onTick() {
    if (_landed || _reducedMotion || _c.value < 0.3) return;
    _landed = true;
    _services.sound
      ..play(Sfx.pop)
      ..say('Color Sprout!');
  }

  void _finish() {
    if (_done || !mounted) return;
    _done = true;
    AppRoutes.replaceWithHome(context);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mascotSize = (size.shortestSide * 0.42).clamp(120.0, 220.0);
    final still = _reducedMotion;
    return Scaffold(
      body: Semantics(
        label: 'Color Sprout is starting. Tap to skip.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finish,
          child: PlayfulBackdrop(
            animate: !still,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _drop,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, still ? 0 : -size.height * 0.6 * (1 - _drop.value)),
                          child: child,
                        ),
                        child: Mascot(size: mascotSize, animate: !still),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: AppLogo(size: 64, centered: true, reveal: still ? null : _letters),
                      ),
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: still ? const AlwaysStoppedAnimation(1) : _tagline,
                        child: SlideTransition(
                          position: still
                              ? const AlwaysStoppedAnimation(Offset.zero)
                              : Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(_tagline),
                          child: Text(
                            "Let's color together!",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading.copyWith(color: AppColors.inkSoft),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _PaintDots(progress: _dots, animate: !still),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of paint drops that hop one after another while the app gets ready.
class _PaintDots extends StatelessWidget {
  const _PaintDots({required this.progress, required this.animate});

  final Animation<double> progress;
  final bool animate;

  static const _colors = [
    AppColors.coral,
    Color(0xFFF5B800),
    AppColors.mintDeep,
    AppColors.skyDeep,
    AppColors.lavenderDeep,
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: progress,
        builder: (_, _) {
          final v = progress.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _colors.length; i++)
                Builder(
                  builder: (_) {
                    // Each dot pops in, then hops twice in a wave.
                    final appear = animate ? ((v * 2.5 - i * 0.2).clamp(0.0, 1.0)) : 1.0;
                    final wave = animate ? ((v * 3 - i * 0.18) % 1) : 0.0;
                    final hop = animate && v > 0 ? -10 * (1 - (2 * wave - 1).abs()) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Transform.translate(
                        offset: Offset(0, hop * appear),
                        child: Transform.scale(
                          scale: Curves.easeOutBack.transform(appear),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _colors[i],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
