/// Configuration for a single game level.
class LevelConfig {
  final int level;
  final String name;
  final List<String> operators;
  final int minOperand;
  final int maxOperand;
  final int timeLimitSeconds;
  final int questionsToAdvance;
  final int maxDividend;

  const LevelConfig({
    required this.level,
    required this.name,
    required this.operators,
    required this.minOperand,
    required this.maxOperand,
    required this.timeLimitSeconds,
    required this.questionsToAdvance,
    this.maxDividend = 0,
  });
}
