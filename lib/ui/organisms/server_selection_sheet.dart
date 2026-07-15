import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/vpn_server.dart';
import '../../resources/strings/app_strings.dart';
import '../../resources/theme/app_colors.dart';
import '../../resources/theme/app_spacing.dart';
import '../../resources/theme/app_typography.dart';
import '../atoms/primary_button.dart';
import '../molecules/server_row.dart';
import '../state/server_selection_controller.dart';

/// Organism — 서버 선택 바텀시트 (design.pen `서버 선택 - 목록`·`서버 선택 - 목록 없음`).
///
/// 상태는 둘뿐이다: 보여줄 목록이 있으면 목록, 없으면 목록 없음. 저장된 목록으로 즉시
/// 열리므로 로딩 화면이 없고, 갱신이 실패해도 저장된 목록을 그대로 두므로 경고 배너도 없다.
class ServerSelectionSheet extends ConsumerWidget {
  const ServerSelectionSheet({super.key, required this.onSelected});

  final void Function(VpnServer server) onSelected;

  static Future<void> show(
    BuildContext context, {
    required void Function(VpnServer server) onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      barrierColor: const Color(0xA60B0F17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (_) => ServerSelectionSheet(onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serverListProvider).asData?.value ?? const [];
    final currentServer = ref.watch(currentServerProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Grabber(),
          if (servers.isEmpty)
            const _EmptyBody()
          else
            _ListBody(
              servers: servers,
              currentServerId: currentServer?.id,
              onSelected: (server) {
                onSelected(server);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.space3,
        bottom: AppSpacing.space2,
      ),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space2,
        horizontal: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(AppStrings.serverSheetTitle, style: AppTypography.heading),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.space1),
            Text(subtitle!, style: AppTypography.caption),
          ],
        ],
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.servers,
    required this.currentServerId,
    required this.onSelected,
  });

  final List<VpnServer> servers;
  final String? currentServerId;
  final void Function(VpnServer server) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SheetHeader(subtitle: AppStrings.serverSheetSubtitle),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.6,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space6,
              AppSpacing.space4,
              AppSpacing.space6,
              AppSpacing.space8,
            ),
            itemCount: servers.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.space2),
            itemBuilder: (_, index) {
              final server = servers[index];
              return ServerRow(
                server: server,
                isSelected: server.id == currentServerId,
                onTap: () => onSelected(server),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 보여줄 목록이 없는 모든 경우 — 빈 목록 / 수신 실패(캐시 없음) / 최초 수신 전.
/// 문구를 중립적으로 둬서 "아직 못 받음"과 "정말 없음"을 함께 덮는다.
class _EmptyBody extends ConsumerWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRefreshing = ref.watch(serverListProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SheetHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space8,
          ),
          child: Column(
            children: [
              const Icon(
                LucideIcons.server,
                size: 32,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                AppStrings.serverEmptyTitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyStrong,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(AppStrings.serverEmptyBody, style: AppTypography.caption),
              const SizedBox(height: AppSpacing.space4),
              PrimaryButton(
                label: AppStrings.actionRetry,
                onPressed: isRefreshing
                    ? null
                    : () => ref.read(serverListProvider.notifier).refresh(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
