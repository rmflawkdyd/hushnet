import 'package:flutter/material.dart';

import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';

/// Molecule — 상태 점(dot) + 상태 텍스트 (design.pen `StatusChip`).
/// 점 색으로 상태를 구분하고, 텍스트는 항상 고대비(text-primary)로 둔다.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.dotColor});

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.space2),
        Text(label, style: AppTypography.heading),
      ],
    );
  }
}
