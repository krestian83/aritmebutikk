import 'dart:convert';

/// En vare tilgjengelig for kjop i butikken.
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

  static const List<StoreItem> defaults = [
    StoreItem(
      id: 'default_0',
      name: '15 min skjermtid',
      icon: '\uD83D\uDCF1',
      cost: 1000,
      category: 'Skjermtid',
    ),
    StoreItem(
      id: 'default_1',
      name: '30 min skjermtid',
      icon: '\uD83D\uDCF1',
      cost: 1800,
      category: 'Skjermtid',
    ),
    StoreItem(
      id: 'default_2',
      name: '1 time skjermtid',
      icon: '\uD83D\uDCBB',
      cost: 3000,
      category: 'Skjermtid',
    ),
    StoreItem(
      id: 'default_3',
      name: '10 kr',
      icon: '\uD83D\uDCB0',
      cost: 2000,
      category: 'Penger',
    ),
    StoreItem(
      id: 'default_4',
      name: '20 kr',
      icon: '\uD83D\uDCB0',
      cost: 3500,
      category: 'Penger',
    ),
    StoreItem(
      id: 'default_5',
      name: '50 kr',
      icon: '\uD83D\uDCB5',
      cost: 8000,
      category: 'Penger',
    ),
  ];
}
