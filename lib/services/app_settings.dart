import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/drawing_tool.dart';

enum AgeMode {
  /// Ages 2–3: bigger targets, fewer tools, one action at a time.
  littleArtist('Little Artist', 'Ages 2–3'),

  /// Ages 4–5: all four drawing tools, sizes and stickers.
  creativeExplorer('Creative Explorer', 'Ages 4–5');

  const AgeMode(this.label, this.ages);

  final String label;
  final String ages;
}

/// Parent-controlled preferences. Defaults are chosen so the app is ready to
/// use with no setup at all.
class AppSettings extends ChangeNotifier {
  AppSettings({File? file}) : _file = file;

  final File? _file;

  bool soundEffects = true;
  bool voicePrompts = false;
  bool haptics = true;
  bool reducedMotion = false;
  bool demonstrations = true;
  bool hints = true;
  bool drawingTools = true;
  bool stickers = true;
  AgeMode ageMode = AgeMode.creativeExplorer;
  BrushSize defaultBrushSize = BrushSize.medium;

  /// Whether the one-time "pick a colour, drop it on the picture" demo ran.
  bool demoSeen = false;

  static Future<AppSettings> load(File file) async {
    final settings = AppSettings(file: file);
    try {
      if (await file.exists()) settings._apply(jsonDecode(await file.readAsString()) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Settings unreadable, using defaults: $e');
    }
    return settings;
  }

  void _apply(Map<String, dynamic> j) {
    soundEffects = j['soundEffects'] as bool? ?? soundEffects;
    voicePrompts = j['voicePrompts'] as bool? ?? voicePrompts;
    haptics = j['haptics'] as bool? ?? haptics;
    reducedMotion = j['reducedMotion'] as bool? ?? reducedMotion;
    demonstrations = j['demonstrations'] as bool? ?? demonstrations;
    hints = j['hints'] as bool? ?? hints;
    drawingTools = j['drawingTools'] as bool? ?? drawingTools;
    stickers = j['stickers'] as bool? ?? stickers;
    ageMode = AgeMode.values.firstWhere((m) => m.name == j['ageMode'], orElse: () => ageMode);
    defaultBrushSize = BrushSize.fromName(j['defaultBrushSize'] as String?);
    demoSeen = j['demoSeen'] as bool? ?? demoSeen;
  }

  Map<String, Object?> toJson() => {
    'soundEffects': soundEffects,
    'voicePrompts': voicePrompts,
    'haptics': haptics,
    'reducedMotion': reducedMotion,
    'demonstrations': demonstrations,
    'hints': hints,
    'drawingTools': drawingTools,
    'stickers': stickers,
    'ageMode': ageMode.name,
    'defaultBrushSize': defaultBrushSize.name,
    'demoSeen': demoSeen,
  };

  bool get isLittle => ageMode == AgeMode.littleArtist;

  /// Applies a change, notifies listeners and persists.
  void update(void Function(AppSettings s) change) {
    change(this);
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final file = _file;
    if (file == null) return;
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(toJson()));
    } catch (e) {
      debugPrint('Could not save settings: $e');
    }
  }
}
