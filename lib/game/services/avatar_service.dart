import 'package:fluttermoji/fluttermojiController.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-player fluttermoji configurations.
///
/// Fluttermoji uses global SharedPreferences keys internally.
/// This service namespaces them per player name so each player
/// keeps their own avatar.
class AvatarService {
  static const _keyPrefix = 'fluttermoji_player_';
  static String? _currentPlayer;

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
}
