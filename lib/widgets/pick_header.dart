import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'kid_buttons.dart';

/// "Pick a Picture" title bar: Back on the left, My Artwork on the right
/// and a chunky outlined title with a little burst of sun rays.
class PickHeader extends StatelessWidget {
  const PickHeader({super.key, required this.onBack, required this.onArtwork, this.title = 'Pick a Picture'});

  final VoidCallback onBack;
  final VoidCallback onArtwork;
  final String title;

  static List<Shadow> outline(Color color, double w) => [
    for (var i = 0; i < 12; i++)
      Shadow(color: color, offset: Offset(math.cos(i * math.pi / 6) * w, math.sin(i * math.pi / 6) * w)),
    Shadow(color: AppColors.grape.withValues(alpha: 0.35), offset: Offset(0, w + 2), blurRadius: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', size: 58, onTap: onBack),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Positioned(top: -2, child: ExcludeSemantics(child: _Rays())),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          title,
                          maxLines: 1,
                          style: AppTextStyles.display.copyWith(
                            fontSize: 36,
                            color: AppColors.grape,
                            shadows: outline(Colors.white, 3),
                          ),
                          semanticsLabel: title,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            RoundIconButton(
              icon: Icons.photo_library_rounded,
              tooltip: 'My Artwork',
              size: 58,
              iconColor: AppColors.grape,
              onTap: onArtwork,
            ),
          ],
        ),
      ),
    );
  }
}

class _Rays extends StatelessWidget {
  const _Rays();

  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size(40, 18), painter: _RaysPainter());
}

class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC21A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final base = Offset(size.width / 2, size.height + 6);
    for (final a in const [-2.2, -1.57, -0.94]) {
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(base + d * 12, base + d * 21, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
