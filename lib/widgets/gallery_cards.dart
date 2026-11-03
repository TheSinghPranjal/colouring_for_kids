import 'package:flutter/material.dart';

import '../models/coloring_artwork.dart';
import '../models/coloring_category.dart';
import '../models/coloring_template.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'artwork_view.dart';
import 'kid_buttons.dart';

/// Picture-first category card: a coloured-in example sketch, the name and
/// how many pictures are inside.
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});

  final ColoringCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = category.templateIds.length;
    return Semantics(
      button: true,
      label: '${category.title}, $count pictures',
      excludeSemantics: true,
      child: Squishy(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: category.color,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 6))],
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            children: [
              Expanded(child: ArtworkView(templateId: category.coverTemplateId, demoColors: true)),
              const SizedBox(height: 4),
              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count pictures',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(fontSize: 12, color: AppColors.inkSoft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
                  if (widget.progress != null) ...[
                    _ProgressDot(progress: widget.progress!),
                    const SizedBox(width: 6),
                  ],
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
