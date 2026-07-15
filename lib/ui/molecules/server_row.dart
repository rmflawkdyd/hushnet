import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/vpn_server.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';
import '../atoms/flag_icon.dart';

/// Molecule — 서버 선택 목록의 한 행 (design.pen `ServerRow`).
///
/// 4개 상태: 선택됨 / 선택 가능 / 혼잡(full) / 점검 중(down).
/// 선택 표시는 색만 쓰지 않고 primary 테두리 + 체크 아이콘의 이중 단서로 준다(접근성).
class ServerRow extends StatelessWidget {
  const ServerRow({
    super.key,
    required this.server,
    required this.isSelected,
    required this.onTap,
  });

  final VpnServer server;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelectable = server.isSelectable;

    return Opacity(
      opacity: isSelectable ? 1 : 0.55,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isSelectable ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.space3,
              horizontal: AppSpacing.space4,
            ),
            child: Row(
              children: [
                FlagIcon(countryCode: server.countryCode),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(server.country, style: AppTypography.bodyStrong),
                      const SizedBox(height: 2),
                      Text(server.city, style: AppTypography.caption),
                    ],
                  ),
                ),
                _buildTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    switch (server.status) {
      case VpnServerStatus.full:
        return const _StatusBadge(
          label: AppStrings.serverStatusFull,
          background: AppColors.warningBg,
          foreground: AppColors.warning,
        );
      case VpnServerStatus.down:
        return const _StatusBadge(
          label: AppStrings.serverStatusDown,
          background: AppColors.surfaceAlt,
          foreground: AppColors.textSecondary,
        );
      case VpnServerStatus.active:
        if (!isSelected) {
          return const SizedBox(width: 22);
        }
        return const Icon(LucideIcons.check, size: 22, color: AppColors.primary);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space1,
        horizontal: AppSpacing.space2,
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
