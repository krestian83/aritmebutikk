import 'dart:math';

import '../config/level_config.dart';
import '../models/question.dart';

/// Generates arithmetic questions with plausible distractors.
class QuestionGenerator {
  final Random _random = Random();

  /// Creates a new question based on the given level config.
  Question generate(LevelConfig config) {
    final op = config.operators[_random.nextInt(config.operators.length)];
    final (a, b, answer) = _generateOperands(op, config);
    final choices = _generateChoices(answer, config);
    return Question(
      operandA: a,
      operandB: b,
      operator: op,
      correctAnswer: answer,
      choices: choices,
    );
  }

  (int, int, int) _generateOperands(String op, LevelConfig config) {
    switch (op) {
      case '+':
        final a = _randRange(config.minOperand, config.maxOperand);
        final b = _randRange(config.minOperand, config.maxOperand);
        return (a, b, a + b);
      case '-':
        // Ensure non-negative result.
        var a = _randRange(config.minOperand, config.maxOperand);
        var b = _randRange(config.minOperand, config.maxOperand);
        if (b > a) {
          final temp = a;
          a = b;
          b = temp;
        }
        return (a, b, a - b);
      case '×':
        final a = _randRange(config.minOperand, config.maxOperand);
        final b = _randRange(config.minOperand, config.maxOperand);
        return (a, b, a * b);
      case '÷':
        // Generate a valid division: pick b and answer, then a = b * answer.
        final b = _randRange(max(1, config.minOperand), config.maxOperand);
        final answer = _randRange(1, config.maxOperand);
        return (b * answer, b, answer);
      default:
        return (1, 1, 2);
    }
  }

  /// Generates 4 unique answer choices including the correct one.
  List<int> _generateChoices(int correct, LevelConfig config) {
    final choices = <int>{correct};
    var attempts = 0;
    while (choices.length < 4 && attempts < 50) {
      // Generate distractors within ±3 of correct answer.
      final offset = _random.nextInt(7) - 3;
      final distractor = correct + offset;
      if (distractor != correct && distractor >= 0) {
        choices.add(distractor);
      }
      attempts++;
    }
    // Fill remaining with wider range if needed.
    while (choices.length < 4) {
      final distractor = correct + _random.nextInt(10) - 5;
      if (distractor != correct && distractor >= 0) {
        choices.add(distractor);
      }
    }
    final list = choices.toList()..shuffle(_random);
    return list;
  }

  int _randRange(int min, int max) => min + _random.nextInt(max - min + 1);
}
