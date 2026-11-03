import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engines/free_draw/sticker_art.dart';
import '../engines/free_draw/stroke_renderer.dart';
import '../models/brush_stroke.dart';
import '../models/drawing_tool.dart';
import '../models/sticker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'kid_buttons.dart';

/// Fill / Draw / Stickers switch with big picture buttons.
class ModeSwitch extends StatelessWidget {
  const ModeSwitch({
    super.key,
    required this.mode,
    required this.onChanged,
    required this.color,
    this.showDraw = true,
    this.showStickers = true,
    this.compact = false,
  });

  final StudioMode mode;
  final ValueChanged<StudioMode> onChanged;
  final Color color;
  final bool showDraw;
  final bool showStickers;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = [
      (StudioMode.fill, Icons.format_color_fill_rounded, 'Fill'),
      if (showDraw) (StudioMode.draw, Icons.brush_rounded, 'Draw'),
      if (showStickers) (StudioMode.sticker, Icons.star_rounded, 'Stickers'),
    ];
    if (items.length == 1) return const SizedBox.shrink();
    final bar = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (m, icon, label) in items)
            Semantics(
              button: true,
              selected: m == mode,
              label: '$label mode',
              excludeSemantics: true,
              child: Squishy(
                onTap: () => onChanged(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: compact ? 44 : 50,
                  padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
                  decoration: BoxDecoration(
                    color: m == mode ? AppColors.butter : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: m == mode ? AppColors.ink : Colors.transparent, width: 2.5),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: m == StudioMode.fill ? color : AppColors.ink, size: 26),
                      const SizedBox(width: 6),
                      Text(label, style: AppTextStyles.label),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return FittedBox(fit: BoxFit.scaleDown, child: bar);
  }
}

/// Tool, size and preview row shown in Draw mode.
class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({
    super.key,
    required this.tools,
    required this.tool,
    required this.size,
    required this.color,
    required this.onTool,
    required this.onSize,
    required this.onClear,
    this.showSizes = true,
    this.canClear = true,
  });

  final List<DrawingTool> tools;
  final DrawingTool tool;
  final BrushSize size;
  final Color color;
  final ValueChanged<DrawingTool> onTool;
  final ValueChanged<BrushSize> onSize;
  final VoidCallback onClear;
  final bool showSizes;
  final bool canClear;

  @override
  Widget build(BuildContext context) {
    final toolButtons = [
      for (final t in tools) ...[
        ToolButton(tool: t, color: color, selected: t == tool, onTap: () => onTool(t)),
        const SizedBox(width: 8),
      ],
    ];
    final sizing = [
      SizePicker(size: size, onChanged: onSize),
      const SizedBox(width: 10),
      BrushPreview(tool: tool, size: size, color: color),
    ];
    final clear = RoundIconButton(
      icon: Icons.cleaning_services_rounded,
      tooltip: 'Clear drawing',
      caption: 'Clear',
      size: 46,
      onTap: canClear ? onClear : null,
    );
    return LayoutBuilder(
      builder: (context, box) {
        // Phones: tools on one row, size + preview on a second row, so all
        // controls stay visible without scrolling.
        if (showSizes && box.maxWidth < 620) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(children: [...toolButtons, clear]),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(children: sizing),
              ),
            ],
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ...toolButtons,
              if (showSizes) ...[const SizedBox(width: 6), ...sizing],
              const SizedBox(width: 10),
              clear,
            ],
          ),
        );
      },
    );
  }
}

