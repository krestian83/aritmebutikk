import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'avatar_service.dart';
import 'credit_service.dart';

/// Manages the list of player profiles stored in SharedPreferences.
class ProfileService {
  static const _key = 'player_profiles';

  /// Returns all saved profile names.
  Future<List<String>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null || json.isEmpty) return [];
    try {
      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded.cast<String>();
    } catch (_) {
      return [];
    }
  }

  /// Adds [name] to the profile list.
  /// Returns `false` if a profile with the same name already exists.
  Future<bool> addProfile(String name) async {
    final profiles = await loadProfiles();
    final lower = name.toLowerCase();
    if (profiles.any((p) => p.toLowerCase() == lower)) return false;

    profiles.add(name);
    await _save(profiles);
    return true;
  }

  /// Removes [name] from the profile list and cleans up
  /// associated credit and avatar data.
  Future<void> deleteProfile(String name) async {
    final profiles = await loadProfiles();
    profiles.removeWhere((p) => p.toLowerCase() == name.toLowerCase());
    await _save(profiles);

    await CreditService().deletePlayerData(name);
    await AvatarService().deletePlayerData(name);
  }

  Future<void> _save(List<String> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profiles));
  }
}
