import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'app_settings.dart';

enum Sfx {
  tap('sounds/tap.wav'),
  fill('sounds/fill.wav'),
  brush('sounds/brush.wav'),
  chime('sounds/chime.wav'),
  pop('sounds/pop.wav');

  const Sfx(this.asset);

  final String asset;
}

/// Quiet sound effects, haptics and optional spoken prompts.
///
/// Every call respects the parent settings and swallows platform errors:
/// audio is a nicety and must never break coloring.
class SoundService {
  SoundService(this.settings, {this.enabled = true});

  /// A silent instance for tests.
  SoundService.silent(this.settings) : enabled = false;

  final AppSettings settings;
  final bool enabled;
  final Map<Sfx, AudioPlayer> _players = {};
  FlutterTts? _tts;

  Future<void> play(Sfx sfx) async {
    if (!enabled || !settings.soundEffects) return;
    try {
      final player = _players[sfx] ??= AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
      await player.stop();
      await player.setVolume(sfx == Sfx.brush ? 0.25 : 0.55);
      await player.play(AssetSource(sfx.asset));
    } catch (e) {
      debugPrint('Sound unavailable: $e');
    }
  }

  void haptic() {
    if (!enabled || !settings.haptics) return;
    HapticFeedback.selectionClick();
  }

  Future<void> say(String text) async {
    if (!enabled || !settings.voicePrompts) return;
    try {
      final tts = _tts ??= FlutterTts();
      await tts.setSpeechRate(0.45);
      await tts.setPitch(1.1);
      await tts.stop();
      await tts.speak(text);
    } catch (e) {
      debugPrint('Speech unavailable: $e');
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _tts?.stop();
  }
}
