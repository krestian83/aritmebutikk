import 'dart:convert';

/// A single purchase in the ledger.
class LedgerEntry {
  final String playerName;
  final String itemName;
  final int creditsCost;
  final DateTime date;

  const LedgerEntry({
    required this.playerName,
    required this.itemName,
    required this.creditsCost,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'itemName': itemName,
    'creditsCost': creditsCost,
    'date': date.toIso8601String(),
  };

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      playerName: json['playerName'] as String,
      itemName: json['itemName'] as String,
      creditsCost: json['creditsCost'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  static String encodeList(List<LedgerEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }

  static List<LedgerEntry> decodeList(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
