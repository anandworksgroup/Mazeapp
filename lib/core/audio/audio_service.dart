import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../features/settings/game_settings.dart';

enum Sfx { buttonClick, movement, blocked, goal, success, unlock, achievement }

/// Bundled sound effects, looping music and haptics. Every call is
/// fire-and-forget: audio failing (no output device, a test run) must never
/// affect the game.
class AudioService {
  AudioService({this.enabled = true});

  /// False in widget tests, where no audio plugin exists.
  final bool enabled;

  GameSettings _settings = const GameSettings();
  final Map<Sfx, AudioPool> _pools = {};
  AudioPlayer? _music;
  bool _musicWanted = false;
  bool _appInForeground = true;

  static const _files = {
    Sfx.buttonClick: 'sounds/button_click.wav',
    Sfx.movement: 'sounds/movement.wav',
    Sfx.blocked: 'sounds/blocked.wav',
    Sfx.goal: 'sounds/goal.wav',
    Sfx.success: 'sounds/success.wav',
    Sfx.unlock: 'sounds/unlock.wav',
    Sfx.achievement: 'sounds/achievement.wav',
  };

  Future<void> init() async {
    if (!enabled) return;
    try {
      await AudioPlayer.global.setAudioContext(AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
      ).build());
    } catch (e) {
      debugPrint('audio context: $e');
    }
    for (final e in _files.entries) {
      try {
        _pools[e.key] = await AudioPool.createFromAsset(
          path: e.value,
          maxPlayers: e.key == Sfx.movement ? 4 : 2,
        );
      } catch (err) {
        debugPrint('sfx ${e.key}: $err');
      }
    }
  }

  void apply(GameSettings settings) {
    _settings = settings;
    _musicWanted = settings.music;
    _syncMusic();
  }

  void play(Sfx sfx, {double volume = 1}) {
    if (!enabled || !_settings.sound) return;
    final pool = _pools[sfx];
    if (pool == null) return;
    pool.start(volume: volume).catchError((Object e) {
      debugPrint('sfx $sfx: $e');
      return () async {};
    });
  }

  void haptic(HapticKind kind) {
    if (!_settings.vibration) return;
    if (_settings.gentleVibration) {
      HapticFeedback.selectionClick();
      return;
    }
    switch (kind) {
      case HapticKind.tick:
        HapticFeedback.selectionClick();
      case HapticKind.bump:
        HapticFeedback.lightImpact();
      case HapticKind.success:
        HapticFeedback.mediumImpact();
    }
  }

  void onAppLifecycle({required bool foreground}) {
    _appInForeground = foreground;
    _syncMusic();
  }

  Future<void> _syncMusic() async {
    if (!enabled) return;
    try {
      if (_musicWanted && _appInForeground) {
        if (_music == null) {
          final player = AudioPlayer(playerId: 'music');
          _music = player;
          await player.setReleaseMode(ReleaseMode.loop);
          await player.setVolume(0.35);
          await player.play(AssetSource('music/theme.wav'));
        } else if (_music!.state != PlayerState.playing) {
          await _music!.resume();
        }
      } else if (_music?.state == PlayerState.playing) {
        await _music!.pause();
      }
    } catch (e) {
      debugPrint('music: $e');
    }
  }
}

enum HapticKind { tick, bump, success }
