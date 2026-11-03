import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../models/coloring_artwork.dart';
import '../services/app_scope.dart';
import '../services/export_flow.dart';
import '../services/gallery_save_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/artwork_view.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/screen_header.dart';
import 'category_gallery_screen.dart';
import 'routes.dart';
import 'sketch_selection_screen.dart';

/// Shows a finished picture. After "Save Picture" it doubles as the
/// "Artwork Saved" screen, with a short celebration and next steps.
class ArtworkPreviewScreen extends StatefulWidget {
  const ArtworkPreviewScreen({super.key, required this.artworkId, this.png, this.saveResult});

  final String artworkId;

  /// The exported image, when arriving straight from a save.
  final Uint8List? png;
  final SaveResult? saveResult;

  @override
  State<ArtworkPreviewScreen> createState() => _ArtworkPreviewScreenState();
}

class _ArtworkPreviewScreenState extends State<ArtworkPreviewScreen> {
  SaveResult? _result;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _result = widget.saveResult;
  }

  ColoringArtwork? get _artwork => AppScope.of(context).artworks.byId(widget.artworkId);

  Future<void> _savePng() async {
    final s = AppScope.of(context);
    final a = _artwork;
    if (a == null || _busy) return;
    setState(() => _busy = true);
    final template = await s.templates.load(a.templateId);
    final outcome = await ExportFlow.save(s, template, a);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = outcome.result;
    });
  }

  Future<void> _share(BuildContext buttonContext) async {
    final s = AppScope.of(context);
    final a = _artwork;
    if (a == null || _busy) return;
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    final template = await s.templates.load(a.templateId);
    final ok = await ExportFlow.share(s, template, a, origin: origin);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sharing is not available on this device.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final a = _artwork;
    final info = a == null ? null : ColoringCatalog.template(a.templateId);
    if (a == null || info == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const ScreenHeader(title: 'Picture'),
              const Spacer(),
            ],
          ),
        ),
      );
    }
    final celebrate = widget.saveResult != null;
    final result = _result;
    final picture = widget.png != null && celebrate
        ? Image.memory(widget.png!, fit: BoxFit.contain, gaplessPlayback: true)
        : ArtworkView(templateId: a.templateId, artwork: a);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: info.title),
            if (result != null) _Banner(result: result),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _MagicReveal(
                  enabled: celebrate && !s.settings.reducedMotion,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 8)),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Semantics(image: true, label: 'Your ${info.title} picture', child: picture),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  BigPillButton(
                    icon: Icons.brush_rounded,
                    label: celebrate ? 'Keep Coloring' : 'Continue Coloring',
                    color: AppColors.skyDeep,
                    height: 56,
                    onTap: () => celebrate
                        ? Navigator.pop(context)
                        : AppRoutes.studioPage(context, a.templateId, artworkId: a.id),
                  ),
                  if (celebrate) ...[
                    BigPillButton(
                      icon: Icons.add_photo_alternate_rounded,
                      label: 'Color Another Picture',
                      height: 56,
                      onTap: () => AppRoutes.backTo(
                        context,
                        AppRoutes.sketches,
                        () => SketchSelectionScreen(categoryId: info.categoryId),
                      ),
                    ),
                    BigPillButton(
                      icon: Icons.grid_view_rounded,
                      label: 'Back to Gallery',
                      color: AppColors.lavenderDeep,
                      height: 56,
                      onTap: () => AppRoutes.backTo(
                        context,
                        AppRoutes.categories,
                        () => const CategoryGalleryScreen(),
                      ),
                    ),
                  ] else
                    BigPillButton(
                      icon: Icons.download_rounded,
                      label: 'Save Picture',
                      color: AppColors.mintDeep,
                      height: 56,
                      onTap: _busy ? null : _savePng,
                    ),
                  Builder(
                    builder: (buttonContext) => BigPillButton(
                      icon: Icons.ios_share_rounded,
                      label: 'Share',
                      color: AppColors.coralDeep,
                      height: 56,
                      onTap: _busy ? null : () => _share(buttonContext),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.result});

  final SaveResult result;

  @override
  Widget build(BuildContext context) {
    final ok = result.outcome == SaveOutcome.savedToGallery || result.outcome == SaveOutcome.savedInApp;
    final detail = ExportFlow.detailFor(result.outcome);
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: ok ? AppColors.mint : AppColors.butter,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(ok ? Icons.check_circle_rounded : Icons.info_rounded, color: AppColors.ink, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ExportFlow.messageFor(result.outcome), style: AppTextStyles.heading),
                  if (detail != null)
                    Text(detail, style: AppTextStyles.caption.copyWith(color: AppColors.ink)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A short, gentle celebration: the picture pops in while a few stars
/// twinkle around it. The artwork itself is never altered.
class _MagicReveal extends StatefulWidget {
  const _MagicReveal({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_MagicReveal> createState() => _MagicRevealState();
}

class _MagicRevealState extends State<_MagicReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
    value: widget.enabled ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final pop = Curves.elasticOut.transform((_c.value / 0.6).clamp(0.0, 1.0));
        final sparkle = math.sin(_c.value * math.pi);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Transform.scale(scale: 0.85 + 0.15 * pop, child: child),
            ),
            if (widget.enabled && _c.value < 1)
              for (var i = 0; i < 6; i++)
                Align(
                  alignment: Alignment(math.cos(i * 1.05) * 0.95, math.sin(i * 1.05) * 0.95),
                  child: Opacity(
                    opacity: sparkle.clamp(0.0, 1.0),
                    child: Icon(Icons.star_rounded, size: 26 + 10 * sparkle, color: const Color(0xFFFFC107)),
                  ),
                ),
          ],
        );
      },
    );
  }
}
