import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../game/models/game_category.dart';
import '../../game/services/credit_service.dart';
import '../../game/services/sound_service.dart';
import '../widgets/avatar/avatar_icon.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/hud/mute_button.dart';
import 'game_screen.dart';

/// Screen where the player picks a category and difficulty.
class CategoryScreen extends StatefulWidget {
  final String playerName;

  const CategoryScreen({super.key, required this.playerName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _creditService = CreditService.instance;
  Map<GameCategory, int>? _earned;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _creditService.resetCategoriesIfNeeded();
    final earned = await _creditService.getAllCategoryEarned(widget.playerName);
    if (!mounted) return;
    setState(() => _earned = earned);
  }

  Future<void> _play(GameCategory category) async {
    SoundService.instance.play('press');
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GameScreen(playerName: widget.playerName, category: category),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _earned == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.cardGradientStart,
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            children: [
                              for (final cat in GameCategory.values)
                                _CategoryCard(
                                  category: cat,
                                  earned: _earned![cat] ?? 0,
                                  onTap: () => _play(cat),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
              const MuteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              SoundService.instance.play('press');
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.cardGradientStart,
            ),
          ),
          AvatarIcon(playerName: widget.playerName, size: 32),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Velg kategori',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.cardGradientStart,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final GameCategory category;
  final int earned;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.earned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxedOut = earned >= category.maxCredits;

    return GestureDetector(
      onTap: maxedOut ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardGradientStart.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cardGradientStart,
                    ),
                  ),
                ),
                Text(
                  '$earned / ${category.maxCredits}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: maxedOut ? AppColors.green : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: earned / category.maxCredits,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: maxedOut ? AppColors.green : AppColors.cardGradientStart,
              ),
            ),
            if (maxedOut)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Maks poeng opptjent!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    'Trykk for \u00e5 spille',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cardGradientStart.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
