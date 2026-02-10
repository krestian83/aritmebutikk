/// Configuration for a single game level.
class LevelConfig {
  final String name;
  final List<String> operators;
  final int minOperand;
  final int maxOperand;
  final int maxDividend;

  const LevelConfig({
    required this.name,
    required this.operators,
    required this.minOperand,
    required this.maxOperand,
    this.maxDividend = 0,
  });
}
