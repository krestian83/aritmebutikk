import 'package:flutter/material.dart';

import '../../app/l10n/strings.dart';
import '../../app/theme/app_colors.dart';
import '../../game/config/level_config.dart';
import '../../game/models/game_category.dart';
import '../../game/models/question.dart';
import '../../game/services/credit_service.dart';
import '../../game/services/sound_service.dart';
import '../../game/systems/question_generator.dart';
import '../../game/systems/scoring_system.dart';
import '../widgets/answer/answer_grid.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/effects/category_max_celebration.dart';
import '../widgets/effects/confetti_overlay.dart';
import '../widgets/effects/score_popup.dart';
import '../widgets/effects/shake_widget.dart';
import '../widgets/hud/mute_button.dart';
import '../widgets/hud/score_pill.dart';
import '../widgets/question/question_card.dart';

/// The main game screen. Plays a single category + difficulty
/// until the player quits.
class GameScreen extends StatefulWidget {
  final String playerName;
  final GameCategory category;

  const GameScreen({
    super.key,
    required this.playerName,
    required this.category,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final _questionGenerator = QuestionGenerator();
  final _scoring = ScoringSystem();
  final _sound = SoundService.instance;
  final _creditService = CreditService.instance;

  final _questionCardKey = GlobalKey<ShakeWidgetState>();

  late Difficulty _difficulty = Difficulty.easy;
  late LevelConfig _config = configFor(widget.category, _difficulty);

  Question? _currentQuestion;
  bool _buttonsEnabled = true;
  bool _showConfetti = false;
  bool _showMaxCelebration = false;
  int? _popupPoints;

  /// Credits already banked for this category before the session.
  int _previouslyEarned = 0;

  /// Score value already persisted, so we don't double-save.
  int _lastSavedScore = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scoring.reset();
    _loadPreviousEarned();
    _nextQuestion();
  }

  Future<void> _loadPreviousEarned() async {
    _previouslyEarned = await _creditService.getCategoryEarned(
      widget.playerName,
      widget.category,
    );
  }

  void _nextQuestion() {
    _currentQuestion = _questionGenerator.generate(_config);
    _buttonsEnabled = true;
    setState(() {});
  }

  void _onAnswerSelected(int answer) {
    if (!_buttonsEnabled || _currentQuestion == null) return;

    final correct = answer == _currentQuestion!.correctAnswer;

    // Play sound immediately on tap.
    _sound.play(correct ? 'success' : 'wrong');

    if (correct) {
      _onCorrectAnswer();
    } else {
      _onWrongAnswer();
    }
  }

  void _onCorrectAnswer() {
    _buttonsEnabled = false;
    final points = _scoring.awardCorrect(
      difficultyMultiplier: _difficulty.pointsMultiplier,
    );

    setState(() {
      _showConfetti = true;
      _popupPoints = points;
    });

    // Check if session score has reached the category cap.
    final totalProjected = _previouslyEarned + _scoring.score.value;
    if (totalProjected >= widget.category.maxCredits) {
      _triggerMaxCelebration();
      return;
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  Future<void> _triggerMaxCelebration() async {
    await _saveUnsavedCredits();
    if (!mounted) return;
    _sound.play('levelup');
    setState(() => _showMaxCelebration = true);
  }

  void _onWrongAnswer() {
    _buttonsEnabled = false;
    _scoring.recordWrong(difficultyMultiplier: _difficulty.pointsMultiplier);
    _questionCardKey.currentState?.shake();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _buttonsEnabled = true;
      setState(() {});
    });
  }

  void _changeDifficulty(Difficulty d) {
    if (d == _difficulty) return;
    _sound.play('press');
    setState(() {
      _difficulty = d;
      _config = configFor(widget.category, d);
    });
    _nextQuestion();
  }

  Future<void> _quitToMenu() async {
    _sound.play('press');
    await _saveUnsavedCredits();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveUnsavedCredits();
    }
  }

  Future<void> _saveUnsavedCredits() async {
    final unsaved = _scoring.score.value - _lastSavedScore;
    if (unsaved <= 0) return;
    final actual = await _creditService.addCredits(
      widget.playerName,
      unsaved,
      widget.category,
    );
    _lastSavedScore += actual;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scoring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              _buildMainContent(),
              if (_showConfetti)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: ConfettiOverlay(
                      onComplete: () {
                        setState(() => _showConfetti = false);
                      },
                    ),
                  ),
                ),
              if (_popupPoints != null)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ScorePopup(
                      points: _popupPoints!,
                      onComplete: () {
                        setState(() => _popupPoints = null);
                      },
                    ),
                  ),
                ),
              const MuteButton(),
              if (_showMaxCelebration)
                Positioned.fill(
                  child: CategoryMaxCelebration(
                    category: widget.category,
                    onComplete: () {
                      if (mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _quitToMenu,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.menuTextBrown,
                ),
                tooltip: S.current.quitAndSave,
              ),
              Expanded(child: ScorePill(score: _scoring.score)),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          _buildDifficultyToggle(),
          const SizedBox(height: 10),
          ShakeWidget(
            key: _questionCardKey,
            child: QuestionCard(
              questionText: _currentQuestion?.displayText ?? '? + ? = ?',
            ),
          ),
          const Spacer(),
          if (_currentQuestion != null)
            RepaintBoundary(
              child: AnswerGrid(
                choices: _currentQuestion!.choices,
                enabled: _buttonsEnabled,
                onChoiceSelected: _onAnswerSelected,
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${widget.category.icon}  ${widget.category.label}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.menuTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final d in Difficulty.values) ...[
          if (d != Difficulty.easy) const SizedBox(width: 6),
          _DifficultyChip(
            label: d.label,
            multiplier: '${d.pointsMultiplier}x',
            selected: d == _difficulty,
            onTap: () => _changeDifficulty(d),
          ),
        ],
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final String multiplier;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.multiplier,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.menuTeal
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.menuTextBrown.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.menuTeal,
              ),
            ),
            Text(
              multiplier,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white70
                    : AppColors.menuTeal.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
