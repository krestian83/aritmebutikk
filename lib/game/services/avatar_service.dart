import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-player emoji avatar selections.
class AvatarService {
  AvatarService._();
  static final instance = AvatarService._();

  static const defaultEmoji = '\u{1F9D2}';
  static const _keyPrefix = 'emoji_avatar_';

  /// Returns the stored emoji for [playerName], or [defaultEmoji].
  Future<String> getEmoji(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefix$playerName') ?? defaultEmoji;
  }

  /// Stores [emoji] for [playerName].
  Future<void> saveEmoji(String playerName, String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$playerName', emoji);
  }

  /// Returns `true` if [playerName] has a custom emoji saved.
  Future<bool> hasAvatar(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_keyPrefix$playerName');
  }

  /// Removes stored avatar data for [playerName].
  Future<void> deletePlayerData(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$playerName');
  }
}
