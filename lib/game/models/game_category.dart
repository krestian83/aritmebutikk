import '../config/level_config.dart';

/// The four arithmetic categories.
enum GameCategory {
  addition,
  subtraction,
  multiplication,
  division;

  String get label => switch (this) {
    addition => 'Addisjon',
    subtraction => 'Subtraksjon',
    multiplication => 'Ganging',
    division => 'Deling',
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
    easy => 'Lett',
    medium => 'Middels',
    hard => 'Vanskelig',
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
    (GameCategory.addition, Difficulty.easy) => const LevelConfig(
      level: 1,
      name: 'Addisjon - Lett',
      operators: ['+'],
      minOperand: 1,
      maxOperand: 5,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.addition, Difficulty.medium) => const LevelConfig(
      level: 1,
      name: 'Addisjon - Middels',
      operators: ['+'],
      minOperand: 1,
      maxOperand: 20,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.addition, Difficulty.hard) => const LevelConfig(
      level: 1,
      name: 'Addisjon - Vanskelig',
      operators: ['+'],
      minOperand: 10,
      maxOperand: 100,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.subtraction, Difficulty.easy) => const LevelConfig(
      level: 1,
      name: 'Subtraksjon - Lett',
      operators: ['-'],
      minOperand: 1,
      maxOperand: 10,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.subtraction, Difficulty.medium) => const LevelConfig(
      level: 1,
      name: 'Subtraksjon - Middels',
      operators: ['-'],
      minOperand: 1,
      maxOperand: 20,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.subtraction, Difficulty.hard) => const LevelConfig(
      level: 1,
      name: 'Subtraksjon - Vanskelig',
      operators: ['-'],
      minOperand: 5,
      maxOperand: 50,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.multiplication, Difficulty.easy) => const LevelConfig(
      level: 1,
      name: 'Ganging - Lett',
      operators: ['\u00D7'],
      minOperand: 1,
      maxOperand: 5,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.multiplication, Difficulty.medium) => const LevelConfig(
      level: 1,
      name: 'Ganging - Middels',
      operators: ['\u00D7'],
      minOperand: 2,
      maxOperand: 9,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.multiplication, Difficulty.hard) => const LevelConfig(
      level: 1,
      name: 'Ganging - Vanskelig',
      operators: ['\u00D7'],
      minOperand: 2,
      maxOperand: 12,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.division, Difficulty.easy) => const LevelConfig(
      level: 1,
      name: 'Deling - Lett',
      operators: ['\u00F7'],
      minOperand: 1,
      maxOperand: 5,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.division, Difficulty.medium) => const LevelConfig(
      level: 1,
      name: 'Deling - Middels',
      operators: ['\u00F7'],
      minOperand: 2,
      maxOperand: 10,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
    (GameCategory.division, Difficulty.hard) => const LevelConfig(
      level: 1,
      name: 'Deling - Vanskelig',
      operators: ['\u00F7'],
      minOperand: 2,
      maxOperand: 15,
      timeLimitSeconds: 0,
      questionsToAdvance: 999999,
    ),
  };
}
