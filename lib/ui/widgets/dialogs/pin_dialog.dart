import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../game/services/store_item_service.dart';

/// 4-digit PIN dialog for parent access.
///
/// Returns `true` if authenticated, `false` / `null` if cancelled.
/// On first use (no PIN set), prompts parent to create one.
class PinDialog extends StatefulWidget {
  const PinDialog._();

  /// Shows the PIN dialog and returns whether access was granted.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PinDialog._(),
    );
    return result ?? false;
  }

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _service = StoreItemService();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isNewPin = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final hasPin = await _service.hasPin();
    if (!mounted) return;
    setState(() {
      _isNewPin = !hasPin;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'PIN ma vaere 4 siffer.');
      return;
    }

    if (_isNewPin) {
      final confirm = _confirmController.text.trim();
      if (pin != confirm) {
        setState(() => _error = 'PIN-kodene er ikke like.');
        return;
      }
      await _service.setPin(pin);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      final ok = await _service.verifyPin(pin);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = 'Feil PIN-kode.');
        _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cardGradientStart),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _isNewPin ? 'Opprett foreldrekode' : 'Skriv inn foreldrekode',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.cardGradientStart,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isNewPin)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Velg en 4-sifret kode som bare du vet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          _buildPinField(
            controller: _pinController,
            label: 'PIN',
            autofocus: true,
          ),
          if (_isNewPin) ...[
            const SizedBox(height: 12),
            _buildPinField(
              controller: _confirmController,
              label: 'Bekreft PIN',
              autofocus: false,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.timerRed,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
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
          ),
          child: Text(_isNewPin ? 'Lagre' : 'OK'),
        ),
      ],
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required bool autofocus,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      obscureText: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 12,
        color: AppColors.cardGradientStart,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.cardGradientStart,
            width: 2,
          ),
        ),
      ),
      onSubmitted: (_) => _submit(),
    );
  }
}
