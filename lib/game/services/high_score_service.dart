import 'package:shared_preferences/shared_preferences.dart';

import '../models/high_score_entry.dart';

/// Persists and retrieves high scores using SharedPreferences.
class HighScoreService {
  static const _key = 'high_scores';
  static const maxEntries = 20;

  /// Loads all saved high scores, sorted by score descending.
  Future<List<HighScoreEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null || json.isEmpty) return [];
    try {
      final entries = HighScoreEntry.decodeList(json);
      entries.sort((a, b) => b.score.compareTo(a.score));
      return entries;
    } catch (_) {
      return [];
    }
  }

  /// Saves a new entry and returns the updated list.
  Future<List<HighScoreEntry>> save(HighScoreEntry entry) async {
    final entries = await load();
    entries.add(entry);
    entries.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = entries.length > maxEntries
        ? entries.sublist(0, maxEntries)
        : entries;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, HighScoreEntry.encodeList(trimmed));
    return trimmed;
  }
}
