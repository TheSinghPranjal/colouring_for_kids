import 'package:flutter/material.dart';

import '../models/drawing_tool.dart';
import '../services/app_scope.dart';
import '../services/app_settings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/screen_header.dart';

/// The Parent Zone. Reached only through the grown-up gate.
class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final settings = s.settings;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'For Grown-ups'),
            Expanded(
              child: ListenableBuilder(
                listenable: Listenable.merge([settings, s.artworks]),
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    _Section('Age mode', [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SegmentedButton<AgeMode>(
                          segments: [
                            for (final m in AgeMode.values)
                              ButtonSegment(
                                value: m,
                                label: Text('${m.label}\n${m.ages}', textAlign: TextAlign.center),
                              ),
                          ],
                          selected: {settings.ageMode},
                          onSelectionChanged: (v) => settings.update((x) => x.ageMode = v.first),
                        ),
                      ),
                      _Note(
                        settings.isLittle
                            ? 'Bigger colour buttons, three simple drawing tools, no stickers.'
                            : 'All four drawing tools, brush sizes, extra colours and stickers.',
                      ),
                    ]),
                    _Section('Sound & feel', [
                      _toggle('Sound effects', 'Soft clicks and chimes', settings.soundEffects, (v) {
                        settings.update((x) => x.soundEffects = v);
                      }),
                      _toggle('Spoken prompts', 'Says colour names and short tips', settings.voicePrompts, (
                        v,
                      ) {
                        settings.update((x) => x.voicePrompts = v);
                      }),
                      _toggle('Haptics', 'Gentle vibration on taps', settings.haptics, (v) {
                        settings.update((x) => x.haptics = v);
                      }),
                      _toggle('Reduce motion', 'Fewer animations and sparkles', settings.reducedMotion, (v) {
                        settings.update((x) => x.reducedMotion = v);
                      }),
                    ]),
                    _Section('Help for your child', [
                      _toggle(
                        'Demonstration',
                        'Shows how to drag a colour on first use',
                        settings.demonstrations,
                        (v) {
                          settings.update((x) => x.demonstrations = v);
                        },
                      ),
                      ListTile(
                        title: const Text('Show the demonstration again'),
                        trailing: const Icon(Icons.replay_rounded),
                        onTap: () {
                          settings.update((x) {
                            x.demoSeen = false;
                            x.demonstrations = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('It will play next time a picture opens.')),
                          );
                        },
                      ),
                      _toggle(
                        'Automatic hints',
                        'Gently highlights a part to color after a pause',
                        settings.hints,
                        (v) {
                          settings.update((x) => x.hints = v);
                        },
                      ),
                    ]),
                    _Section('Creative tools', [
                      _toggle(
                        'Drawing tools',
                        'Pencil, crayon, marker, watercolor and eraser',
                        settings.drawingTools,
                        (v) {
                          settings.update((x) => x.drawingTools = v);
                        },
                      ),
                      _toggle('Stickers', 'Optional sticker tray (Creative Explorer)', settings.stickers, (
                        v,
                      ) {
                        settings.update((x) => x.stickers = v);
                      }),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(child: Text('Default brush size', style: AppTextStyles.body)),
                            SegmentedButton<BrushSize>(
                              segments: [
                                for (final b in BrushSize.values)
                                  ButtonSegment(value: b, label: Text(b.label)),
                              ],
                              selected: {settings.defaultBrushSize},
                              onSelectionChanged: (v) => settings.update((x) => x.defaultBrushSize = v.first),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    _Section('Artwork storage', [
                      ListTile(
                        leading: const Icon(Icons.folder_rounded),
                        title: Text('${s.artworks.all.length} pictures saved on this device'),
                        subtitle: const Text(
                          'Editable pictures are stored privately inside the app. '
                          'Saved PNGs go to the photo gallery when allowed, and a copy is kept in the app for sharing.',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_forever_rounded, color: AppColors.coralDeep),
                        title: const Text('Delete all artwork'),
                        subtitle: const Text('Pictures already saved to the photo gallery are not affected.'),
                        onTap: () => _confirmDeleteAll(context),
                      ),
                    ]),
                    const _Section('Privacy', [
                      _Note(
                        'Color Sprout works fully offline. It has no accounts, no ads, no in-app purchases, '
                        'no analytics and no tracking, and it never asks for a name, photos, contacts or the '
                        'microphone. Photo access is requested only to add a picture to the gallery when '
                        'Save Picture is tapped, and declining it keeps everything working.',
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) =>
      SwitchListTile(title: Text(title), subtitle: Text(subtitle), value: value, onChanged: onChanged);

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final s = AppScope.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all artwork?'),
        content: const Text('This removes every editable picture from this device. It cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete all')),
        ],
      ),
    );
    if (yes == true) await s.artworks.deleteAll();
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Text(title, style: AppTextStyles.heading),
          ),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
    child: Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.ink, height: 1.35)),
  );
}