class ToolButton extends StatelessWidget {
  const ToolButton({
    super.key,
    required this.tool,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final DrawingTool tool;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: tool.label,
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 56,
              transform: Matrix4.translationValues(0, selected ? -4 : 0, 0),
              decoration: BoxDecoration(
                color: selected ? AppColors.butter : AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppColors.ink : AppColors.shadow,
                  width: selected ? 3 : 1.5,
                ),
                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: CustomPaint(painter: ToolGlyphPainter(tool, color)),
            ),
            const SizedBox(height: 2),
            Text(tool.label, style: AppTextStyles.caption.copyWith(fontSize: 12, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

/// Simple illustrated icons for each tool, tipped with the current colour.
class ToolGlyphPainter extends CustomPainter {
  ToolGlyphPainter(this.tool, this.color);

  final DrawingTool tool;
  final Color color;

  static const ink = AppColors.ink;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    final s = size.width / 56;
    canvas.scale(s);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..color = ink;
    void shape(Path p, Color fill) {
      canvas.drawPath(p, Paint()..color = fill);
      canvas.drawPath(p, line);
    }

    switch (tool) {
      case DrawingTool.pencil:
        shape(Path()..addRect(const Rect.fromLTRB(-16, -5, 10, 5)), const Color(0xFFFFC94D));
        shape(Path()..addRect(const Rect.fromLTRB(-21, -5, -16, 5)), const Color(0xFFFF9EB5));
        shape(
          Path()
            ..moveTo(10, -5)
            ..lineTo(21, 0)
            ..lineTo(10, 5)
            ..close(),
          const Color(0xFFF5DEB3),
        );
        shape(
          Path()
            ..moveTo(17, -1.9)
            ..lineTo(21, 0)
            ..lineTo(17, 1.9)
            ..close(),
          color,
        );
      case DrawingTool.crayon:
        shape(RRectPath.of(const Rect.fromLTRB(-20, -6.5, 12, 6.5), 3), color);
        shape(Path()..addRect(const Rect.fromLTRB(-12, -6.5, 4, 6.5)), Colors.white);
        shape(
          Path()
            ..moveTo(12, -6.5)
            ..lineTo(21, -2.5)
            ..lineTo(21, 2.5)
            ..lineTo(12, 6.5)
            ..close(),
          color,
        );
      case DrawingTool.marker:
        shape(RRectPath.of(const Rect.fromLTRB(-21, -8, 6, 8), 5), const Color(0xFFECEFF1));
        shape(RRectPath.of(const Rect.fromLTRB(-21, -8, -8, 8), 4), color);
        shape(
          Path()
            ..moveTo(6, -6)
            ..lineTo(14, -4)
            ..lineTo(14, 4)
            ..lineTo(6, 6)
            ..close(),
          const Color(0xFF90A4AE),
        );
        shape(RRectPath.of(const Rect.fromLTRB(14, -3.5, 21, 3.5), 2.5), color);
      case DrawingTool.watercolor:
        shape(RRectPath.of(const Rect.fromLTRB(-22, -3, 2, 3), 3), const Color(0xFFB07A4F));
        shape(Path()..addRect(const Rect.fromLTRB(2, -4.5, 8, 4.5)), const Color(0xFFCFD8DC));
        shape(
          Path()
            ..moveTo(8, -5)
            ..quadraticBezierTo(18, -6, 23, 0)
            ..quadraticBezierTo(18, 6, 8, 5)
            ..close(),
          color.withValues(alpha: 0.75),
        );
      case DrawingTool.eraser:
        shape(RRectPath.of(const Rect.fromLTRB(-16, -9, 16, 9), 4), const Color(0xFFFF9EB5));
        shape(RRectPath.of(const Rect.fromLTRB(-16, -9, -4, 9), 4), const Color(0xFF81D4FA));
    }
  }

  @override
  bool shouldRepaint(ToolGlyphPainter old) => old.tool != tool || old.color != color;
}

class RRectPath {
  RRectPath._();

  static Path of(Rect r, double radius) =>
      Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(radius)));
}

class SizePicker extends StatelessWidget {
  const SizePicker({super.key, required this.size, required this.onChanged});

