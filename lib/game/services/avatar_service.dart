import 'dart:async';

import 'package:fluttermoji/fluttermojiController.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-player fluttermoji configurations.
///
/// Fluttermoji uses global SharedPreferences keys internally.
/// This service namespaces them per player name so each player
/// keeps their own avatar.
class AvatarService {
  AvatarService._();
  static final instance = AvatarService._();

  static const _keyPrefix = 'fluttermoji_player_';
  static String? _currentPlayer;

  /// Serialises access to the global fluttermoji options so
  /// concurrent [getAvatarSvg] calls don't corrupt state.
  Future<void>? _svgLock;

  /// The currently loaded player name, if any.
  static String? get currentPlayer => _currentPlayer;

  /// Returns `true` if [playerName] has a saved avatar.
  Future<bool> hasAvatar(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_keyPrefix$playerName');
  }

  /// Load [playerName]'s avatar into the global fluttermoji
  /// controller. No-op if already loaded for this player.
  Future<void> loadPlayer(String playerName) async {
    if (_currentPlayer == playerName) return;
    _currentPlayer = playerName;

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('$_keyPrefix$playerName');

    if (saved != null) {
      await prefs.setString('fluttermojiSelectedOptions', saved);
    } else {
      await prefs.remove('fluttermojiSelectedOptions');
      await prefs.remove('fluttermoji');
    }

    if (!Get.isRegistered<FluttermojiController>()) {
      Get.put(FluttermojiController());
      return;
    }

    final controller = Get.find<FluttermojiController>();
    final options = await controller.getFluttermojiOptions();
    controller.selectedOptions = Map<String, dynamic>.from(options);
    controller.fluttermoji.value = controller.getFluttermojiFromOptions();
  }

  /// Save current controller state for [playerName].
  Future<void> savePlayer(String playerName) async {
    if (Get.isRegistered<FluttermojiController>()) {
      final controller = Get.find<FluttermojiController>();
      await controller.setFluttermoji();
    }

    final prefs = await SharedPreferences.getInstance();
    final options = prefs.getString('fluttermojiSelectedOptions');
    if (options != null) {
      await prefs.setString('$_keyPrefix$playerName', options);
    }
  }

  /// Force reload even if same player (after editor changes).
  Future<void> refreshPlayer(String playerName) async {
    _currentPlayer = null;
    await loadPlayer(playerName);
  }

  /// Removes stored avatar data for [playerName].
  Future<void> deletePlayerData(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$playerName');

    if (_currentPlayer == playerName) {
      _currentPlayer = null;
    }
  }

  /// Returns the SVG string for [playerName]'s avatar without
  /// switching the global controller. Returns `null` if no
  /// saved data exists.
  ///
  /// Uses a simple lock so concurrent calls don't corrupt the
  /// shared global fluttermoji options.
  Future<String?> getAvatarSvg(String playerName) async {
    // Wait for any in-flight call to finish first.
    while (_svgLock != null) {
      await _svgLock;
    }

    final completer = Completer<void>();
    _svgLock = completer.future;

    try {
      return await _getAvatarSvgUnsafe(playerName);
    } finally {
      completer.complete();
      _svgLock = null;
    }
  }

  Future<String?> _getAvatarSvgUnsafe(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('$_keyPrefix$playerName');
    if (saved == null) return null;

    // Temporarily set global options to render this player's SVG.
    final original = prefs.getString('fluttermojiSelectedOptions');
    await prefs.setString('fluttermojiSelectedOptions', saved);

    if (!Get.isRegistered<FluttermojiController>()) {
      Get.put(FluttermojiController());
    }
    final controller = Get.find<FluttermojiController>();
    final options = await controller.getFluttermojiOptions();
    controller.selectedOptions = Map<String, dynamic>.from(options);
    final svg = controller.getFluttermojiFromOptions();

    // Restore original options.
    if (original != null) {
      await prefs.setString('fluttermojiSelectedOptions', original);
    } else {
      await prefs.remove('fluttermojiSelectedOptions');
    }

    return svg;
  }
}
