import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:arithmetic/game/models/game_category.dart';
import 'package:arithmetic/game/systems/question_generator.dart';

void main() {
  final generator = QuestionGenerator();

  group('no overlap between difficulty levels', () {
    /// Generates [n] questions and returns all (operandA, operandB) pairs.
    List<(int, int)> sampleOperands(
      GameCategory category,
      Difficulty difficulty,
      int n,
    ) {
      final config = configFor(category, difficulty);
      final pairs = <(int, int)>[];
      for (var i = 0; i < n; i++) {
        final q = generator.generate(config);
        pairs.add((q.operandA, q.operandB));
      }
      return pairs;
    }

    /// Returns the min and max operand seen across [n] samples.
    /// For division, checks divisor (operandB) and quotient
    /// (correctAnswer) instead of the derived dividend.
    (int, int) operandRange(
      GameCategory category,
      Difficulty difficulty, {
      int n = 500,
    }) {
      final config = configFor(category, difficulty);
      var lo = 999999;
      var hi = 0;
      for (var i = 0; i < n; i++) {
        final q = generator.generate(config);
        if (category == GameCategory.division) {
          // Only track divisor range; quotient is derived from
          // maxDividend / divisor and intentionally differs.
          lo = min(lo, q.operandB);
          hi = max(hi, q.operandB);
        } else {
          lo = min(lo, min(q.operandA, q.operandB));
          hi = max(hi, max(q.operandA, q.operandB));
        }
      }
      return (lo, hi);
    }

    for (final category in GameCategory.values) {
      test('$category: easy and medium do not overlap', () {
        final (_, easyHi) = operandRange(category, Difficulty.easy);
        final (medLo, _) = operandRange(category, Difficulty.medium);
        expect(
          medLo,
          greaterThan(easyHi),
          reason:
              '$category medium min ($medLo) should be > '
              'easy max ($easyHi)',
        );
      });

      test('$category: medium and hard do not overlap', () {
        final (_, medHi) = operandRange(category, Difficulty.medium);
        final (hardLo, _) = operandRange(category, Difficulty.hard);
        expect(
          hardLo,
          greaterThan(medHi),
          reason:
              '$category hard min ($hardLo) should be > '
              'medium max ($medHi)',
        );
      });
    }
  });

  group('question variety (no excessive repetition)', () {
    /// Generates [n] questions and returns the count of unique
    /// question strings.
    int uniqueQuestions(
      GameCategory category,
      Difficulty difficulty, {
      int n = 100,
    }) {
      final config = configFor(category, difficulty);
      final seen = <String>{};
      for (var i = 0; i < n; i++) {
        final q = generator.generate(config);
        seen.add(q.displayText);
      }
      return seen.length;
    }

    for (final category in GameCategory.values) {
      for (final difficulty in Difficulty.values) {
        test('$category ${difficulty.label}: sufficient variety', () {
          final unique = uniqueQuestions(category, difficulty);
          // At least 15 unique questions out of 100 samples.
          // Lower threshold for small ranges (multiplication,
          // division easy).
          final minExpected = switch ((category, difficulty)) {
            (GameCategory.multiplication, Difficulty.easy) => 10,
            (GameCategory.division, Difficulty.easy) => 8,
            _ => 15,
          };
          expect(
            unique,
            greaterThanOrEqualTo(minExpected),
            reason:
                '$category ${difficulty.label}: only $unique unique '
                'questions out of 100 (expected >= $minExpected)',
          );
        });
      }
    }
  });

  group('operands stay within configured bounds', () {
    for (final category in GameCategory.values) {
      for (final difficulty in Difficulty.values) {
        test('$category ${difficulty.label}: operands in range', () {
          final config = configFor(category, difficulty);
          for (var i = 0; i < 200; i++) {
            final q = generator.generate(config);
            // For division, operandA is the dividend (b*answer)
            // which can exceed maxOperand. Check operandB instead.
            if (category == GameCategory.division) {
              expect(
                q.operandB,
                inInclusiveRange(max(2, config.minOperand), config.maxOperand),
                reason: 'divisor out of range: ${q.displayText}',
              );
              // Quotient upper bound depends on dividend cap
              // and actual divisor, mirroring the generator logic.
              final lo = max(2, config.minOperand);
              final maxQ = config.maxDividend > 0
                  ? max(lo, config.maxDividend ~/ q.operandB)
                  : config.maxOperand;
              expect(
                q.correctAnswer,
                inInclusiveRange(lo, maxQ),
                reason: 'quotient out of range: ${q.displayText}',
              );
              if (config.maxDividend > 0) {
                expect(
                  q.operandA,
                  lessThanOrEqualTo(config.maxDividend),
                  reason: 'dividend exceeds cap: ${q.displayText}',
                );
              }
            } else {
              expect(
                q.operandA,
                inInclusiveRange(config.minOperand, config.maxOperand),
                reason: 'operandA out of range: ${q.displayText}',
              );
              expect(
                q.operandB,
                inInclusiveRange(config.minOperand, config.maxOperand),
                reason: 'operandB out of range: ${q.displayText}',
              );
            }
          }
        });
      }
    }
  });
}
