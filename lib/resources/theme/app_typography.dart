import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 디자인 토큰 — 타이포그래피 (단일 출처). `design.pen`의 스케일과 대응.
///
/// 참고: 디자인은 Inter를 지정하나, Inter는 한글 글리프가 없고 앱은 한국어 우선이라
/// 폰트를 별도로 번들하지 않고 시스템 기본 폰트를 쓴다(한글이 각 OS의 한글 폰트로
/// 자연스럽게 렌더링됨). 크기·굵기·행간만 토큰으로 고정한다.
abstract final class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
