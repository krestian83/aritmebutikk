import 'package:flutter/foundation.dart';

/// Three-state audio mute: all on, music off, everything off.
enum MuteMode { allOn, musicOff, allOff }

/// Global audio mute state shared across the app.
class AudioState {
  AudioState._();
  static final instance = AudioState._();

  /// Master volume multiplier applied to all audio (0.0 – 1.0).
  static const double masterVolume = 0.49;

  final notifier = ValueNotifier<MuteMode>(MuteMode.musicOff);

  MuteMode get mode => notifier.value;

  bool get musicEnabled => mode == MuteMode.allOn;
  bool get soundEnabled => mode != MuteMode.allOff;

  /// Cycles: musicOff → allOn → allOff → musicOff.
  void cycle() {
    notifier.value = switch (mode) {
      MuteMode.musicOff => MuteMode.allOn,
      MuteMode.allOn => MuteMode.allOff,
      MuteMode.allOff => MuteMode.musicOff,
    };
  }
}
