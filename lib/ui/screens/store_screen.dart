import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../game/models/ledger_entry.dart';
import '../../game/models/store_item.dart';
import '../../game/services/credit_service.dart';
import '../../game/services/store_item_service.dart';
import '../widgets/background/animated_background.dart';

/// Store where players spend credits, plus a purchase ledger.
class StoreScreen extends StatefulWidget {
  final String playerName;

  const StoreScreen({super.key, required this.playerName});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  final _creditService = CreditService();
  final _storeItemService = StoreItemService();
  late final TabController _tabController;
  int _balance = 0;
  List<StoreItem>? _items;
  List<LedgerEntry>? _ledger;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final balance = await _creditService.getBalance(widget.playerName);
    final items = await _storeItemService.loadItems();
    final ledger = await _creditService.loadLedger();
    if (!mounted) return;
    setState(() {
      _balance = balance;
      _items = items;
      _ledger = ledger;
    });
  }

  Future<void> _buy(StoreItem item) async {
    if (_balance < item.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ikke nok poeng! Trenger ${item.cost}, '
            'har $_balance.',
          ),
          backgroundColor: AppColors.timerRed,
        ),
      );
      return;
    }

    final success = await _creditService.spend(
      widget.playerName,
      item.cost,
      item.name,
    );
    if (!success || !mounted) return;
    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kj\u00F8pt ${item.name}!'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildBalanceBanner(),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.cardGradientStart,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.cardGradientStart,
                tabs: const [
                  Tab(text: 'Butikk'),
                  Tab(text: 'Logg'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildStore(), _buildLedger()],
                ),
              ),
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
              'Butikk',
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

  Widget _buildBalanceBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientStart.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('\u2B50', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            '$_balance poeng',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStore() {
    if (_items == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cardGradientStart),
      );
    }
    if (_items!.isEmpty) {
      return Center(
        child: Text(
          'Ingen varer i butikken.',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.cardGradientStart.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        for (final item in _items!)
          _StoreItemCard(
            item: item,
            canAfford: _balance >= item.cost,
            onBuy: () => _buy(item),
          ),
      ],
    );
  }

  Widget _buildLedger() {
    if (_ledger == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cardGradientStart),
      );
    }
    if (_ledger!.isEmpty) {
      return Center(
        child: Text(
          'Ingen kj\u00F8p enn\u00E5.',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.cardGradientStart.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _ledger!.length,
      itemBuilder: (context, index) {
        final entry = _ledger![index];
        return _LedgerRow(entry: entry);
      },
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final bool canAfford;
  final VoidCallback onBuy;

  const _StoreItemCard({
    required this.item,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: canAfford ? 0.95 : 0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientStart.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: canAfford
                        ? AppColors.cardGradientStart
                        : Colors.grey.shade500,
                  ),
                ),
                Text(
                  '${item.cost} poeng',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canAfford ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardGradientStart,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Kj\u00F8p',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final LedgerEntry entry;

  const _LedgerRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.itemName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cardGradientStart,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.playerName}  \u2022  '
                  '${entry.formattedDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '-${entry.creditsCost}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.timerRed,
            ),
          ),
        ],
      ),
    );
  }
}
