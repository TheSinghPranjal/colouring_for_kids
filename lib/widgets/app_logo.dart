import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// "Color Sprout" in playful multi-coloured letters.
///
/// Pass [reveal] (0 → 1) to make the letters pop in one after another, as
/// the splash screen does.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 44, this.centered = false, this.reveal});

  final double size;
  final bool centered;
  final Animation<double>? reveal;

  static const colors = [
    Color(0xFFF2584A),
    Color(0xFFFB8C00),
    Color(0xFFF5B800),
    Color(0xFF2FB58A),
    Color(0xFF3FA9F5),
    Color(0xFF7C64E8),
  ];

  static const _words = ['Color', 'Sprout'];
  static final _letterCount = _words.join().length;

  @override
  Widget build(BuildContext context) {
    final logo = reveal == null
        ? _letters(1)
        : AnimatedBuilder(animation: reveal!, builder: (_, _) => _letters(reveal!.value));
    return Semantics(
      header: true,
      label: 'Color Sprout',
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: logo,
      ),
    );
  }

  Widget _letters(double progress) {
    var i = 0;
    Widget word(String w) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final ch in w.split(''))
          _letter(ch, colors[i % colors.length], _letterScale(progress, i++)),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [for (final w in _words) word(w)],
    );
  }

  /// Each letter springs in during its own slice of [progress].
  static double _letterScale(double progress, int index) {
    if (progress >= 1) return 1;
    const span = 0.45;
    final start = index / _letterCount * (1 - span);
    final local = ((progress - start) / span).clamp(0.0, 1.0);
    return Curves.elasticOut.transform(local);
  }

  Widget _letter(String ch, Color color, double scale) {
    final text = Text(
      ch,
      style: AppTextStyles.display.copyWith(
        fontSize: size,
        color: color,
        shadows: const [Shadow(color: Colors.white, offset: Offset(0, 3))],
      ),
    );
    if (scale >= 1) return text;
    return Opacity(
      opacity: scale.clamp(0.0, 1.0),
      child: Transform.scale(scale: math.max(scale, 0.0), child: text),
    );
  }
}
