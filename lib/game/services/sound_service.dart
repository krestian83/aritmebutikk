import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Service for playing game sound effects.
///
/// Uses bundled MP3 assets via [AssetSource] for offline playback.
/// Each sound type has its own [AudioPlayer] for overlap-free
/// re-triggering.
class SoundService {
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _tapPlayer = AudioPlayer();
  final AudioPlayer _levelUpPlayer = AudioPlayer();
  final AudioPlayer _warningPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;

    await _correctPlayer.setReleaseMode(ReleaseMode.stop);
    await _wrongPlayer.setReleaseMode(ReleaseMode.stop);
    await _tapPlayer.setReleaseMode(ReleaseMode.stop);
    await _levelUpPlayer.setReleaseMode(ReleaseMode.stop);
    await _warningPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Plays a named sound effect with optional haptic feedback.
  Future<void> play(String name) async {
    await _init();
    switch (name) {
      case 'correct':
        await _playCorrect();
      case 'wrong':
        await _playWrong();
      case 'tap':
        await _playTap();
      case 'levelup':
        await _playLevelUp();
      case 'warning':
        await _playWarning();
    }
  }

  Future<void> _playCorrect() async {
    if (!kIsWeb) HapticFeedback.mediumImpact();
    try {
      _correctPlayer.stop();
      _correctPlayer.play(
        AssetSource('audio/correct.mp3'),
        volume: 0.7,
      );
    } catch (_) {}
  }

  Future<void> _playWrong() async {
    if (!kIsWeb) HapticFeedback.vibrate();
    try {
      _wrongPlayer.stop();
      _wrongPlayer.play(
        AssetSource('audio/wrong.mp3'),
        volume: 0.3,
      );
    } catch (_) {}
  }

  Future<void> _playTap() async {
    if (!kIsWeb) HapticFeedback.lightImpact();
    try {
      _tapPlayer.stop();
      _tapPlayer.play(
        AssetSource('audio/tap.mp3'),
        volume: 0.5,
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
        volume: 0.6,
      );
    } catch (_) {}
  }

  Future<void> _playWarning() async {
    try {
      _warningPlayer.stop();
      _warningPlayer.play(
        AssetSource('audio/warning.mp3'),
        volume: 0.3,
      );
    } catch (_) {}
  }

  void dispose() {
    _correctPlayer.dispose();
    _wrongPlayer.dispose();
    _tapPlayer.dispose();
    _levelUpPlayer.dispose();
    _warningPlayer.dispose();
  }
}
