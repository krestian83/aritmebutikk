import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'audio_state.dart';

/// Service for playing game sound effects.
///
/// Uses bundled MP3 assets via [AssetSource] for offline playback.
/// Each sound type has its own [AudioPlayer] for overlap-free
/// re-triggering.
class SoundService {
  SoundService._();
  static final instance = SoundService._();

  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _levelUpPlayer = AudioPlayer();
  final AudioPlayer _warningPlayer = AudioPlayer();
  final AudioPlayer _pressPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  bool _initialized = false;

  void _init() {
    if (_initialized) return;
    _initialized = true;

    _wrongPlayer.setReleaseMode(ReleaseMode.stop);
    _levelUpPlayer.setReleaseMode(ReleaseMode.stop);
    _warningPlayer.setReleaseMode(ReleaseMode.stop);
    _pressPlayer.setReleaseMode(ReleaseMode.stop);
    _successPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Plays a named sound effect with optional haptic feedback.
  Future<void> play(String name) async {
    if (!AudioState.instance.soundEnabled) return;
    _init();
    switch (name) {
      case 'wrong':
        await _playWrong();
      case 'levelup':
        await _playLevelUp();
      case 'warning':
        await _playWarning();
      case 'press':
        await _playPress();
      case 'success':
        await _playSuccess();
    }
  }

  Future<void> _playWrong() async {
    if (!kIsWeb) HapticFeedback.vibrate();
    try {
      _wrongPlayer.stop();
      _wrongPlayer.play(
        AssetSource('audio/wrong.mp3'),
        volume: 0.3 * AudioState.masterVolume,
      );
    } catch (_) {}
  }

  Future<void> _playLevelUp() async {
    if (!kIsWeb) {
      HapticFeedback.heavyImpact();
      Future.delayed(
        const Duration(milliseconds: 150),
        () => HapticFeedback.heavyImpact(),
      );
      Future.delayed(
        const Duration(milliseconds: 300),
        () => HapticFeedback.heavyImpact(),
      );
    }
    try {
      _levelUpPlayer.stop();
      _levelUpPlayer.play(
        AssetSource('audio/levelup.mp3'),
        volume: 0.6 * AudioState.masterVolume,
      );
    } catch (_) {}
  }

  Future<void> _playWarning() async {
    try {
      _warningPlayer.stop();
      _warningPlayer.play(
        AssetSource('audio/warning.mp3'),
        volume: 0.3 * AudioState.masterVolume,
      );
    } catch (_) {}
  }

  Future<void> _playPress() async {
    if (!kIsWeb) HapticFeedback.lightImpact();
    try {
      _pressPlayer.stop();
      _pressPlayer.play(
        AssetSource('audio/press.mp3'),
        volume: 0.2 * AudioState.masterVolume,
      );
    } catch (_) {}
  }

  Future<void> _playSuccess() async {
    if (!kIsWeb) HapticFeedback.mediumImpact();
    try {
      _successPlayer.stop();
      _successPlayer.play(
        AssetSource('audio/success.mp3'),
        volume: 0.7 * AudioState.masterVolume,
      );
    } catch (_) {}
  }

  void dispose() {
    _wrongPlayer.dispose();
    _levelUpPlayer.dispose();
    _warningPlayer.dispose();
    _pressPlayer.dispose();
    _successPlayer.dispose();
  }
}
