import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../game/models/store_item.dart';
import '../../game/models/store_suggestion.dart';
import '../../game/services/store_item_service.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/dialogs/item_form_dialog.dart';

/// Parent editor for customizing store items.
class StoreEditorScreen extends StatefulWidget {
  const StoreEditorScreen({super.key});

  @override
  State<StoreEditorScreen> createState() => _StoreEditorScreenState();
}

class _StoreEditorScreenState extends State<StoreEditorScreen> {
  final _service = StoreItemService();
  List<StoreItem>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _service.loadItems();
    if (!mounted) return;
    setState(() => _items = items);
  }

  List<String> get _categories {
    if (_items == null) return [];
    return _items!.map((i) => i.category).toSet().toList()..sort();
  }

  /// Groups items by category, preserving insertion order.
  Map<String, List<StoreItem>> get _grouped {
    final map = <String, List<StoreItem>>{};
    for (final item in _items ?? <StoreItem>[]) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  Future<void> _addItem({StoreSuggestion? suggestion}) async {
    final result = await ItemFormDialog.show(
      context,
      suggestion: suggestion,
      categories: _categories,
    );
    if (result == null) return;
    await _service.addItem(
      name: result.name,
      icon: result.icon,
      cost: result.cost,
      category: result.category,
    );
    await _load();
  }

  Future<void> _editItem(StoreItem item) async {
    final result = await ItemFormDialog.show(
      context,
      item: item,
      categories: _categories,
    );
    if (result == null) return;
    await _service.updateItem(result);
    await _load();
  }

  Future<void> _deleteItem(StoreItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Slett vare?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.cardGradientStart,
          ),
        ),
        content: Text(
          'Er du sikker pa at du vil slette '
          '"${item.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Avbryt',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.timerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Slett'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _service.deleteItem(item.id);
    await _load();
  }

  Future<void> _resetDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tilbakestill?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.cardGradientStart,
          ),
        ),
        content: const Text(
          'Dette fjerner alle endringer og '
          'tilbakestiller til standardvarene.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Avbryt',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.timerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tilbakestill'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _service.saveItems(List.of(StoreItem.defaults));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(),
        backgroundColor: AppColors.cardGradientStart,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Legg til vare',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
              'Rediger butikk',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.cardGradientStart,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.cardGradientStart,
            ),
            onSelected: (val) {
              if (val == 'reset') _resetDefaults();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'reset',
                child: Text('Tilbakestill standardvarer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_items == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cardGradientStart),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        ..._buildItemSections(),
        const SizedBox(height: 24),
        _buildSuggestionsSection(),
      ],
    );
  }

  List<Widget> _buildItemSections() {
    final grouped = _grouped;
    if (grouped.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'Ingen varer enna.\n'
              'Legg til fra forslagene under!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.cardGradientStart.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            entry.key,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.cardGradientStart,
            ),
          ),
        ),
      );
      for (final item in entry.value) {
        widgets.add(
          _EditorItemCard(
            item: item,
            onEdit: () => _editItem(item),
            onDelete: () => _deleteItem(item),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildSuggestionsSection() {
    final grouped = <String, List<StoreSuggestion>>{};
    for (final s in StoreSuggestion.all) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 4),
        const Text(
          'Forslag',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.cardGradientStart,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Trykk for a legge til raskt',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 10),
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final s in entry.value)
                ActionChip(
                  avatar: Text(s.icon, style: const TextStyle(fontSize: 16)),
                  label: Text(s.name),
                  labelStyle: const TextStyle(fontSize: 13),
                  backgroundColor: Colors.white.withValues(alpha: 0.85),
                  side: BorderSide(
                    color: AppColors.cardGradientStart.withValues(alpha: 0.2),
                  ),
                  onPressed: () => _addItem(suggestion: s),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EditorItemCard extends StatelessWidget {
  final StoreItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EditorItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientStart.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cardGradientStart,
                  ),
                ),
                Text(
                  '${item.cost} poeng',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.cardGradientStart,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.timerRed,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
