import 'package:flutter/painting.dart';

/// A named colour offered to the child.
class PaletteColor {
  const PaletteColor(this.id, this.name, this.color);

  final String id;
  final String name;
  final Color color;

  /// Light colours need a visible border against white backgrounds.
  bool get isLight => color.computeLuminance() > 0.6;
}

/// The 16 colours always visible in the studio palette.
const List<PaletteColor> kBasicPalette = [
  PaletteColor('red', 'Red', Color(0xFFE53935)),
  PaletteColor('orange', 'Orange', Color(0xFFFB8C00)),
  PaletteColor('yellow', 'Yellow', Color(0xFFFDD835)),
  PaletteColor('green', 'Green', Color(0xFF43A047)),
  PaletteColor('light_green', 'Light green', Color(0xFF9CCC65)),
  PaletteColor('blue', 'Blue', Color(0xFF1E88E5)),
  PaletteColor('sky_blue', 'Sky blue', Color(0xFF4FC3F7)),
  PaletteColor('purple', 'Purple', Color(0xFF8E24AA)),
  PaletteColor('pink', 'Pink', Color(0xFFF48FB1)),
  PaletteColor('brown', 'Brown', Color(0xFF8D6E63)),
  PaletteColor('black', 'Black', Color(0xFF212121)),
  PaletteColor('white', 'White', Color(0xFFFFFFFF)),
  PaletteColor('grey', 'Grey', Color(0xFF9E9E9E)),
  PaletteColor('peach', 'Peach', Color(0xFFFFCCBC)),
  PaletteColor('teal', 'Teal', Color(0xFF26A69A)),
  PaletteColor('dark_blue', 'Dark blue', Color(0xFF283593)),
];

/// Optional extra colours shown in the separate "More colours" panel.
const List<PaletteColor> kExtendedPalette = [
  PaletteColor('lavender', 'Lavender', Color(0xFFCE93D8)),
  PaletteColor('mint', 'Mint', Color(0xFFA5D6A7)),
  PaletteColor('lemon', 'Lemon', Color(0xFFFFF59D)),
  PaletteColor('coral', 'Coral', Color(0xFFFF8A65)),
  PaletteColor('magenta', 'Magenta', Color(0xFFD81B60)),
  PaletteColor('gold', 'Gold', Color(0xFFFFB300)),
  PaletteColor('olive', 'Olive', Color(0xFF827717)),
  PaletteColor('maroon', 'Maroon', Color(0xFF8E2424)),
  PaletteColor('cream', 'Cream', Color(0xFFFFF8E1)),
  PaletteColor('baby_blue', 'Baby blue', Color(0xFFBBDEFB)),
  PaletteColor('rose', 'Rose', Color(0xFFF8BBD0)),
  PaletteColor('sand', 'Sand', Color(0xFFD7B98E)),
  PaletteColor('forest', 'Forest', Color(0xFF1B5E20)),
  PaletteColor('indigo', 'Indigo', Color(0xFF5C6BC0)),
  PaletteColor('lilac', 'Lilac', Color(0xFFB39DDB)),
  PaletteColor('charcoal', 'Charcoal', Color(0xFF546E7A)),
];

PaletteColor? paletteColorFor(Color color) {
  for (final c in [...kBasicPalette, ...kExtendedPalette]) {
    if (c.color.toARGB32() == color.toARGB32()) return c;
  }
  return null;
}
