import 'package:shared_preferences/shared_preferences.dart';

import '../models/store_item.dart';

/// CRUD service for store items and parent PIN management.
class StoreItemService {
  StoreItemService._();
  static final instance = StoreItemService._();

  static const _itemsKey = 'store_items';
  static const _pinKey = 'parent_pin';

  // -- Items -------------------------------------------------------

  /// Returns saved items, or [StoreItem.defaults] on first launch.
  Future<List<StoreItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_itemsKey);
    if (json == null || json.isEmpty) {
      return List.of(StoreItem.defaults);
    }
    try {
      return StoreItem.decodeList(json);
    } catch (_) {
      return List.of(StoreItem.defaults);
    }
  }

  /// Full replace of the item list.
  Future<void> saveItems(List<StoreItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemsKey, StoreItem.encodeList(items));
  }

  /// Appends a new item with a generated id.
  Future<void> addItem({
    required String name,
    required String icon,
    required int cost,
    required String category,
  }) async {
    final items = await loadItems();
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    items.add(
      StoreItem(id: id, name: name, icon: icon, cost: cost, category: category),
    );
    await saveItems(items);
  }

  /// Replaces the item with matching [id].
  Future<void> updateItem(StoreItem updated) async {
    final items = await loadItems();
    final index = items.indexWhere((i) => i.id == updated.id);
    if (index == -1) return;
    items[index] = updated;
    await saveItems(items);
  }

  /// Removes the item with the given [id].
  Future<void> deleteItem(String id) async {
    final items = await loadItems();
    items.removeWhere((i) => i.id == id);
    await saveItems(items);
  }

  // -- PIN ---------------------------------------------------------

  /// Whether a parent PIN has been set.
  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinKey);
    return pin != null && pin.isNotEmpty;
  }

  /// Returns true if [pin] matches the stored PIN.
  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) == pin;
  }

  /// Stores a new PIN (4 digits).
  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }
}
