import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'audio_state.dart';

/// Plays looping background music throughout the app.
class MusicService {
  MusicService._();
  static final instance = MusicService._();

  AudioPlayer? _player;
  bool _playing = false;
  bool _started = false;

  /// Starts playback. Creates the player on first call so the
  /// browser audio context is born inside a user gesture.
  Future<void> start() async {
    _started = true;
    if (!AudioState.instance.musicEnabled) return;
    if (_playing) return;
    _playing = true;
    try {
      _player ??= AudioPlayer();
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.play(
        AssetSource('music/Study_Time_Fun_2026-02-07T220130.mp3'),
      );
      await _player!.setVolume(0.15);
      debugPrint('[Music] playing at volume 0.15');
    } catch (e) {
      _playing = false;
      debugPrint('[Music] error: $e');
    }
  }

  /// Pauses the music. Call [start] to resume.
  Future<void> stop() async {
    _playing = false;
    try {
      await _player?.pause();
    } catch (_) {}
  }

  /// Called when mute state changes.
  void applyMuteState() {
    if (!_started) return;
    if (AudioState.instance.musicEnabled) {
      if (!_playing) start();
    } else {
      stop();
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
