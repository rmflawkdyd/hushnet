import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';

/// Atom — 국가 국기 (design.pen `Flag/JP`·`Flag/US`).
///
/// 시스템 이모지 폰트에 의존하면 국기 글리프가 없는 기기에서 국가코드 글자 박스로
/// 렌더링되므로, 번들한 SVG 에셋을 쓴다. 에셋이 없는 국가는 국가코드 배지로 대체한다.
class FlagIcon extends StatelessWidget {
  const FlagIcon({super.key, required this.countryCode, this.width = 24});

  static const Set<String> _bundledCountryCodes = {'JP', 'US', 'KR'};

  final String countryCode;
  final double width;

  double get _height => width * 3 / 4;

  bool get _hasAsset =>
      _bundledCountryCodes.contains(countryCode.toUpperCase());

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm - 1),
      child: Container(
        width: width,
        height: _height,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.sm - 1),
        ),
        alignment: Alignment.center,
        child: _hasAsset ? _buildFlag() : _buildCodeBadge(),
      ),
    );
  }

  Widget _buildFlag() {
    return SvgPicture.asset(
      'assets/flags/${countryCode.toLowerCase()}.svg',
      width: width,
      height: _height,
      fit: BoxFit.cover,
    );
  }

  Widget _buildCodeBadge() {
    return ColoredBox(
      color: AppColors.surfaceAlt,
      child: SizedBox(
        width: width,
        height: _height,
        child: Center(
          child: Text(
            countryCode.toUpperCase(),
            style: AppTypography.label.copyWith(
              fontSize: width * 0.4,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
