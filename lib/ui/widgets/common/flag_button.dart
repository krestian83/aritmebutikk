import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Circular country flag button with a highlighted border
/// when [selected].
class FlagButton extends StatelessWidget {
  final String countryCode;
  final bool selected;
  final VoidCallback onTap;

  const FlagButton({
    super.key,
    required this.countryCode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const size = 27.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.menuTeal
                : AppColors.menuTextBrown.withValues(alpha: 0.15),
            width: selected ? 2.5 : 1,
          ),
        ),
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: FittedBox(
              fit: BoxFit.cover,
              child: CountryFlag.fromCountryCode(countryCode),
            ),
          ),
        ),
      ),
    );
  }
}
