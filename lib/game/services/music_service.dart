import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'audio_state.dart';

/// Plays background music, picking a random track each time
/// and advancing to a new random track when one finishes.
class MusicService {
  MusicService._();
  static final instance = MusicService._();

  static const _tracks = [
    'music/Study_Time_Fun_2026-02-07T220130.mp3',
    'music/Lofi_Study_Flow_2026-02-10T152947.mp3',
    'music/Lofi_Study_Flow_2026-02-10T153428.mp3',
  ];

  final _random = Random();
  AudioPlayer? _player;
  bool _playing = false;
  bool _started = false;
  int _currentIndex = -1;

  /// Picks a random track index different from the current one
  /// (when more than one track exists).
  int _nextTrackIndex() {
    if (_tracks.length <= 1) return 0;
    int next;
    do {
      next = _random.nextInt(_tracks.length);
    } while (next == _currentIndex);
    return next;
  }

  /// Starts playback. Creates the player on first call so the
  /// browser audio context is born inside a user gesture.
  Future<void> start() async {
    _started = true;
    if (!AudioState.instance.musicEnabled) return;
    if (_playing) return;
    _playing = true;
    try {
      _player ??= AudioPlayer()
        ..onPlayerComplete.listen((_) => _onTrackComplete());
      _currentIndex = _nextTrackIndex();
      await _player!.setReleaseMode(ReleaseMode.release);
      await _player!.play(AssetSource(_tracks[_currentIndex]));
      final vol = 0.15 * AudioState.masterVolume;
      await _player!.setVolume(vol);
      debugPrint('[Music] playing track $_currentIndex at volume $vol');
    } catch (e) {
      _playing = false;
      debugPrint('[Music] error: $e');
    }
  }

  void _onTrackComplete() {
    if (!_playing) return;
    _currentIndex = _nextTrackIndex();
    try {
      _player!.play(AssetSource(_tracks[_currentIndex]));
      debugPrint('[Music] next track $_currentIndex');
    } catch (e) {
      debugPrint('[Music] error on next track: $e');
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
