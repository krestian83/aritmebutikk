import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../game/models/store_item.dart';
import '../../../game/models/store_suggestion.dart';

/// Dialog for adding or editing a store item.
///
/// Returns the completed [StoreItem], or `null` if cancelled.
class ItemFormDialog extends StatefulWidget {
  /// Pre-fill from an existing item (edit mode).
  final StoreItem? item;

  /// Pre-fill from a suggestion template (quick-add).
  final StoreSuggestion? suggestion;

  /// Existing category names for the dropdown.
  final List<String> categories;

  const ItemFormDialog._({
    this.item,
    this.suggestion,
    required this.categories,
  });

  /// Shows the form dialog. Returns the created/updated [StoreItem]
  /// or `null` if cancelled.
  static Future<StoreItem?> show(
    BuildContext context, {
    StoreItem? item,
    StoreSuggestion? suggestion,
    required List<String> categories,
  }) {
    return showDialog<StoreItem>(
      context: context,
      builder: (_) => ItemFormDialog._(
        item: item,
        suggestion: suggestion,
        categories: categories,
      ),
    );
  }

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _costCtrl;
  String _category = '';
  bool _isNewCategory = false;
  late final TextEditingController _newCategoryCtrl;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final sug = widget.suggestion;

    _nameCtrl = TextEditingController(text: item?.name ?? sug?.name ?? '');
    _iconCtrl = TextEditingController(text: item?.icon ?? sug?.icon ?? '');
    _costCtrl = TextEditingController(
      text: item != null
          ? item.cost.toString()
          : sug != null
          ? sug.defaultCost.toString()
          : '',
    );
    _category = item?.category ?? sug?.category ?? '';
    if (_category.isNotEmpty && !widget.categories.contains(_category)) {
      _isNewCategory = true;
    }
    _newCategoryCtrl = TextEditingController(
      text: _isNewCategory ? _category : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    _costCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cat = _isNewCategory ? _newCategoryCtrl.text.trim() : _category;
    if (cat.isEmpty) return;

    final cost = int.tryParse(_costCtrl.text.trim()) ?? 0;

    final id =
        widget.item?.id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final result = StoreItem(
      id: id,
      name: _nameCtrl.text.trim(),
      icon: _iconCtrl.text.trim(),
      cost: cost,
      category: cat,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _isEditing ? 'Rediger vare' : 'Ny vare',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.cardGradientStart,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNameField(),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(width: 80, child: _buildIconField()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCostField()),
                ],
              ),
              const SizedBox(height: 12),
              _buildCategoryPicker(),
              if (_isNewCategory) ...[
                const SizedBox(height: 8),
                _buildNewCategoryField(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Avbryt', style: TextStyle(color: Colors.grey.shade500)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cardGradientStart,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: AppColors.outline,
              width: 1,
            ),
          ),
          child: Text(_isEditing ? 'Lagre' : 'Legg til'),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      textCapitalization: TextCapitalization.sentences,
      decoration: _inputDecoration('Navn'),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Navn er pakrevd' : null,
    );
  }

  Widget _buildIconField() {
    return TextFormField(
      controller: _iconCtrl,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24),
      decoration: _inputDecoration('Ikon'),
      validator: (v) => (v == null || v.trim().isEmpty) ? '' : null,
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      controller: _costCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration('Poeng'),
      validator: (v) {
        final n = int.tryParse(v ?? '');
        if (n == null || n <= 0) return 'Maa vaere > 0';
        return null;
      },
    );
  }

  Widget _buildCategoryPicker() {
    final items = [
      ...widget.categories.map(
        (c) => DropdownMenuItem(value: c, child: Text(c)),
      ),
      const DropdownMenuItem(value: '__new__', child: Text('+ Ny kategori')),
    ];

    final current = _isNewCategory
        ? '__new__'
        : widget.categories.contains(_category)
        ? _category
        : null;

    return DropdownButtonFormField<String>(
      initialValue: current,
      items: items,
      decoration: _inputDecoration('Kategori'),
      onChanged: (val) {
        setState(() {
          if (val == '__new__') {
            _isNewCategory = true;
          } else {
            _isNewCategory = false;
            _category = val ?? '';
          }
        });
      },
      validator: (v) {
        if (v == null || v.isEmpty) return 'Velg kategori';
        if (v == '__new__' && _newCategoryCtrl.text.trim().isEmpty) {
          return 'Skriv inn ny kategori';
        }
        return null;
      },
    );
  }

  Widget _buildNewCategoryField() {
    return TextFormField(
      controller: _newCategoryCtrl,
      textCapitalization: TextCapitalization.sentences,
      decoration: _inputDecoration('Ny kategori'),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Skriv inn kategori' : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.cardGradientStart,
          width: 2,
        ),
      ),
    );
  }
}
