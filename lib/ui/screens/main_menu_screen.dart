import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../game/services/credit_service.dart';
import '../widgets/background/animated_background.dart';
import 'category_screen.dart';
import 'store_screen.dart';

/// Main menu with name entry, credit balance, and navigation.
class MainMenuScreen extends StatefulWidget {
  final String? initialName;

  const MainMenuScreen({super.key, this.initialName});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  final _creditService = CreditService();
  int? _balance;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
      _loadBalance(widget.initialName!);
    }
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      _loadBalance(name);
    } else {
      setState(() => _balance = null);
    }
  }

  Future<void> _loadBalance(String name) async {
    final balance = await _creditService.getBalance(name);
    if (!mounted) return;
    setState(() => _balance = balance);
  }

  void _startGame() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => CategoryScreen(playerName: name)),
        )
        .then((_) => _loadBalance(name));
  }

  void _openStore() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => StoreScreen(playerName: name)))
        .then((_) => _loadBalance(name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '\u2795\u2796\u2716\u2797',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aritme(bu)tikk',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cardGradientStart,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildNameField(),
                  if (_balance != null) ...[
                    const SizedBox(height: 16),
                    _buildBalanceChip(),
                  ],
                  const SizedBox(height: 24),
                  _buildPlayButton(),
                  const SizedBox(height: 16),
                  _buildStoreButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientStart.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.cardGradientStart,
        ),
        decoration: InputDecoration(
          hintText: 'Skriv inn navnet ditt',
          hintStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.cardGradientStart.withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
        onSubmitted: (_) => _startGame(),
      ),
    );
  }

  Widget _buildBalanceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\u2B50', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            '$_balance poeng',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardGradientStart,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Spill',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildStoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _openStore,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cardGradientStart,
          side: const BorderSide(color: AppColors.cardGradientStart, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Butikk',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
