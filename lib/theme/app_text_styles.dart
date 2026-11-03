import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Baloo 2 is bundled as a variable font, so weight is set via its axis.
class AppTextStyles {
  AppTextStyles._();

  static const family = 'Baloo2';

  static TextStyle _w(double size, double weight, {Color color = AppColors.ink, double height = 1.1}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        height: height,
        color: color,
        fontWeight: weight >= 700 ? FontWeight.w700 : FontWeight.w500,
        fontVariations: [FontVariation('wght', weight)],
      );

  static final display = _w(40, 800);
  static final title = _w(28, 800);
  static final heading = _w(22, 700);
  static final button = _w(20, 700);
  static final label = _w(16, 600);
  static final body = _w(17, 500, height: 1.3);
  static final caption = _w(14, 600, color: AppColors.inkSoft);
}
