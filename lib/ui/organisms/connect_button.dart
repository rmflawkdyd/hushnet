import 'package:flutter/material.dart';

import '../../resources/theme/app_colors.dart';

/// Organism — 원형 연결 버튼 (design.pen `ConnectButton`).
/// fill/stroke/아이콘 색을 상태별로 오버라이드해 4개 상태를 표현한다.
/// [isBusy]이면 아이콘을 회전시켜 진행 중임을 나타낸다.
class ConnectButton extends StatefulWidget {
  const ConnectButton({
    super.key,
    required this.icon,
    required this.fillColor,
    required this.strokeColor,
    required this.iconColor,
    required this.onTap,
    this.isBusy = false,
  });

  final IconData icon;
  final Color fillColor;
  final Color strokeColor;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isBusy;

  static const double diameter = 168;

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _syncSpin();
  }

  @override
  void didUpdateWidget(ConnectButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBusy != oldWidget.isBusy) _syncSpin();
  }

  void _syncSpin() {
    if (widget.isBusy) {
      _spin.repeat();
    } else {
      _spin.stop();
      _spin.reset();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(widget.icon, size: 56, color: widget.iconColor);
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: ConnectButton.diameter,
          height: ConnectButton.diameter,
          decoration: BoxDecoration(
            color: widget.fillColor,
            shape: BoxShape.circle,
            border: Border.all(color: widget.strokeColor, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.connectButtonShadow,
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.isBusy
              ? RotationTransition(turns: _spin, child: icon)
              : icon,
        ),
      ),
    );
  }
}
