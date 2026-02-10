import 'package:flutter_test/flutter_test.dart';
import 'package:arithmetic/game/systems/scoring_system.dart';

void main() {
  late ScoringSystem scoring;

  setUp(() {
    scoring = ScoringSystem();
  });

  tearDown(() {
    scoring.dispose();
  });

  group('score cap at 2x base', () {
    test('easy (1x) caps at 20 per question', () {
      // Build a long streak to exceed the cap.
      for (var i = 0; i < 20; i++) {
        final points = scoring.awardCorrect(difficultyMultiplier: 1);
        expect(
          points,
          lessThanOrEqualTo(20),
          reason: 'Streak $i: earned $points, should be <= 20',
        );
      }
    });

    test('medium (2x) caps at 40 per question', () {
      for (var i = 0; i < 20; i++) {
        final points = scoring.awardCorrect(difficultyMultiplier: 2);
        expect(
          points,
          lessThanOrEqualTo(40),
          reason: 'Streak $i: earned $points, should be <= 40',
        );
      }
    });

    test('hard (3x) caps at 60 per question', () {
      for (var i = 0; i < 20; i++) {
        final points = scoring.awardCorrect(difficultyMultiplier: 3);
        expect(
          points,
          lessThanOrEqualTo(60),
          reason: 'Streak $i: earned $points, should be <= 60',
        );
      }
    });

    test('easy starts at 10 and grows to 20', () {
      final first = scoring.awardCorrect(difficultyMultiplier: 1);
      expect(first, 10);

      // Keep going until we hit the cap.
      var hitCap = false;
      for (var i = 0; i < 20; i++) {
        final points = scoring.awardCorrect(difficultyMultiplier: 1);
        if (points == 20) {
          hitCap = true;
          break;
        }
      }
      expect(hitCap, true, reason: 'Should reach 2x cap of 20');
    });

    test('awardWouldBe also respects the cap', () {
      // Build streak high enough to exceed cap.
      for (var i = 0; i < 20; i++) {
        scoring.awardCorrect(difficultyMultiplier: 1);
      }
      final wouldBe = scoring.awardWouldBe(difficultyMultiplier: 1);
      expect(wouldBe, lessThanOrEqualTo(20));
    });

    test('wrong answer penalty based on capped value', () {
      // Build a high streak.
      for (var i = 0; i < 15; i++) {
        scoring.awardCorrect(difficultyMultiplier: 1);
      }
      final before = scoring.score.value;
      final penalty = scoring.recordWrong(difficultyMultiplier: 1);
      // Penalty is half of capped value, so max 10.
      expect(penalty, lessThanOrEqualTo(10));
      expect(scoring.score.value, before - penalty);
    });
  });
}
