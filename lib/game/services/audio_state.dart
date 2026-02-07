import 'package:flutter/foundation.dart';

/// Three-state audio mute: all on, music off, everything off.
enum MuteMode { allOn, musicOff, allOff }

/// Global audio mute state shared across the app.
class AudioState {
  AudioState._();
  static final instance = AudioState._();

  final notifier = ValueNotifier<MuteMode>(MuteMode.allOn);

  MuteMode get mode => notifier.value;

  bool get musicEnabled => mode == MuteMode.allOn;
  bool get soundEnabled => mode != MuteMode.allOff;

  /// Cycles to the next mute mode.
  void cycle() {
    notifier.value = switch (mode) {
      MuteMode.allOn => MuteMode.musicOff,
      MuteMode.musicOff => MuteMode.allOff,
      MuteMode.allOff => MuteMode.allOn,
    };
  }
}
