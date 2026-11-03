import 'package:flutter/material.dart';

import '../engines/region_coloring/coloring_canvas.dart';
import '../engines/region_coloring/coloring_controller.dart';
import '../models/coloring_artwork.dart';
import '../models/coloring_region.dart';
import '../models/coloring_template.dart';
import '../models/drawing_tool.dart';
import '../models/palette_color.dart';
import '../services/app_scope.dart';
import '../services/export_flow.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/color_palette.dart';
import '../widgets/demo_overlay.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/kid_buttons.dart';
import '../widgets/kid_dialogs.dart';
import 'routes.dart';

class ColoringStudioScreen extends StatefulWidget {
  const ColoringStudioScreen({super.key, required this.templateId, this.artworkId});

  final String templateId;

  /// Continue this specific project; otherwise the latest one for the
  /// template is resumed, or a new one is started.
  final String? artworkId;

  @override
  State<ColoringStudioScreen> createState() => _ColoringStudioScreenState();
}

class _ColoringStudioScreenState extends State<ColoringStudioScreen> {
  final GlobalKey<ColorPaletteState> _paletteKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  Future<ColoringTemplate>? _loading;
  ColoringController? _controller;
  PaletteColor? _extraColor;
  bool _saving = false;
  bool _showDemo = false;

  // Cached so dispose() can flush the project without a context lookup.
  late AppServices _s;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _s = AppScope.of(context);
    if (_controller != null || _loading != null) return;
    final cached = _s.templates.peek(widget.templateId);
    if (cached != null) {
      // Already parsed (e.g. from the sketch gallery): open with no spinner.
      _loading = Future.value(cached);
      _start(cached, rebuild: false);
    } else {
      _loading = _s.templates.load(widget.templateId).then((t) {
        if (mounted) _start(t);
        return t;
      });
    }
  }

  void _start(ColoringTemplate template, {bool rebuild = true}) {
    final settings = _s.settings;
    final existing = widget.artworkId == null ? null : _s.artworks.byId(widget.artworkId!);
    final artwork = existing ?? _s.artworks.openFor(template.id);
    final isNew = artwork.isEmpty && artwork.strokes.isEmpty;
    if (isNew) {
      artwork.studio = StudioPrefs(
        brushSize: settings.isLittle ? BrushSize.large : settings.defaultBrushSize,
        tool: DrawingTool.crayon,
      );
    }
    final controller = ColoringController(
      template: template,
      artwork: artwork,
      onArtworkChanged: _s.artworks.scheduleSave,
    );
    // Respect parent settings that may have changed since the last visit.
    if (!settings.drawingTools && controller.mode == StudioMode.draw) controller.setMode(StudioMode.fill);
    if ((!settings.stickers || settings.isLittle) && controller.mode == StudioMode.sticker) {
      controller.setMode(StudioMode.fill);
    }
    final extra = paletteColorFor(controller.selectedColor);
    if (extra != null && !kBasicPalette.contains(extra)) _extraColor = extra;
    void apply() {
      _controller = controller;
      _showDemo = settings.demonstrations && !settings.demoSeen;
    }

    rebuild ? setState(apply) : apply();
    if (settings.isLittle) _s.sound.say('Pick a color, then put it on the picture!');
  }

  @override
  void dispose() {
    final c = _controller;
    if (c != null) {
      c.finishGesture();
      c.onArtworkChanged = null;
      _s.artworks.save(c.artwork);
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------- actions

  void _selectColor(PaletteColor c) {
    _controller!.selectColor(c.color);
    _s.sound.play(Sfx.tap);
    _s.sound.haptic();
    _s.sound.say(c.name);
  }

  void _filled(ColoringRegion region) {
    _s.sound.play(Sfx.fill);
    _s.sound.haptic();
  }

  Future<void> _moreColors() async {
    final picked = await showMoreColors(context, _controller!.selectedColor);
    if (picked == null || !mounted) return;
    setState(() => _extraColor = picked);
    _selectColor(picked);
  }

  Future<void> _reset() async {
    final c = _controller!;
    if (c.artwork.isEmpty) return;
    final yes = await confirmWithChild(
      context,
      question: 'Start this picture again?',
      icon: Icons.refresh_rounded,
      yes: 'Start again',
      no: 'Keep it',
    );
    if (yes) c.resetPicture();
  }

  Future<void> _save() async {
    final c = _controller;
    if (c == null || _saving) return;
    c.finishGesture();
    setState(() => _saving = true);
    final outcome = await ExportFlow.save(_s, c.template, c.artwork);
    if (!mounted) return;
    setState(() => _saving = false);
    if (outcome.succeeded) {
      _s.sound.play(Sfx.chime);
      _s.sound.say('Your picture is saved!');
      await AppRoutes.previewPage(context, c.artwork.id, png: outcome.png, saveResult: outcome.result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${ExportFlow.messageFor(outcome.result.outcome)} ${ExportFlow.detailFor(outcome.result.outcome)}',
          ),
          action: SnackBarAction(label: 'Try again', onPressed: _save),
        ),
      );
    }
  }

  void _endDemo() {
    setState(() => _showDemo = false);
    _s.settings.update((s) => s.demoSeen = true);
  }

  // ----------------------------------------------------------------- layout

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: AppColors.studioBackground,
      body: SafeArea(
        child: c == null
            ? FutureBuilder(
                future: _loading,
                builder: (context, snap) => Center(
                  child: snap.hasError
                      ? Text("Sorry, this picture couldn't open.", style: AppTextStyles.heading)
                      : const CircularProgressIndicator(),
                ),
              )
            : ListenableBuilder(
                listenable: Listenable.merge([c, _s.settings]),
                builder: (context, _) => LayoutBuilder(
                  builder: (context, box) {
                    final wide = box.maxWidth > box.maxHeight && box.maxWidth >= 700;
                    final body = wide ? _wideLayout(c) : _tallLayout(c, box);
                    return Stack(
                      children: [
                        body,
                        if (_saving) const _SavingVeil(),
                        if (_showDemo)
                          DemoOverlay(
                            paletteKey: _paletteKey,
                            canvasKey: _canvasKey,
                            template: c.template,
                            color: c.selectedColor,
                            reducedMotion: _s.settings.reducedMotion,
                            onDone: _endDemo,
                          ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  bool get _little => _s.settings.isLittle;

  double get _swatch => _little ? 56 : 48;

  /// Fixed height so Fill / Draw / Stickers tool rows do not resize the canvas.
  static const _toolPanelHeight = 140.0;

  static const _modeBarHeight = 58.0;

  Widget _tallLayout(ColoringController c, BoxConstraints box) {
    final small = box.maxHeight < 640;
    return Column(
      children: [
        _topBar(c, box.maxWidth),
        Expanded(child: _canvas(c)),
        const SizedBox(height: 6),
        SizedBox(
          height: _modeBarHeight,
          child: Center(child: _modeSwitch(c, compact: small)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: _toolPanelHeight,
          child: ClipRect(
            child: Align(alignment: Alignment.center, child: _toolRow(c)),
          ),
        ),
        _palette(c, Axis.horizontal),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _wideLayout(ColoringController c) {
    return Row(
      children: [
        Expanded(child: _canvas(c)),
        SizedBox(
          width: 360,
          child: Column(
            children: [
              _topBar(c, 360),
              const SizedBox(height: 8),
              SizedBox(
                height: _modeBarHeight,
                child: Center(child: _modeSwitch(c)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: _toolPanelHeight,
                child: ClipRect(
                  child: Align(alignment: Alignment.center, child: _toolRow(c)),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _palette(c, Axis.vertical),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topBar(ColoringController c, double width) {
    final settings = _s.settings;
    final narrow = width < 420;
    final size = narrow ? 44.0 : 52.0;
    final tiny = width < 380;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            size: size,
            onTap: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 8),
          RoundIconButton(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            size: size,
            onTap: c.canUndo ? c.undo : null,
          ),
          const SizedBox(width: 6),
          RoundIconButton(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            size: size,
            onTap: c.canRedo ? c.redo : null,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RoundIconButton(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Start picture again',
                    size: size,
                    onTap: c.artwork.isEmpty ? null : _reset,
                  ),
                  const SizedBox(width: 6),
                  RoundIconButton(
                    icon: settings.soundEffects ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    tooltip: settings.soundEffects ? 'Sound on' : 'Sound off',
                    size: size,
                    onTap: () => settings.update((s) => s.soundEffects = !s.soundEffects),
                  ),
                  const SizedBox(width: 8),
                  // Very narrow phones get an icon-only Save so nothing overflows.
                  if (tiny)
                    RoundIconButton(
                      icon: Icons.download_rounded,
                      tooltip: 'Save',
                      size: size,
                      color: AppColors.mintDeep,
                      iconColor: Colors.white,
                      onTap: _saving ? null : _save,
                    )
                  else
                    BigPillButton(
                      icon: Icons.download_rounded,
                      label: 'Save',
                      height: size,
                      color: AppColors.mintDeep,
                      onTap: _saving ? null : _save,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _canvas(ColoringController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Container(
        key: _canvasKey,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: ColoringCanvas(
            controller: c,
            reducedMotion: _s.settings.reducedMotion,
            hintsEnabled: _s.settings.hints,
            onFilled: _filled,
            onBackgroundFilled: () {
              _s.sound.play(Sfx.fill);
              _s.sound.haptic();
            },
            onInvalidDrop: (offset, color) => _paletteKey.currentState?.animateReturn(offset, color),
            onStrokeStarted: () => _s.sound.play(Sfx.brush),
            onStickerPlaced: () => _s.sound.play(Sfx.pop),
            onInteraction: _showDemo ? _endDemo : null,
          ),
        ),
      ),
    );
  }

  Widget _modeSwitch(ColoringController c, {bool compact = false}) {
    final settings = _s.settings;
    return ModeSwitch(
      mode: c.mode,
      color: c.selectedColor,
      compact: compact,
      showDraw: settings.drawingTools,
      showStickers: settings.stickers && !_little,
      onChanged: (m) {
        _s.sound.play(Sfx.tap);
        c.setMode(m);
      },
    );
  }

  List<DrawingTool> get _tools =>
      _little ? const [DrawingTool.crayon, DrawingTool.marker, DrawingTool.eraser] : DrawingTool.values;

  Widget _toolRow(ColoringController c) {
    final canClear = c.artwork.strokes.isNotEmpty || c.artwork.stickers.isNotEmpty;
    switch (c.mode) {
      case StudioMode.draw:
        return DrawingToolbar(
          tools: _tools,
          tool: c.tool,
          size: c.brushSize,
          color: c.selectedColor,
          showSizes: !_little,
          canClear: canClear,
          onTool: (t) {
            _s.sound.play(Sfx.tap);
            c.setTool(t);
          },
          onSize: c.setBrushSize,
          onClear: c.clearDrawing,
        );
      case StudioMode.sticker:
        return StickerTray(
          kind: c.stickerKind,
          onKind: c.setStickerKind,
          onClear: c.clearDrawing,
          canClear: canClear,
        );
      case StudioMode.fill:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwatchDot(color: c.selectedColor, size: 40, selected: true),
              const SizedBox(width: 10),
              const Icon(Icons.east_rounded, color: AppColors.inkSoft, size: 28),
              const SizedBox(width: 6),
              const Icon(Icons.touch_app_rounded, color: AppColors.inkSoft, size: 34),
              if (!_little) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Drag a color onto a part or the background!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }

  Widget _palette(ColoringController c, Axis axis) => ColorPalette(
    key: _paletteKey,
    selected: c.selectedColor,
    extraColor: _extraColor,
    swatchSize: _swatch,
    axis: axis,
    onSelected: _selectColor,
    onMoreColors: _little ? null : _moreColors,
  );
}

class _SavingVeil extends StatelessWidget {
  const _SavingVeil();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.mintDeep),
              const SizedBox(height: 14),
              Text('Saving your picture…', style: AppTextStyles.heading),
            ],
          ),
        ),
      ),
    );
  }
}
