import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../game/models/high_score_entry.dart';
import '../../game/services/high_score_service.dart';
import '../widgets/background/animated_background.dart';

/// Displays the local high score table.
class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  final _service = HighScoreService();
  List<HighScoreEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _service.load();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildList()),
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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.cardGradientStart,
            ),
          ),
          const Expanded(
            child: Text(
              'High Scores',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
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

  Widget _buildList() {
    if (_entries == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cardGradientStart),
      );
    }

    if (_entries!.isEmpty) {
      return Center(
        child: Text(
          'No scores yet.\nPlay a game!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.cardGradientStart.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _entries!.length,
      itemBuilder: (context, index) {
        final entry = _entries![index];
        return _ScoreRow(rank: index + 1, entry: entry);
      },
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int rank;
  final HighScoreEntry entry;

  const _ScoreRow({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final rankIcons = ['', '\uD83E\uDD47', '\uD83E\uDD48', '\uD83E\uDD49'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isTop3 ? 0.95 : 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: AppColors.cardGradientStart.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: isTop3
                ? Text(rankIcons[rank], style: const TextStyle(fontSize: 22))
                : Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isTop3
                        ? AppColors.cardGradientStart
                        : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.formattedTime}  \u2022  '
                  '${entry.formattedDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isTop3 ? AppColors.cardGradientEnd : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
