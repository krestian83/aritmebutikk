import 'package:flutter/foundation.dart';

import '../config/level_config.dart';

/// Tracks level progression.
class LevelManager {
  final ValueNotifier<int> currentLevel = ValueNotifier(1);
  final ValueNotifier<int> correctInLevel = ValueNotifier(0);

  LevelConfig get config {
    final idx = (currentLevel.value - 1).clamp(
      0,
      LevelConfig.levels.length - 1,
    );
    return LevelConfig.levels[idx];
  }

  /// Records a correct answer. Returns true if level is complete.
  bool recordCorrect() {
    correctInLevel.value++;
    return correctInLevel.value >= config.questionsToAdvance;
  }

  /// Advances to the next level. Returns true if there are more
  /// levels, false if the player has beaten all levels.
  bool advanceLevel() {
    if (currentLevel.value >= LevelConfig.levels.length) {
      return false;
    }
    currentLevel.value++;
    correctInLevel.value = 0;
    return true;
  }

  /// Resets to level 1.
  void reset() {
    currentLevel.value = 1;
    correctInLevel.value = 0;
  }

  void dispose() {
    currentLevel.dispose();
    correctInLevel.dispose();
  }
}
