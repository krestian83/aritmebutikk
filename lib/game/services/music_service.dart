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
    'music/study_time_fun.mp3',
    'music/lofi_study_flow_1.mp3',
    'music/lofi_study_flow_2.mp3',
  ];

  static final double _volume = 0.15 * AudioState.masterVolume;

  final _random = Random();
  AudioPlayer? _player;
  bool _playing = false;
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

  /// Starts playback with a random track. Creates the player
  /// lazily so the browser audio context is born inside a user
  /// gesture.
  Future<void> start() async {
    if (_playing) return;
    _playing = true;
    try {
      _player ??= AudioPlayer()
        ..onPlayerComplete.listen((_) => _onTrackComplete());
      _currentIndex = _nextTrackIndex();
      await _player!.setReleaseMode(ReleaseMode.stop);
      await _player!.play(AssetSource(_tracks[_currentIndex]));
      await _player!.setVolume(_volume);
      debugPrint('[Music] playing track $_currentIndex');
    } catch (e) {
      _playing = false;
      debugPrint('[Music] error: $e');
    }
  }

  void _onTrackComplete() {
    if (!_playing) return;
    _currentIndex = _nextTrackIndex();
    _playTrack(_currentIndex);
  }

  Future<void> _playTrack(int index) async {
    try {
      await _player!.play(AssetSource(_tracks[index]));
      await _player!.setVolume(_volume);
      debugPrint('[Music] next track $index');
    } catch (e) {
      _playing = false;
      debugPrint('[Music] error on next track: $e');
    }
  }

  /// Resumes a paused track if music is still enabled.
  Future<void> resume() async {
    if (!AudioState.instance.musicEnabled) return;
    if (_player == null) return;
    if (_playing) return;
    _playing = true;
    try {
      await _player!.resume();
      debugPrint('[Music] resumed track $_currentIndex');
    } catch (e) {
      _playing = false;
      debugPrint('[Music] resume error: $e');
    }
  }

  /// Pauses the music.
  Future<void> stop() async {
    _playing = false;
    try {
      await _player?.pause();
    } catch (_) {}
  }

  /// Starts or stops music based on the current audio mode.
  void applyMuteState() {
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
