import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
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
  final AudioPlayer _pressPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  bool _initialized = false;

  void _init() {
    if (_initialized) return;
    _initialized = true;

    _wrongPlayer.setReleaseMode(ReleaseMode.stop);
    _levelUpPlayer.setReleaseMode(ReleaseMode.stop);
    _pressPlayer.setReleaseMode(ReleaseMode.stop);
    _successPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Plays a named sound effect with optional haptic feedback.
  ///
  /// Haptics always fire regardless of mute state.
  Future<void> play(String name) async {
    _fireHaptic(name);
    if (!AudioState.instance.soundEnabled) return;
    _init();
    switch (name) {
      case 'wrong':
        await _playWrong();
      case 'levelup':
        await _playLevelUp();
      case 'press':
        await _playPress();
      case 'success':
        await _playSuccess();
    }
  }

  void _fireHaptic(String name) {
    if (kIsWeb) return;
    switch (name) {
      case 'wrong':
        HapticFeedback.vibrate();
      case 'levelup':
        HapticFeedback.heavyImpact();
        Future.delayed(
          const Duration(milliseconds: 150),
          () => HapticFeedback.heavyImpact(),
        );
        Future.delayed(
          const Duration(milliseconds: 300),
          () => HapticFeedback.heavyImpact(),
        );
      case 'press':
        HapticFeedback.lightImpact();
      case 'success':
        HapticFeedback.mediumImpact();
    }
  }

  Future<void> _playWrong() async {
    try {
      await _wrongPlayer.stop();
      _wrongPlayer.play(
        AssetSource('audio/wrong.mp3'),
        volume: 0.3 * AudioState.masterVolume,
      );
    } catch (e) {
      debugPrint('[SFX] wrong error: $e');
    }
  }

  Future<void> _playLevelUp() async {
    try {
      await _levelUpPlayer.stop();
      _levelUpPlayer.play(
        AssetSource('audio/levelup.mp3'),
        volume: 0.6 * AudioState.masterVolume,
      );
    } catch (e) {
      debugPrint('[SFX] levelup error: $e');
    }
  }

  Future<void> _playPress() async {
    try {
      await _pressPlayer.stop();
      _pressPlayer.play(
        AssetSource('audio/press.mp3'),
        volume: 0.16 * AudioState.masterVolume,
      );
    } catch (e) {
      debugPrint('[SFX] press error: $e');
    }
  }

  Future<void> _playSuccess() async {
    try {
      await _successPlayer.stop();
      _successPlayer.play(
        AssetSource('audio/success.mp3'),
        volume: 0.476 * AudioState.masterVolume,
      );
    } catch (e) {
      debugPrint('[SFX] success error: $e');
    }
  }

  /// Stops all SFX players so nothing replays on app resume.
  void stopAll() {
    try {
      _wrongPlayer.stop();
      _levelUpPlayer.stop();
      _pressPlayer.stop();
      _successPlayer.stop();
    } catch (_) {}
  }

  void dispose() {
    _wrongPlayer.dispose();
    _levelUpPlayer.dispose();
    _pressPlayer.dispose();
    _successPlayer.dispose();
  }
}
