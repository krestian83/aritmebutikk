/// Represents a single arithmetic question with answer choices.
class Question {
  final int operandA;
  final int operandB;
  final String operator;
  final int correctAnswer;
  final List<int> choices;

  const Question({
    required this.operandA,
    required this.operandB,
    required this.operator,
    required this.correctAnswer,
    required this.choices,
  });

  String get displayText => '$operandA $operator $operandB = ?';
}
