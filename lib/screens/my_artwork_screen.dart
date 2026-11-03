import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../models/coloring_artwork.dart';
import '../services/app_scope.dart';
import '../services/export_flow.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/artwork_view.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/kid_dialogs.dart';
import '../widgets/mascot.dart';
import '../widgets/screen_header.dart';
import 'routes.dart';

class MyArtworkScreen extends StatelessWidget {
  const MyArtworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 1000 ? 4 : (width > 640 ? 3 : 2);
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'My Artwork'),
            Expanded(
              child: ListenableBuilder(
                listenable: s.artworks,
                builder: (context, _) {
                  final items = s.artworks.all;
                  if (items.isEmpty) return const _Empty();
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) => _ArtworkTile(artwork: items[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Mascot(size: 120, animate: !AppScope.of(context).settings.reducedMotion),
            const SizedBox(height: 16),
            Text('Your pictures will live here!', textAlign: TextAlign.center, style: AppTextStyles.heading),
            const SizedBox(height: 20),
            BigPillButton(
              icon: Icons.palette_rounded,
              label: 'Start Coloring',
              onTap: () => AppRoutes.categoriesPage(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkTile extends StatelessWidget {
  const _ArtworkTile({required this.artwork});

  final ColoringArtwork artwork;

  Future<void> _delete(BuildContext context) async {
    final s = AppScope.of(context);
    final yes = await confirmWithChild(
      context,
      question: 'Throw away this picture?',
      icon: Icons.delete_rounded,
      yes: 'Throw away',
      no: 'Keep it',
    );
    if (yes) await s.artworks.delete(artwork.id);
  }

  Future<void> _share(BuildContext context) async {
    final s = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    final template = await s.templates.load(artwork.templateId);
    final ok = await ExportFlow.share(s, template, artwork, origin: origin);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(content: Text('Sharing is not available on this device.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ColoringCatalog.template(artwork.templateId);
    if (info == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 5))],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: 'Look at ${info.title}',
              excludeSemantics: true,
              child: Squishy(
                onTap: () => AppRoutes.previewPage(context, artwork.id),
                child: ArtworkView(templateId: artwork.templateId, artwork: artwork),
              ),
            ),
          ),
          Text(info.title, style: AppTextStyles.label.copyWith(fontSize: 18)),
          const SizedBox(height: 6),
          FittedBox(
            child: Row(
              children: [
                RoundIconButton(
                  icon: Icons.brush_rounded,
                  tooltip: 'Continue coloring',
                  size: 44,
                  color: AppColors.mint,
                  onTap: () => AppRoutes.studioPage(context, artwork.templateId, artworkId: artwork.id),
                ),
                const SizedBox(width: 6),
                RoundIconButton(
                  icon: Icons.visibility_rounded,
                  tooltip: 'Preview',
                  size: 44,
                  onTap: () => AppRoutes.previewPage(context, artwork.id),
                ),
                const SizedBox(width: 6),
                Builder(
                  builder: (c) => RoundIconButton(
                    icon: Icons.ios_share_rounded,
                    tooltip: 'Share',
                    size: 44,
                    onTap: () => _share(c),
                  ),
                ),
                const SizedBox(width: 6),
                RoundIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Delete',
                  size: 44,
                  iconColor: AppColors.coralDeep,
                  onTap: () => _delete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
