import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_category.dart';
import '../models/ledger_entry.dart';

/// Persists per-player credit balances, per-category earned
/// totals, and the purchase ledger.
class CreditService {
  static const _balancesKey = 'credit_balances';
  static const _ledgerKey = 'credit_ledger';
  static const _categoryKey = 'category_earned';
  static const _lastResetKey = 'category_last_reset';

  /// Hour of the day (0-23) when category progress resets.
  static const resetHour = 22; // TODO: change to 0 for midnight

  // ── Daily reset ──────────────────────────────────────────

  /// Resets all category earned totals if the reset hour has
  /// passed since the last reset. Call once on app/screen load.
  Future<void> resetCategoriesIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString(_lastResetKey);

    final now = DateTime.now();
    // The most recent reset boundary: today at resetHour,
    // or yesterday at resetHour if we haven't reached it yet.
    var boundary = DateTime(now.year, now.month, now.day, resetHour);
    if (now.isBefore(boundary)) {
      boundary = boundary.subtract(const Duration(days: 1));
    }

    if (lastReset != null) {
      final lastResetDate = DateTime.tryParse(lastReset);
      if (lastResetDate != null && !lastResetDate.isBefore(boundary)) {
        return; // Already reset for this period.
      }
    }

    // Clear all category progress.
    await prefs.remove(_categoryKey);
    await prefs.setString(_lastResetKey, now.toIso8601String());
  }

  // ── Balance ───────────────────────────────────────────────

  Future<int> getBalance(String playerName) async {
    final balances = await _loadMap(_balancesKey);
    return balances[playerName] ?? 0;
  }

  /// Adds [amount] credits capped by [category] limit.
  /// Returns the actual amount added (may be less than [amount]).
  Future<int> addCredits(
    String playerName,
    int amount,
    GameCategory category,
  ) async {
    final earned = await getCategoryEarned(playerName, category);
    final remaining = category.maxCredits - earned;
    if (remaining <= 0) return 0;

    final actual = amount.clamp(0, remaining);

    final balances = await _loadMap(_balancesKey);
    balances[playerName] = (balances[playerName] ?? 0) + actual;
    await _saveMap(_balancesKey, balances);

    await _addCategoryEarned(playerName, category, actual);
    return actual;
  }

  Future<bool> spend(String playerName, int amount, String itemName) async {
    final balances = await _loadMap(_balancesKey);
    final current = balances[playerName] ?? 0;
    if (current < amount) return false;

    balances[playerName] = current - amount;
    await _saveMap(_balancesKey, balances);

    final ledger = await loadLedger();
    ledger.insert(
      0,
      LedgerEntry(
        playerName: playerName,
        itemName: itemName,
        creditsCost: amount,
        date: DateTime.now(),
      ),
    );
    await _saveLedger(ledger);
    return true;
  }

  // ── Category caps ─────────────────────────────────────────

  /// How many credits [playerName] has already earned in
  /// [category].
  Future<int> getCategoryEarned(
    String playerName,
    GameCategory category,
  ) async {
    final map = await _loadCategoryMap();
    final playerMap = map[playerName];
    if (playerMap == null) return 0;
    return playerMap[category.key] ?? 0;
  }

  /// Returns a map of category -> earned for [playerName].
  Future<Map<GameCategory, int>> getAllCategoryEarned(String playerName) async {
    final map = await _loadCategoryMap();
    final playerMap = map[playerName] ?? {};
    return {
      for (final cat in GameCategory.values) cat: playerMap[cat.key] ?? 0,
    };
  }

  Future<void> _addCategoryEarned(
    String playerName,
    GameCategory category,
    int amount,
  ) async {
    final map = await _loadCategoryMap();
    final playerMap = map[playerName] ?? {};
    playerMap[category.key] = (playerMap[category.key] ?? 0) + amount;
    map[playerName] = playerMap;
    await _saveCategoryMap(map);
  }

  // ── Ledger ────────────────────────────────────────────────

  Future<List<LedgerEntry>> loadLedger() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_ledgerKey);
    if (json == null || json.isEmpty) return [];
    try {
      return LedgerEntry.decodeList(json);
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLedger(List<LedgerEntry> ledger) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ledgerKey, LedgerEntry.encodeList(ledger));
  }

  // ── Generic map helpers ───────────────────────────────────

  Future<Map<String, int>> _loadMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);
    if (json == null || json.isEmpty) return {};
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveMap(String key, Map<String, int> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(map));
  }

  Future<Map<String, Map<String, int>>> _loadCategoryMap() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_categoryKey);
    if (json == null || json.isEmpty) return {};
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(
          k,
          (v as Map<String, dynamic>).map((ck, cv) => MapEntry(ck, cv as int)),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveCategoryMap(Map<String, Map<String, int>> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoryKey, jsonEncode(map));
  }

  // ── Cleanup ────────────────────────────────────────────────

  /// Removes all stored data for [playerName]: balance,
  /// category earned totals, and ledger entries.
  Future<void> deletePlayerData(String playerName) async {
    final balances = await _loadMap(_balancesKey);
    balances.remove(playerName);
    await _saveMap(_balancesKey, balances);

    final catMap = await _loadCategoryMap();
    catMap.remove(playerName);
    await _saveCategoryMap(catMap);

    final ledger = await loadLedger();
    ledger.removeWhere((e) => e.playerName == playerName);
    await _saveLedger(ledger);
  }
}
