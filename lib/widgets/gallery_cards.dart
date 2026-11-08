import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/coloring_artwork.dart';
import '../models/coloring_category.dart';
import '../models/coloring_template.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'artwork_view.dart';
import 'kid_buttons.dart';

/// Picture-first category card: a coloured-in example sketch standing in a
/// little pastel scene (clouds, grass), the name and how many pictures.
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});

  final ColoringCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = category.templateIds.length;
    final tint = category.color;
    return Semantics(
      button: true,
      label: '${category.title}, $count pictures',
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: AppColors.grape.withValues(alpha: 0.18), blurRadius: 14, offset: const Offset(0, 7)),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.lerp(tint, Colors.white, 0.4)!, tint, _richer(tint)],
                  stops: const [0, 0.45, 1],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _CardSceneryPainter(category.id))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                    child: Column(
                      children: [
                        Expanded(child: ArtworkView(templateId: category.coverTemplateId, demoColors: true)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            category.title,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title.copyWith(fontSize: 19, color: AppColors.grape),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.lavender, width: 1.5),
                            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: Text(
                            '$count pictures',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.grapeSoft),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A deeper, more saturated version of a pastel tint for the card's foot.
Color _richer(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl
      .withSaturation(math.min(1, hsl.saturation + 0.25))
      .withLightness(math.max(0, hsl.lightness - 0.07))
      .toColor();
}

/// A little scene behind each category's cover picture: bubbles and sand
/// under the sea, a road for vehicles, a branch for birds and so on.
class _CardSceneryPainter extends CustomPainter {
  const _CardSceneryPainter(this.categoryId);

  final String categoryId;

  static const _leafDark = Color(0xFF4FA83A);
  static const _leaf = Color(0xFF6CC644);
  static const _leafLight = Color(0xFF8BD45A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final ground = h * 0.66;
    switch (categoryId) {
      case 'flowers_garden':
        _clouds(canvas, w, h);
        _glow(canvas, w, ground);
        _grass(canvas, w, h, ground);
        _tinyFlower(canvas, Offset(w * 0.1, ground + h * 0.01), w * 0.025, const Color(0xFFFF8FC0));
        _tinyFlower(canvas, Offset(w * 0.9, ground - h * 0.01), w * 0.022, const Color(0xFFFFD43B));
      case 'pets_farm':
        _clouds(canvas, w, h);
        _glow(canvas, w, ground);
        _fence(canvas, w, ground, h * 0.13);
        _grass(canvas, w, h, ground);
      case 'wild_animals':
        _glow(canvas, w, ground);
        for (final (x, flip) in [(w * 0.14, 1.0), (w * 0.86, -1.0)]) {
          _leafFan(canvas, Offset(x, ground + h * 0.02), h * 0.2, flip);
        }
      case 'birds_insects':
        _clouds(canvas, w, h);
        _branch(canvas, w, h, ground);
      case 'underwater_world':
        _sand(canvas, w, h, ground);
        for (final (x, flip) in [(w * 0.12, 1.0), (w * 0.88, -1.0)]) {
          _seaweed(canvas, Offset(x, ground + h * 0.02), h * 0.2, flip);
        }
        _bubbles(canvas, w, h);
      case 'vehicles':
        _road(canvas, w, h, ground);
      case 'buildings_places':
        _clouds(canvas, w, h);
        _glow(canvas, w, ground);
        _fence(canvas, w, ground, h * 0.1);
        _roundTree(canvas, Offset(w * 0.13, ground + h * 0.02), w * 0.09);
        _roundTree(canvas, Offset(w * 0.87, ground + h * 0.02), w * 0.09);
      case 'fruits_vegetables':
        _glow(canvas, w, ground);
        for (final (x, flip) in [(w * 0.2, 1.0), (w * 0.8, -1.0)]) {
          _bigLeaf(canvas, Offset(x, ground + h * 0.02), h * 0.17, flip);
        }
      case 'sky_weather':
        _clouds(canvas, w, h, extra: true);
      case 'toys_imagination':
        _stars(canvas, w, h);
      default:
        _clouds(canvas, w, h);
        _grass(canvas, w, h, ground);
    }
  }

  void _cloud(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, r * 0.3), width: r * 3.6, height: r * 1.2),
        Radius.circular(r),
      ),
      paint,
    );
    canvas.drawCircle(c + Offset(-r * 0.5, 0), r * 0.7, paint);
    canvas.drawCircle(c + Offset(r * 0.4, -r * 0.2), r * 0.9, paint);
  }

  void _clouds(Canvas canvas, double w, double h, {bool extra = false}) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    _cloud(canvas, Offset(w * 0.2, h * 0.1), w * 0.07, paint);
    _cloud(canvas, Offset(w * 0.82, h * 0.08), w * 0.065, paint);
    if (extra) {
      _cloud(canvas, Offset(w * 0.55, h * 0.05), w * 0.05, paint);
      _cloud(canvas, Offset(w * 0.12, h * 0.55), w * 0.06, paint);
      _cloud(canvas, Offset(w * 0.9, h * 0.5), w * 0.055, paint);
    }
  }

  void _glow(Canvas canvas, double w, double ground) => canvas.drawOval(
    Rect.fromCenter(center: Offset(w / 2, ground), width: w * 0.95, height: w * 0.11),
    Paint()..color = Colors.white.withValues(alpha: 0.35),
  );

  void _grass(Canvas canvas, double w, double h, double ground) {
    for (final (x, flip) in [(w * 0.17, 1.0), (w * 0.83, -1.0)]) {
      for (final (dx, len, a, color) in const [
        (-6.0, 0.13, -0.55, Color(0xFF5DBB3F)),
        (0.0, 0.17, -0.1, _leaf),
        (6.0, 0.14, 0.4, _leafDark),
        (11.0, 0.1, 0.8, Color(0xFF7ED957)),
      ]) {
        final base = Offset(x + dx * flip * w / 180, ground + h * 0.01);
        final tip = base + Offset(math.sin(a * flip) * h * len * 0.6, -h * len);
        final blade = Path()
          ..moveTo(base.dx - w * 0.018, base.dy)
          ..quadraticBezierTo(base.dx, base.dy - h * len * 0.5, tip.dx, tip.dy)
          ..quadraticBezierTo(base.dx + w * 0.004, base.dy - h * len * 0.4, base.dx + w * 0.018, base.dy)
          ..close();
        canvas.drawPath(blade, Paint()..color = color);
      }
    }
  }

  void _tinyFlower(Canvas canvas, Offset c, double r, Color color) {
    for (var i = 0; i < 5; i++) {
      final a = i / 5 * 2 * math.pi;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, r * 0.8, Paint()..color = color);
    }
    canvas.drawCircle(c, r * 0.6, Paint()..color = const Color(0xFFFFB300));
  }

  void _leafShape(Canvas canvas, Offset base, double len, double angle, Color color) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.35, -len * 0.5, 0, -len)
      ..quadraticBezierTo(-len * 0.35, -len * 0.5, 0, 0)
      ..close();
    canvas.drawPath(leaf, Paint()..color = color);
    canvas.drawLine(
      Offset.zero,
      Offset(0, -len * 0.85),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..strokeWidth = 1.2,
    );
    canvas.restore();
  }

  /// A bushy fan of jungle leaves.
  void _leafFan(Canvas canvas, Offset base, double len, double flip) {
    for (final (a, l, c) in const [
      (-0.9, 0.8, _leafDark),
      (-0.35, 1.0, _leaf),
      (0.2, 0.9, _leafDark),
      (0.7, 0.7, _leafLight),
    ]) {
      _leafShape(canvas, base, len * l, a * flip, c);
    }
  }

  void _bigLeaf(Canvas canvas, Offset base, double len, double flip) {
    _leafShape(canvas, base, len, -1.0 * flip, _leaf);
    _leafShape(canvas, base, len * 0.8, -0.45 * flip, _leafLight);
  }

  void _fence(Canvas canvas, double w, double ground, double postH) {
    final wood = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final edge = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final postW = w * 0.035;
    for (final (from, to) in [(0.0, w * 0.3), (w * 0.7, w)]) {
      for (final y in [ground - postH * 0.75, ground - postH * 0.35]) {
        final rail = Rect.fromLTWH(from, y, to - from, postH * 0.12);
        canvas.drawRect(rail, wood);
        canvas.drawRect(rail, edge);
      }
      for (var x = from + postW * 0.4; x < to - postW * 0.5; x += postW * 2.2) {
        final post = Path()
          ..moveTo(x, ground)
          ..lineTo(x, ground - postH)
          ..lineTo(x + postW / 2, ground - postH - postW * 0.6)
          ..lineTo(x + postW, ground - postH)
          ..lineTo(x + postW, ground)
          ..close();
        canvas.drawPath(post, wood);
        canvas.drawPath(post, edge);
      }
    }
  }

  void _roundTree(Canvas canvas, Offset base, double r) {
    canvas.drawRect(
      Rect.fromCenter(center: base + Offset(0, -r * 0.7), width: r * 0.3, height: r * 1.4),
      Paint()..color = const Color(0xFF8A5A2B),
    );
    canvas.drawCircle(base + Offset(0, -r * 1.7), r, Paint()..color = _leaf);
    canvas.drawCircle(base + Offset(-r * 0.3, -r * 2.0), r * 0.4, Paint()..color = _leafLight);
  }

  /// A brown branch for the bird to perch on.
  void _branch(Canvas canvas, double w, double h, double ground) {
    final y = ground + h * 0.01;
    final branch = Path()
      ..moveTo(w * 0.04, y + h * 0.03)
      ..quadraticBezierTo(w * 0.5, y - h * 0.03, w * 0.96, y - h * 0.01);
    canvas.drawPath(
      branch,
      Paint()
        ..color = const Color(0xFF8A5A2B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.035
        ..strokeCap = StrokeCap.round,
    );
    _leafShape(canvas, Offset(w * 0.14, y + h * 0.015), h * 0.09, -1.1, _leaf);
    _leafShape(canvas, Offset(w * 0.2, y + h * 0.01), h * 0.08, 0.5, _leafLight);
    _leafShape(canvas, Offset(w * 0.86, y - h * 0.005), h * 0.09, 1.1, _leaf);
    _leafShape(canvas, Offset(w * 0.8, y), h * 0.07, -0.4, _leafLight);
  }

  void _sand(Canvas canvas, double w, double h, double ground) {
    final mound = Path()
      ..moveTo(0, ground + h * 0.03)
      ..quadraticBezierTo(w * 0.5, ground - h * 0.06, w, ground + h * 0.03)
      ..lineTo(w, ground + h * 0.08)
      ..quadraticBezierTo(w * 0.5, ground + h * 0.02, 0, ground + h * 0.08)
      ..close();
    canvas.drawPath(mound, Paint()..color = const Color(0xFFF6DFA0));
  }

  void _seaweed(Canvas canvas, Offset base, double len, double flip) {
    for (final (dx, l, c) in const [(-4.0, 1.0, _leaf), (4.0, 0.75, _leafDark)]) {
      final b = base + Offset(dx * flip, 0);
      final weed = Path()
        ..moveTo(b.dx - 3, b.dy)
        ..cubicTo(b.dx - 10 * flip, b.dy - len * l * 0.4, b.dx + 10 * flip, b.dy - len * l * 0.6, b.dx, b.dy - len * l)
        ..cubicTo(b.dx + 14 * flip, b.dy - len * l * 0.6, b.dx - 6 * flip, b.dy - len * l * 0.4, b.dx + 3, b.dy)
        ..close();
      canvas.drawPath(weed, Paint()..color = c);
    }
  }

  void _bubbles(Canvas canvas, double w, double h) {
    final ring = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.3);
    for (final (x, y, r) in const [
      (0.12, 0.12, 0.04),
      (0.2, 0.22, 0.025),
      (0.1, 0.3, 0.018),
      (0.86, 0.1, 0.035),
      (0.9, 0.24, 0.022),
      (0.8, 0.32, 0.016),
    ]) {
      final c = Offset(w * x, h * y);
      canvas.drawCircle(c, w * r, fill);
      canvas.drawCircle(c, w * r, ring);
      canvas.drawCircle(c + Offset(-w * r * 0.35, -w * r * 0.35), w * r * 0.22, Paint()..color = Colors.white);
    }
  }

  /// A grey road with dashed lane markings receding into the card.
  void _road(Canvas canvas, double w, double h, double ground) {
    final top = ground - h * 0.1, bottom = ground + h * 0.035;
    final road = Path()
      ..moveTo(0, top + h * 0.02)
      ..lineTo(w, top)
      ..lineTo(w, bottom)
      ..lineTo(0, bottom + h * 0.02)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFF9EA3B5));
    canvas.drawLine(
      Offset(0, top + h * 0.02),
      Offset(w, top),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 2,
    );
    final dash = Paint()
      ..color = Colors.white
      ..strokeWidth = h * 0.012
      ..strokeCap = StrokeCap.round;
    final mid = (top + bottom) / 2 + h * 0.01;
    for (var x = w * 0.04; x < w; x += w * 0.2) {
      canvas.drawLine(Offset(x, mid), Offset(x + w * 0.09, mid - h * 0.002), dash);
    }
  }

  void _stars(Canvas canvas, double w, double h) {
    for (final (x, y, r, color) in const [
      (0.14, 0.12, 0.06, Color(0xFFFFC21A)),
      (0.86, 0.14, 0.055, Color(0xFFFFC21A)),
      (0.12, 0.48, 0.045, Color(0xFFFF7FB0)),
      (0.9, 0.52, 0.05, Color(0xFFFFC21A)),
      (0.5, 0.06, 0.03, Color(0xFFB79CFF)),
    ]) {
      final c = Offset(w * x, h * y);
      final path = Path();
      for (var i = 0; i < 10; i++) {
        final a = i * math.pi / 5 - math.pi / 2;
        final rad = i.isEven ? w * r : w * r * 0.45;
        final p = c + Offset(math.cos(a), math.sin(a)) * rad;
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _CardSceneryPainter old) => old.categoryId != categoryId;
}

/// A sketch to choose. Unstarted sketches show the template's own
/// thumbnail; started ones show the child's current colours.
class SketchCard extends StatefulWidget {
  const SketchCard({
    super.key,
    required this.template,
    required this.artwork,
    required this.progress,
    required this.onTap,
  });

  final TemplateInfo template;
  final ColoringArtwork? artwork;

  /// 0..1, or null when not started.
  final double? progress;
  final VoidCallback onTap;

  @override
  State<SketchCard> createState() => _SketchCardState();
}

class _SketchCardState extends State<SketchCard> {
  bool _picked = false;

  Future<void> _tap() async {
    setState(() => _picked = true);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    widget.onTap();
    setState(() => _picked = false);
  }

  @override
  Widget build(BuildContext context) {
    final started = widget.artwork != null;
    return Semantics(
      button: true,
      label: '${widget.template.title}${started ? ', started' : ''}',
      excludeSemantics: true,
      child: Squishy(
        onTap: _tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _picked ? AppColors.coral : Colors.white, width: _picked ? 6 : 4),
            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 6))],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                // The real template drawn by the app's renderer: blank line
                // art when new, the child's colours once started.
                child: ArtworkView(templateId: widget.template.id, artwork: widget.artwork),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.progress != null) ...[_ProgressDot(progress: widget.progress!), const SizedBox(width: 6)],
                  Flexible(
                    child: Text(
                      widget.template.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(fontSize: 18),
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
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: progress >= 1
          ? const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 22)
          : CircularProgressIndicator(
              value: progress.clamp(0.05, 1.0),
              strokeWidth: 4,
              backgroundColor: AppColors.studioBackground,
              color: AppColors.mintDeep,
            ),
    );
  }
}
