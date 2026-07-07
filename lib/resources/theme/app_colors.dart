import 'package:flutter/material.dart';

/// 디자인 토큰 — 색상 (단일 출처). `design.pen` 변수와 1:1 대응.
/// Phase A 목업은 라이트 테마 기준이므로 라이트 값으로 정의한다.
/// 상태색(success/error/warning)은 점·아이콘 등 비텍스트 그래픽에만 쓴다
/// (흰 배경 위 텍스트 대비 미달 — 디자인 스펙 1장 접근성 원칙).
abstract final class AppColors {
  static const Color bg = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F2F6);
  static const Color border = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF10151A);
  static const Color textSecondary = Color(0xFF5B6472);
  static const Color primary = Color(0xFF0062FF);
  static const Color primaryOn = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFEF3C7);

  /// ConnectButton 그림자 (design.pen: #00000014 ≈ 8% 검정, offset 0,8, blur 24).
  static const Color connectButtonShadow = Color(0x14000000);
}
