import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/traffic_formatters.dart';
import '../../data/models/vpn_traffic.dart';
import '../../domain/entities/vpn_connection_status.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';
import '../atoms/secondary_button.dart';
import '../molecules/status_chip.dart';
import '../organisms/connect_button.dart';
import '../organisms/hushnet_top_bar.dart';
import '../organisms/traffic_stats_card.dart';
import '../state/vpn_controller.dart';
import 'info_page.dart';

enum HomeState { disconnected, connecting, connected, failed }

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  HomeState _resolveState(VpnConnectionStatus status, String? errorMessage) {
    switch (status) {
      case VpnConnectionStatus.error:
        return HomeState.failed;
      case VpnConnectionStatus.connected:
        return HomeState.connected;
      case VpnConnectionStatus.connecting:
      case VpnConnectionStatus.disconnecting:
        return HomeState.connecting;
      case VpnConnectionStatus.disconnected:
        return errorMessage != null ? HomeState.failed : HomeState.disconnected;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(vpnStatusProvider);
    final status =
        statusAsync.asData?.value ?? VpnConnectionStatus.disconnected;
    final errorMessage = ref.watch(vpnControllerProvider);
    final controller = ref.read(vpnControllerProvider.notifier);
    final state = _resolveState(status, errorMessage);

    final traffic = state == HomeState.connected
        ? (ref.watch(vpnTrafficProvider).asData?.value ?? VpnTraffic.zero)
        : VpnTraffic.zero;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space6,
            0,
            AppSpacing.space6,
            AppSpacing.space8,
          ),
          child: Column(
            children: [
              HushnetTopBar(
                leadingSvgAsset: 'assets/icon/hushnet_logo.svg',
                leadingIconColor: AppColors.primary,
                title: AppStrings.appName,
                trailingIcon: LucideIcons.settings,
                onTrailingTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const InfoPage()),
                ),
              ),
              SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusChip(
                      label: _chipLabel(state, traffic),
                      dotColor: _dotColor(state),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    SizedBox(
                      width: 260,
                      child: Text(
                        _caption(state),
                        textAlign: TextAlign.center,
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space6,
                ),
                child: Column(
                  children: [
                    _buildConnectButton(state, controller),
                    const SizedBox(height: AppSpacing.space4),
                    _buildActionUnderButton(state, controller),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space4),
                child: state == HomeState.connected
                    ? TrafficStatsCard(traffic: traffic)
                    : const SizedBox.shrink(),
              ),
              const Spacer(),
              const _FooterInfo(),
            ],
          ),
        ),
      ),
    );
  }

  String _chipLabel(HomeState state, VpnTraffic traffic) {
    switch (state) {
      case HomeState.disconnected:
        return AppStrings.stateDisconnectedChip;
      case HomeState.connecting:
        return AppStrings.stateConnectingChip;
      case HomeState.connected:
        return '${AppStrings.stateConnectedChipPrefix} · '
            '${formatDuration(traffic.duration)}';
      case HomeState.failed:
        return AppStrings.stateFailedChip;
    }
  }

  Color _dotColor(HomeState state) {
    switch (state) {
      case HomeState.disconnected:
        return AppColors.textSecondary;
      case HomeState.connecting:
        return AppColors.primary;
      case HomeState.connected:
        return AppColors.success;
      case HomeState.failed:
        return AppColors.error;
    }
  }

  String _caption(HomeState state) {
    switch (state) {
      case HomeState.disconnected:
        return AppStrings.stateDisconnectedCaption;
      case HomeState.connecting:
        return AppStrings.stateConnectingCaption;
      case HomeState.connected:
        return AppStrings.stateConnectedCaption;
      case HomeState.failed:
        return AppStrings.stateFailedCaption;
    }
  }

  Widget _buildConnectButton(HomeState state, VpnController controller) {
    switch (state) {
      case HomeState.disconnected:
        return ConnectButton(
          icon: LucideIcons.power,
          fillColor: AppColors.surface,
          strokeColor: AppColors.border,
          iconColor: AppColors.textSecondary,
          onTap: controller.connect,
        );
      case HomeState.connecting:
        return ConnectButton(
          icon: LucideIcons.loader,
          fillColor: AppColors.primary,
          strokeColor: AppColors.primary,
          iconColor: AppColors.primaryOn,
          isBusy: true,
          onTap: null,
        );
      case HomeState.connected:
        return ConnectButton(
          icon: LucideIcons.power,
          fillColor: AppColors.primary,
          strokeColor: AppColors.primary,
          iconColor: AppColors.primaryOn,
          onTap: controller.disconnect,
        );
      case HomeState.failed:
        return ConnectButton(
          icon: LucideIcons.power,
          fillColor: AppColors.surface,
          strokeColor: AppColors.error,
          iconColor: AppColors.error,
          onTap: controller.connect,
        );
    }
  }

  Widget _buildActionUnderButton(HomeState state, VpnController controller) {
    switch (state) {
      case HomeState.disconnected:
        return Text(AppStrings.actionConnect, style: AppTypography.bodyStrong);
      case HomeState.connecting:
        return SecondaryButton(
          label: AppStrings.actionCancel,
          onPressed: controller.disconnect,
        );
      case HomeState.connected:
        return Text(
          AppStrings.actionDisconnect,
          style: AppTypography.bodyStrong,
        );
      case HomeState.failed:
        return Text(AppStrings.actionRetry, style: AppTypography.bodyStrong);
    }
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.space1),
        Text(AppStrings.serverLabel, style: AppTypography.caption),
      ],
    );
  }
}
