import 'dart:convert';

import '../../app/l10n/strings.dart';

/// A store item available for purchase.
class StoreItem {
  final String id;
  final String name;
  final String icon;
  final int cost;
  final String category;

  const StoreItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
    required this.category,
  });

  StoreItem copyWith({
    String? id,
    String? name,
    String? icon,
    int? cost,
    String? category,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      cost: cost ?? this.cost,
      category: category ?? this.category,
    );
  }

  /// Returns a copy with locale-aware name/category for default
  /// items. Custom items are returned unchanged.
  StoreItem get localized {
    final l10n = _defaultL10n[id];
    if (l10n == null) return this;
    return copyWith(name: l10n.$1, category: l10n.$2);
  }

  static Map<String, (String, String)> get _defaultL10n => {
    'default_0': (S.current.defScreenTime15, S.current.suggCatScreenTime),
    'default_1': (S.current.defScreenTime30, S.current.suggCatScreenTime),
    'default_2': (S.current.defScreenTime60, S.current.suggCatScreenTime),
    'default_3': ('10 kr', S.current.suggCatMoney),
    'default_4': ('20 kr', S.current.suggCatMoney),
    'default_5': ('50 kr', S.current.suggCatMoney),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'cost': cost,
    'category': category,
  };

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      cost: json['cost'] as int,
      category: json['category'] as String,
    );
  }

  static String encodeList(List<StoreItem> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }

  static List<StoreItem> decodeList(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => StoreItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<StoreItem> get defaults => [
    StoreItem(
      id: 'default_0',
      name: S.current.defScreenTime15,
      icon: '\uD83D\uDCF1',
      cost: 1000,
      category: S.current.suggCatScreenTime,
    ),
    StoreItem(
      id: 'default_1',
      name: S.current.defScreenTime30,
      icon: '\uD83D\uDCF1',
      cost: 1800,
      category: S.current.suggCatScreenTime,
    ),
    StoreItem(
      id: 'default_2',
      name: S.current.defScreenTime60,
      icon: '\uD83D\uDCBB',
      cost: 3000,
      category: S.current.suggCatScreenTime,
    ),
    StoreItem(
      id: 'default_3',
      name: '10 kr',
      icon: '\uD83D\uDCB0',
      cost: 2000,
      category: S.current.suggCatMoney,
    ),
    StoreItem(
      id: 'default_4',
      name: '20 kr',
      icon: '\uD83D\uDCB0',
      cost: 3500,
      category: S.current.suggCatMoney,
    ),
    StoreItem(
      id: 'default_5',
      name: '50 kr',
      icon: '\uD83D\uDCB5',
      cost: 8000,
      category: S.current.suggCatMoney,
    ),
  ];
}