  final BrushSize size;
  final ValueChanged<BrushSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(26)),
      child: Row(
        children: [
          for (final s in BrushSize.values)
            Semantics(
              button: true,
              selected: s == size,
              label: '${s.label} brush',
              excludeSemantics: true,
              child: Squishy(
                onTap: () => onChanged(s),
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s == size ? AppColors.butter : Colors.transparent,
                    border: Border.all(color: s == size ? AppColors.ink : Colors.transparent, width: 2.5),
                  ),
                  child: Center(
                    child: Container(
                      width: [8.0, 15.0, 24.0][s.index],
                      height: [8.0, 15.0, 24.0][s.index],
                      decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A sample squiggle drawn with the real stroke renderer, so the preview
/// looks exactly like the mark the child is about to make.
class BrushPreview extends StatelessWidget {
  const BrushPreview({super.key, required this.tool, required this.size, required this.color});

  final DrawingTool tool;
  final BrushSize size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${tool.label}, ${size.label}',
      child: Container(
        width: 96,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.shadow, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(painter: _PreviewPainter(tool, size, color)),
        ),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.tool, this.size, this.color);

  final DrawingTool tool;
  final BrushSize size;
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    // Draw in a virtual 300 x 160 space with the true template-unit width,
    // scaled like a canvas roughly the size of a phone screen.
    canvas.scale(s.width / 300, s.height / 160);
    final pts = [for (var x = 30.0; x <= 270; x += 8) Offset(x, 80 + 34 * math.sin((x - 30) / 40))];
    if (tool.isEraser) {
      canvas.saveLayer(Offset.zero & const Size(300, 160), Paint());
      canvas.drawRect(const Rect.fromLTWH(0, 40, 300, 80), Paint()..color = const Color(0xFFB3E5FC));
    }
    StrokeRenderer.paint(
      canvas,
      BrushStroke(id: 0, tool: tool, color: color, width: tool.widthFor(size), seed: 7, points: pts),
    );
    if (tool.isEraser) canvas.restore();
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => old.tool != tool || old.size != size || old.color != color;
}

/// Sticker choices shown in Sticker mode.
class StickerTray extends StatelessWidget {
  const StickerTray({
    super.key,
    required this.kind,
    required this.onKind,
    required this.onClear,
    this.canClear = true,
  });

  final StickerKind kind;
  final ValueChanged<StickerKind> onKind;
  final VoidCallback onClear;
  final bool canClear;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final k in StickerKind.values) ...[
            _DraggableSticker(
              kind: k,
              selected: k == kind,
              onSelected: () => onKind(k),
            ),
            const SizedBox(width: 8),
          ],
          const SizedBox(width: 6),
          RoundIconButton(
            icon: Icons.cleaning_services_rounded,
            tooltip: 'Clear drawing',
            size: 46,
            onTap: canClear ? onClear : null,
          ),
        ],
      ),
    );
  }
}

/// Drag a sticker onto the picture (vertical drag so the tray still scrolls).
class _DraggableSticker extends StatelessWidget {
  const _DraggableSticker({required this.kind, required this.selected, required this.onSelected});

  final StickerKind kind;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: selected ? AppColors.butter : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.ink : AppColors.shadow,
          width: selected ? 3 : 1.5,
        ),
      ),
      child: CustomPaint(painter: _StickerIconPainter(kind)),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: '${kind.label} sticker',
      excludeSemantics: true,
      child: LongPressDraggable<StickerDragData>(
        data: StickerDragData(kind),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        rootOverlay: true,
        hapticFeedbackOnStart: true,
        delay: const Duration(milliseconds: 180),
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: SizedBox(width: 56, height: 56, child: CustomPaint(painter: _StickerIconPainter(kind))),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: tile),
        onDragStarted: onSelected,
        child: GestureDetector(onTap: onSelected, behavior: HitTestBehavior.opaque, child: tile),
      ),
    );
  }
}

class _StickerIconPainter extends CustomPainter {
  _StickerIconPainter(this.kind);

  final StickerKind kind;

  @override
  void paint(Canvas canvas, Size size) =>
      StickerArt.paint(canvas, kind, size.center(Offset.zero), size.width * 0.7);

  @override
  bool shouldRepaint(_StickerIconPainter old) => old.kind != kind;
}
