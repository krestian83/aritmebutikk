import 'dart:convert';

/// A single high score entry.
class HighScoreEntry {
  final String name;
  final int score;
  final Duration timePlayed;
  final DateTime date;

  const HighScoreEntry({
    required this.name,
    required this.score,
    required this.timePlayed,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
    'timePlayedMs': timePlayed.inMilliseconds,
    'date': date.toIso8601String(),
  };

  factory HighScoreEntry.fromJson(Map<String, dynamic> json) {
    return HighScoreEntry(
      name: json['name'] as String,
      score: json['score'] as int,
      timePlayed: Duration(milliseconds: json['timePlayedMs'] as int),
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Formats [timePlayed] as MM:SS.
  String get formattedTime {
    final minutes = timePlayed.inMinutes;
    final seconds = timePlayed.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats [date] as dd.MM.yyyy.
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  static String encodeList(List<HighScoreEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }

  static List<HighScoreEntry> decodeList(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => HighScoreEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
