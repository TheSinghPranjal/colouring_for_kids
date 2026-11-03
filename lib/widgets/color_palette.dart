import 'package:flutter/material.dart';

import '../engines/region_coloring/coloring_canvas.dart';
import '../models/palette_color.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'kid_buttons.dart';

/// The studio palette: big round swatches that can be tapped to select or
/// dragged straight onto a section of the picture.
class ColorPalette extends StatefulWidget {
  const ColorPalette({
    super.key,
    required this.selected,
    required this.onSelected,
    this.extraColor,
    this.swatchSize = 48,
    this.axis = Axis.horizontal,
    this.onMoreColors,
    this.onDragStarted,
  });

  final Color selected;
  final ValueChanged<PaletteColor> onSelected;

  /// A colour chosen from "More colours", shown first so it can be dragged.
  final PaletteColor? extraColor;
  final double swatchSize;

  /// Horizontal: one scrolling row (phones). Vertical: a wrapping grid in a
  /// side panel (tablets / landscape).
  final Axis axis;
  final VoidCallback? onMoreColors;
  final ValueChanged<PaletteColor>? onDragStarted;

  @override
  State<ColorPalette> createState() => ColorPaletteState();
}

class ColorPaletteState extends State<ColorPalette> {
  final Map<int, GlobalKey> _keys = {};

  GlobalKey _keyFor(Color c) => _keys.putIfAbsent(c.toARGB32(), GlobalKey.new);

  List<PaletteColor> get _colors => [?widget.extraColor, ...kBasicPalette];

  /// Global centre of the swatch for [color], if it is on screen.
  Offset? swatchCenter(Color color) {
    final box = _keys[color.toARGB32()]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  /// Glides a swatch from [fromGlobal] back to its place in the palette, used
  /// when a drop missed every fillable region.
  void animateReturn(Offset fromGlobal, Color color) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final key = _keys[color.toARGB32()];
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final selfBox = context.findRenderObject() as RenderBox?;
    final target = box != null && box.attached
        ? box.localToGlobal(box.size.center(Offset.zero))
        : selfBox?.localToGlobal(selfBox.size.center(Offset.zero));
    if (target == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ReturningSwatch(
        from: fromGlobal,
        to: target,
        color: color,
        size: widget.swatchSize * 1.25,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      for (final c in _colors)
        _Swatch(
          key: _keyFor(c.color),
          color: c,
          size: widget.swatchSize,
          selected: c.color.toARGB32() == widget.selected.toARGB32(),
          dragAxis: widget.axis == Axis.horizontal ? Axis.vertical : Axis.horizontal,
          onTap: () => widget.onSelected(c),
          onDragStarted: () {
            widget.onSelected(c);
            widget.onDragStarted?.call(c);
          },
          onCancelled: (offset) => animateReturn(offset, c.color),
        ),
      if (widget.onMoreColors != null)
        _MoreColorsButton(size: widget.swatchSize, onTap: widget.onMoreColors!),
    ];
    final gap = widget.swatchSize * 0.28;
    if (widget.axis == Axis.horizontal) {
      return SizedBox(
        height: widget.swatchSize * 1.5,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: gap * 1.5),
          itemCount: children.length,
          separatorBuilder: (_, _) => SizedBox(width: gap),
          itemBuilder: (_, i) => Center(child: children[i]),
        ),
      );
    }
    return Wrap(spacing: gap, runSpacing: gap, alignment: WrapAlignment.center, children: children);
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    super.key,
    required this.color,
    required this.size,
    required this.selected,
    required this.dragAxis,
    required this.onTap,
    required this.onDragStarted,
    required this.onCancelled,
  });

  final PaletteColor color;
  final double size;
  final bool selected;
  final Axis dragAxis;
  final VoidCallback onTap;
  final VoidCallback onDragStarted;
  final ValueChanged<Offset> onCancelled;

  @override
  Widget build(BuildContext context) {
    final dot = SwatchDot(color: color.color, size: size, selected: selected);
    return Semantics(
      button: true,
      selected: selected,
      label: color.name,
      excludeSemantics: true,
      child: Draggable<SwatchDragData>(
        data: SwatchDragData(color.color),
        affinity: dragAxis,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Transform.translate(
          offset: Offset(-size * 0.65, -size * 0.65),
          child: SwatchDot(color: color.color, size: size * 1.3, floating: true),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: dot),
        onDragStarted: onDragStarted,
        onDraggableCanceled: (_, offset) => onCancelled(offset),
        child: GestureDetector(onTap: onTap, child: dot),
      ),
    );
  }
}

/// A round paint swatch. Selection is shown with a ring, a slight enlarge
/// and a tick, never by colour alone.
class SwatchDot extends StatelessWidget {
  const SwatchDot({
    super.key,
    required this.color,
    required this.size,
    this.selected = false,
    this.floating = false,
  });

  final Color color;
  final double size;
  final bool selected;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final light = color.computeLuminance() > 0.6;
    return AnimatedScale(
      scale: selected ? 1.14 : 1,
      duration: const Duration(milliseconds: 140),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selected ? Border.all(color: AppColors.ink, width: 3.5) : null,
          boxShadow: [
            BoxShadow(
              color: floating ? Colors.black38 : AppColors.shadow,
              blurRadius: floating ? 16 : 6,
              offset: Offset(0, floating ? 8 : 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(selected ? 3 : 0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: light ? const Color(0xFFB9B3C9) : Colors.black12, width: light ? 2 : 1),
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 0.9,
              colors: [Color.lerp(color, Colors.white, 0.3)!, color],
            ),
          ),
          child: selected
              ? Icon(Icons.check_rounded, size: size * 0.5, color: light ? AppColors.ink : Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _MoreColorsButton extends StatelessWidget {
  const _MoreColorsButton({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'More colors',
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Color(0xFFE53935),
                Color(0xFFFDD835),
                Color(0xFF43A047),
                Color(0xFF1E88E5),
                Color(0xFF8E24AA),
                Color(0xFFE53935),
              ],
            ),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Center(
            child: Container(
              width: size * 0.56,
              height: size * 0.56,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, size: size * 0.42, color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReturningSwatch extends StatelessWidget {
  const _ReturningSwatch({
    required this.from,
    required this.to,
    required this.color,
    required this.size,
    required this.onDone,
  });

  final Offset from;
  final Offset to;
  final Color color;
  final double size;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        onEnd: onDone,
        builder: (context, t, _) {
          final p = Offset.lerp(from, to, t)!;
          return Stack(
            children: [
              Positioned(
                left: p.dx - size / 2,
                top: p.dy - size / 2,
                child: Opacity(
                  opacity: 1 - t * 0.6,
                  child: SwatchDot(color: color, size: size * (1 - t * 0.25), floating: true),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bottom sheet with the optional extended colours.
Future<PaletteColor?> showMoreColors(BuildContext context, Color selected) {
  return showModalBottomSheet<PaletteColor>(
    context: context,
    backgroundColor: AppColors.cream,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('More colors', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                for (final c in kExtendedPalette)
                  Semantics(
                    button: true,
                    label: c.name,
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, c),
                      child: SwatchDot(color: c.color, size: 52, selected: c.color == selected),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
