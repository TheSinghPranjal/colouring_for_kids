import 'package:flutter/material.dart';

import '../engines/region_coloring/canvas_transform.dart';
import '../models/coloring_template.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'color_palette.dart';

/// First-visit demonstration: a hand carries the selected colour from the
/// palette to the biggest part of the picture. Any touch dismisses it, and it
/// never changes the artwork.
class DemoOverlay extends StatefulWidget {
  const DemoOverlay({
    super.key,
    required this.paletteKey,
    required this.canvasKey,
    required this.template,
    required this.color,
    required this.onDone,
    this.reducedMotion = false,
  });

  final GlobalKey<ColorPaletteState> paletteKey;
  final GlobalKey canvasKey;
  final ColoringTemplate template;
  final Color color;
  final VoidCallback onDone;
  final bool reducedMotion;

  @override
  State<DemoOverlay> createState() => _DemoOverlayState();
}

class _DemoOverlayState extends State<DemoOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  Offset? _from;
  Offset? _to;
  int _loops = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    _anim.addStatusListener((s) {
      if (s != AnimationStatus.completed) return;
      if (++_loops >= 2) {
        widget.onDone();
      } else {
        _anim.forward(from: 0);
      }
    });
  }

  void _measure() {
    if (!mounted) return;
    final overlayBox = context.findRenderObject() as RenderBox?;
    final canvasBox = widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final from = widget.paletteKey.currentState?.swatchCenter(widget.color);
    if (overlayBox == null || canvasBox == null || from == null) {
      widget.onDone();
      return;
    }
    final regions = widget.template.fillableRegions.toList()..sort((a, b) => b.area.compareTo(a.area));
    final t = CanvasTransform.fit(canvasBox.size, widget.template.viewBox, padding: 10);
    final target = regions.isEmpty ? canvasBox.size.center(Offset.zero) : t.toLocal(regions.first.center);
    setState(() {
      _from = overlayBox.globalToLocal(from);
      _to = overlayBox.globalToLocal(canvasBox.localToGlobal(target));
    });
    if (widget.reducedMotion) {
      _anim.value = 1;
      Future<void>.delayed(const Duration(seconds: 4), () {
        if (mounted) widget.onDone();
      });
    } else {
      _anim.forward();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => widget.onDone(),
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              if (_from == null || _to == null) return const SizedBox.expand();
              final v = _anim.value;
              // Pause on the swatch, travel, then pause on the picture.
              final travel = Curves.easeInOut.transform(((v - 0.2) / 0.55).clamp(0.0, 1.0));
              final p = Offset.lerp(_from, _to, travel)!;
              final dropped = v > 0.8;
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 12,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.palette_rounded, color: AppColors.coral),
                            const SizedBox(width: 6),
                            const Icon(Icons.east_rounded, color: AppColors.inkSoft),
                            const SizedBox(width: 6),
                            Text('Drag a color onto the picture', style: AppTextStyles.label),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!dropped)
                    Positioned(
                      left: p.dx - 26,
                      top: p.dy - 26,
                      child: SwatchDot(color: widget.color, size: 52, floating: true),
                    ),
                  if (dropped)
                    Positioned(
                      left: _to!.dx - 40,
                      top: _to!.dy - 40,
                      child: Opacity(
                        opacity: (1 - (v - 0.8) / 0.2).clamp(0.0, 1.0),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: p.dx - 6,
                    top: p.dy + 8,
                    child: const Icon(
                      Icons.touch_app_rounded,
                      size: 64,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
