import 'package:flutter/material.dart';

import '../data/coloring_catalog.dart';
import '../models/coloring_template.dart';
import '../services/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/gallery_cards.dart';
import '../widgets/screen_header.dart';
import 'routes.dart';

class SketchSelectionScreen extends StatefulWidget {
  const SketchSelectionScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<SketchSelectionScreen> createState() => _SketchSelectionScreenState();
}

class _SketchSelectionScreenState extends State<SketchSelectionScreen> {
  Future<List<ColoringTemplate>>? _templates;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = AppScope.of(context).templates;
    _templates ??= Future.wait([
      for (final t in ColoringCatalog.templatesIn(widget.categoryId)) repo.load(t.id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final category = ColoringCatalog.category(widget.categoryId)!;
    final infos = ColoringCatalog.templatesIn(widget.categoryId);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 900 ? 5 : (width > 600 ? 3 : 2);
    return Scaffold(
      backgroundColor: Color.lerp(category.color, AppColors.cream, 0.4),
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: category.title),
            Expanded(
              child: FutureBuilder<List<ColoringTemplate>>(
                future: _templates,
                builder: (context, snap) => ListenableBuilder(
                  listenable: services.artworks,
                  builder: (context, _) => GridView.count(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    crossAxisCount: columns,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.9,
                    children: [for (final info in infos) _card(context, info, snap.data)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, TemplateInfo info, List<ColoringTemplate>? loaded) {
    final artwork = AppScope.of(context).artworks.latestFor(info.id);
    double? progress;
    final template = loaded?.where((t) => t.id == info.id).firstOrNull;
    if (artwork != null && template != null) {
      final total = template.fillableRegions.length;
      progress = total == 0 ? 0 : artwork.fills.length / total;
    }
    return SketchCard(
      template: info,
      artwork: artwork,
      progress: progress,
      onTap: () => AppRoutes.studioPage(context, info.id, artworkId: artwork?.id),
    );
  }
}
