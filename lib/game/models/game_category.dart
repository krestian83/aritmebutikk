import '../../app/l10n/strings.dart';
import '../config/level_config.dart';

/// The four arithmetic categories.
enum GameCategory {
  addition,
  subtraction,
  multiplication,
  division;

  String get label => switch (this) {
    addition => S.current.addition,
    subtraction => S.current.subtraction,
    multiplication => S.current.multiplication,
    division => S.current.division,
  };

  String get icon => switch (this) {
    addition => '\u2795',
    subtraction => '\u2796',
    multiplication => '\u2716',
    division => '\u2797',
  };

  /// Maximum credits earnable in this category.
  int get maxCredits => switch (this) {
    addition => 2000,
    subtraction => 4000,
    multiplication => 6000,
    division => 8000,
  };

  /// The persistence key used for tracking earned credits.
  String get key => name;
}

/// Difficulty within a category.
enum Difficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
    easy => S.current.easy,
    medium => S.current.medium,
    hard => S.current.hard,
  };

  /// Points multiplier: easy 1x, medium 2x, hard 3x.
  int get pointsMultiplier => switch (this) {
    easy => 1,
    medium => 2,
    hard => 3,
  };
}

/// Returns the [LevelConfig] for a given category + difficulty.
LevelConfig configFor(GameCategory category, Difficulty difficulty) {
  return switch ((category, difficulty)) {
    // ── Addition ──
    (GameCategory.addition, Difficulty.easy) => const LevelConfig(
      name: 'Addition - Easy',
      operators: ['+'],
      minOperand: 1,
      maxOperand: 10,
    ),
    (GameCategory.addition, Difficulty.medium) => const LevelConfig(
      name: 'Addition - Medium',
      operators: ['+'],
      minOperand: 11,
      maxOperand: 50,
    ),
    (GameCategory.addition, Difficulty.hard) => const LevelConfig(
      name: 'Addition - Hard',
      operators: ['+'],
      minOperand: 51,
      maxOperand: 200,
    ),
    // ── Subtraction ──
    (GameCategory.subtraction, Difficulty.easy) => const LevelConfig(
      name: 'Subtraction - Easy',
      operators: ['-'],
      minOperand: 1,
      maxOperand: 10,
    ),
    (GameCategory.subtraction, Difficulty.medium) => const LevelConfig(
      name: 'Subtraction - Medium',
      operators: ['-'],
      minOperand: 11,
      maxOperand: 50,
    ),
    (GameCategory.subtraction, Difficulty.hard) => const LevelConfig(
      name: 'Subtraction - Hard',
      operators: ['-'],
      minOperand: 51,
      maxOperand: 100,
    ),
    // ── Multiplication ──
    (GameCategory.multiplication, Difficulty.easy) => const LevelConfig(
      name: 'Multiplication - Easy',
      operators: ['\u00D7'],
      minOperand: 1,
      maxOperand: 5,
    ),
    (GameCategory.multiplication, Difficulty.medium) => const LevelConfig(
      name: 'Multiplication - Medium',
      operators: ['\u00D7'],
      minOperand: 6,
      maxOperand: 10,
    ),
    (GameCategory.multiplication, Difficulty.hard) => const LevelConfig(
      name: 'Multiplication - Hard',
      operators: ['\u00D7'],
      minOperand: 11,
      maxOperand: 15,
    ),
    // ── Division ──
    (GameCategory.division, Difficulty.easy) => const LevelConfig(
      name: 'Division - Easy',
      operators: ['\u00F7'],
      minOperand: 1,
      maxOperand: 5,
      maxDividend: 25,
    ),
    (GameCategory.division, Difficulty.medium) => const LevelConfig(
      name: 'Division - Medium',
      operators: ['\u00F7'],
      minOperand: 6,
      maxOperand: 12,
      maxDividend: 80,
    ),
    (GameCategory.division, Difficulty.hard) => const LevelConfig(
      name: 'Division - Hard',
      operators: ['\u00F7'],
      minOperand: 13,
      maxOperand: 20,
      maxDividend: 400,
    ),
  };
}
