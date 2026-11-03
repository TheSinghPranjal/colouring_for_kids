import 'package:flutter/material.dart';

/// Shared home / splash studio artwork and overlay spacing.
class StudioBackground {
  StudioBackground._();

  static const assetPath = 'assets/images/home_studio_bg.jpg';
  static const imageAlignment = Alignment(0, -0.15);

  /// Horizontal inset for bottom controls (buttons, loader).
  static const overlayHorizontal = 28.0;
  static const overlayBottom = 28.0;

  static const overlayPadding = EdgeInsets.fromLTRB(
    overlayHorizontal,
    0,
    overlayHorizontal,
    overlayBottom,
  );

  static const menuMaxWidth = 340.0;
}

/// Full-bleed studio illustration used on splash and title screens.
class StudioBackgroundImage extends StatelessWidget {
  const StudioBackgroundImage({super.key, this.semanticsLabel});

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      StudioBackground.assetPath,
      fit: BoxFit.cover,
      alignment: StudioBackground.imageAlignment,
      filterQuality: FilterQuality.high,
    );
    if (semanticsLabel == null) return image;
    return Semantics(
      header: true,
      label: semanticsLabel,
      image: true,
      child: image,
    );
  }
}
