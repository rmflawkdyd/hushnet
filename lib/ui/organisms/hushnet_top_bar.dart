import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';

/// Organism — 상단 바 (design.pen `TopBar`).
/// 좌측 아이콘+타이틀, 우측 원형 아이콘 버튼(선택). Home(브랜드)과 정보 화면(뒤로가기)에서 재사용.
///
/// 좌측 심볼은 [leadingSvgAsset](브랜드 로고 SVG) 또는 [leadingIcon](폰트 아이콘) 중
/// 하나로 지정한다. Home은 design.pen과 동일한 shield-check 벡터를 SVG로 쓰고,
/// 정보 화면은 뒤로가기 폰트 아이콘을 쓴다.
class HushnetTopBar extends StatelessWidget {
  const HushnetTopBar({
    super.key,
    this.leadingIcon,
    this.leadingSvgAsset,
    required this.leadingIconColor,
    required this.title,
    this.onLeadingTap,
    this.trailingIcon,
    this.onTrailingTap,
  }) : assert(
         (leadingIcon == null) != (leadingSvgAsset == null),
         'leadingIcon 과 leadingSvgAsset 중 정확히 하나만 지정하세요.',
       );

  final IconData? leadingIcon;
  final String? leadingSvgAsset;
  final Color leadingIconColor;
  final String title;
  final VoidCallback? onLeadingTap;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final leading = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingSvgAsset != null)
          SvgPicture.asset(
            leadingSvgAsset!,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(leadingIconColor, BlendMode.srcIn),
          )
        else
          Icon(leadingIcon, size: 22, color: leadingIconColor),
        const SizedBox(width: AppSpacing.space2),
        Text(title, style: AppTypography.heading),
      ],
    );

    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onLeadingTap != null)
            InkWell(
              onTap: onLeadingTap,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: leading,
            )
          else
            leading,
          if (trailingIcon != null)
            _RightIconButton(icon: trailingIcon!, onTap: onTrailingTap),
        ],
      ),
    );
  }
}

class _RightIconButton extends StatelessWidget {
  const _RightIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
