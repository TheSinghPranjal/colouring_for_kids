import 'package:flutter/material.dart';

import '../services/app_scope.dart';
import '../services/sound_service.dart';
import '../widgets/studio_background.dart';
import 'routes.dart';

/// Studio background with a line loader, then a soft fade to the title screen.
/// A tap anywhere skips ahead.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const duration = Duration(milliseconds: 2200);
  static const reducedMotionDuration = Duration(milliseconds: 900);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  late bool _reducedMotion;
  late AppServices _services;
  bool _greeted = false;
  bool _done = false;

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
    if (_greeted || _reducedMotion || _c.value < 0.25) return;
    _greeted = true;
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
    return Scaffold(
      body: Semantics(
        label: 'Color Sprout is starting. Tap to skip.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finish,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const StudioBackgroundImage(),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: StudioBackground.overlayPadding,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: StudioBackground.menuMaxWidth),
                      child: _LineLoader(progress: _c),
                    ),
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

/// Soft track with a colorful fill that grows with splash progress.
class _LineLoader extends StatelessWidget {
  const _LineLoader({required this.progress});

  final Animation<double> progress;

  static const _track = Color(0x66FFFFFF);
  static const _fill = [
    Color(0xFFFF4D9A),
    Color(0xFFFFB84D),
    Color(0xFF3DCF6A),
    Color(0xFF3FA9F5),
    Color(0xFF8B6BE8),
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: progress,
        builder: (_, _) {
          final v = Curves.easeInOut.transform(progress.value.clamp(0.0, 1.0));
          return SizedBox(
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _track,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: v.clamp(0.04, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(colors: _fill),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
