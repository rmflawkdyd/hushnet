import 'package:flutter/material.dart';

import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';

/// Atom — 외곽선 보조 버튼 (design.pen `Button/Secondary`).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space4,
            horizontal: AppSpacing.space6,
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTypography.bodyStrong),
        ),
      ),
    );
  }
}
