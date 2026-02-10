import 'package:flutter/foundation.dart';

/// Manages score, streak, and scoring logic.
class ScoringSystem {
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> streak = ValueNotifier(0);

  static const int _basePoints = 10;

  /// Awards points for a correct answer.
  /// [difficultyMultiplier]: 1 for easy, 2 for medium, 3 for hard.
  /// Returns the points earned.
  int awardCorrect({int difficultyMultiplier = 1}) {
    streak.value++;
    // 10% bonus per streak level, capped at 2x base.
    final streakBonus = 1.0 + (streak.value - 1) * 0.1;
    final base = _basePoints * difficultyMultiplier;
    final maxPoints = base * 2;
    final points = (base * streakBonus).round().clamp(0, maxPoints);
    score.value += points;
    return points;
  }

  /// Penalises a wrong answer: subtracts half of what a correct
  /// answer would have been worth. Score cannot go below 0.
  /// Returns the penalty (positive number).
  int recordWrong({int difficultyMultiplier = 1}) {
    final wouldHaveEarned = awardWouldBe(
      difficultyMultiplier: difficultyMultiplier,
    );
    final penalty = (wouldHaveEarned / 2).round();
    score.value = (score.value - penalty).clamp(0, score.value);
    streak.value = 0;
    return penalty;
  }

  /// What a correct answer would earn right now (without
  /// awarding it).
  int awardWouldBe({int difficultyMultiplier = 1}) {
    final streakBonus = 1.0 + (streak.value) * 0.1;
    final base = _basePoints * difficultyMultiplier;
    final maxPoints = base * 2;
    return (base * streakBonus).round().clamp(0, maxPoints);
  }

  /// Whether the player has earned a time bonus (5+ streak).
  bool get hasTimeBonus => streak.value >= 5 && streak.value % 5 == 0;

  /// Resets all scoring state.
  void reset() {
    score.value = 0;
    streak.value = 0;
  }

  void dispose() {
    score.dispose();
    streak.dispose();
  }
}
