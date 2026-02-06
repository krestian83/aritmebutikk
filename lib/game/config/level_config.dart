/// Configuration for a single game level.
class LevelConfig {
  final int level;
  final String name;
  final List<String> operators;
  final int minOperand;
  final int maxOperand;
  final int timeLimitSeconds;
  final int questionsToAdvance;

  const LevelConfig({
    required this.level,
    required this.name,
    required this.operators,
    required this.minOperand,
    required this.maxOperand,
    required this.timeLimitSeconds,
    required this.questionsToAdvance,
  });

  static const List<LevelConfig> levels = [
    LevelConfig(
      level: 1,
      name: 'Enkel addisjon',
      operators: ['+'],
      minOperand: 1,
      maxOperand: 5,
      timeLimitSeconds: 60,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 2,
      name: 'Addisjon',
      operators: ['+'],
      minOperand: 1,
      maxOperand: 10,
      timeLimitSeconds: 60,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 3,
      name: 'Enkel subtraksjon',
      operators: ['-'],
      minOperand: 1,
      maxOperand: 10,
      timeLimitSeconds: 60,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 4,
      name: 'Blandet +/-',
      operators: ['+', '-'],
      minOperand: 1,
      maxOperand: 12,
      timeLimitSeconds: 55,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 5,
      name: 'Enkel ganging',
      operators: ['×'],
      minOperand: 1,
      maxOperand: 5,
      timeLimitSeconds: 60,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 6,
      name: 'Ganging',
      operators: ['×'],
      minOperand: 2,
      maxOperand: 9,
      timeLimitSeconds: 55,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 7,
      name: 'Blandet +/-/×',
      operators: ['+', '-', '×'],
      minOperand: 2,
      maxOperand: 12,
      timeLimitSeconds: 50,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 8,
      name: 'Enkel deling',
      operators: ['÷'],
      minOperand: 1,
      maxOperand: 10,
      timeLimitSeconds: 60,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 9,
      name: 'Blandet alle',
      operators: ['+', '-', '×', '÷'],
      minOperand: 2,
      maxOperand: 12,
      timeLimitSeconds: 50,
      questionsToAdvance: 10,
    ),
    LevelConfig(
      level: 10,
      name: 'Utfordring!',
      operators: ['+', '-', '×', '÷'],
      minOperand: 3,
      maxOperand: 15,
      timeLimitSeconds: 45,
      questionsToAdvance: 10,
    ),
  ];
}
