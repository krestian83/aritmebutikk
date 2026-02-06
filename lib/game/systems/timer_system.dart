import 'dart:async';

import 'package:flutter/foundation.dart';

/// Countdown timer for the game.
///
/// The timer runs continuously across questions. Correct answers
/// add small amounts of bonus time. Capped at [maxSeconds] (1 hour).
class TimerSystem {
  static const int maxSeconds = 3600;

  final ValueNotifier<int> secondsLeft = ValueNotifier(0);
  Timer? _timer;
  VoidCallback? onTimeUp;

  /// Total seconds elapsed since the game started.
  int _elapsedSeconds = 0;

  /// Total bonus seconds accumulated from correct answers.
  int _accumulatedSeconds = 0;

  /// Total elapsed play time.
  int get elapsedSeconds => _elapsedSeconds;

  /// Total bonus time earned by answering correctly.
  int get accumulatedSeconds => _accumulatedSeconds;

  bool get isWarning => secondsLeft.value <= 10;

  /// Starts the countdown with the given duration.
  void start(int seconds) {
    secondsLeft.value = seconds.clamp(0, maxSeconds);
    _elapsedSeconds = 0;
    _accumulatedSeconds = 0;
    _timer?.cancel();
    _startTicking();
  }

  void _startTicking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsLeft.value <= 0) {
        _timer?.cancel();
        onTimeUp?.call();
        return;
      }
      secondsLeft.value--;
      _elapsedSeconds++;
    });
  }

  /// Adds bonus time, capped at [maxSeconds].
  void addTime(int seconds) {
    final before = secondsLeft.value;
    secondsLeft.value = (before + seconds).clamp(0, maxSeconds);
    _accumulatedSeconds += secondsLeft.value - before;
  }

  /// Pauses the countdown.
  void pause() {
    _timer?.cancel();
  }

  /// Resumes the countdown from current value.
  void resume() {
    if (secondsLeft.value > 0) {
      _timer?.cancel();
      _startTicking();
    }
  }

  /// Resets and stops.
  void reset() {
    _timer?.cancel();
    secondsLeft.value = 0;
    _elapsedSeconds = 0;
    _accumulatedSeconds = 0;
  }

  void dispose() {
    _timer?.cancel();
    secondsLeft.dispose();
  }
}
