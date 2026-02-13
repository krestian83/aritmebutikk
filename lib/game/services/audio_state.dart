import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Three-state audio mode controlling sound and music.
///
/// | Mode        | Sound | Music | Haptics |
/// |-------------|-------|-------|---------|
/// | `soundOnly` | ON    | OFF   | ON      |
/// | `all`       | ON    | ON    | ON      |
/// | `muted`     | OFF   | OFF   | ON      |
enum AudioMode { soundOnly, all, muted }

/// Global audio state shared across the app.
///
/// Persists the user's mode preference via SharedPreferences.
/// Call [load] once at startup to restore the saved preference.
class AudioState {
  AudioState._();
  static final instance = AudioState._();
  static const _key = 'audio_mode';

  /// Master volume multiplier applied to all audio (0.0 – 1.0).
  static const double masterVolume = 0.49;

  final notifier = ValueNotifier<AudioMode>(AudioMode.soundOnly);

  AudioMode get mode => notifier.value;

  bool get soundEnabled => mode != AudioMode.muted;
  bool get musicEnabled => mode == AudioMode.all;

  /// Reads the stored audio mode from disk.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == null) return;
    for (final m in AudioMode.values) {
      if (m.name == stored) {
        notifier.value = m;
        return;
      }
    }
  }

  /// Cycles: soundOnly → all → muted → soundOnly.
  void cycle() {
    notifier.value = switch (mode) {
      AudioMode.soundOnly => AudioMode.all,
      AudioMode.all => AudioMode.muted,
      AudioMode.muted => AudioMode.soundOnly,
    };
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
