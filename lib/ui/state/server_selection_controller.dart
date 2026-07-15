import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/vpn_server.dart';
import '../../data/repositories/cached_server_directory_repository.dart';
import '../../data/repositories/selected_server_store.dart';
import '../../data/repositories/server_directory_repository.dart';

const String _directoryUrl = String.fromEnvironment(
  'HUSHNET_DIRECTORY_URL',
  defaultValue: 'https://hushnet-servers.mytjdcjf.workers.dev/servers.json',
);

final selectedServerStoreProvider = Provider<SelectedServerStore>(
  (ref) => const SelectedServerStore(),
);

final serverDirectoryRepositoryProvider =
    Provider<CachedServerDirectoryRepository>((ref) {
      return CachedServerDirectoryRepository(
        remote: HttpServerDirectoryRepository(directoryUrl: _directoryUrl),
      );
    });

/// 서버 목록 — 캐시 우선.
///
/// 저장된 목록이 있으면 그것으로 즉시 화면을 채우고 뒤에서 조용히 갱신한다. 갱신에
/// 실패해도 저장된 목록을 유지한다. 그래서 시트에는 로딩·캐시폴백 화면이 없다.
class ServerListNotifier extends AsyncNotifier<List<VpnServer>> {
  CachedServerDirectoryRepository get _repository =>
      ref.read(serverDirectoryRepositoryProvider);

  @override
  Future<List<VpnServer>> build() async {
    final cached = await _repository.loadCached();
    if (cached.isEmpty) {
      return _repository.getServers();
    }
    _refreshInBackground();
    return cached;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repository.getServers);
  }

  /// 갱신 실패는 조용히 삼킨다 — 이미 보여주고 있는 저장된 목록을 그대로 둔다.
  void _refreshInBackground() {
    unawaited(
      _repository
          .getServers()
          .then((servers) {
            if (ref.mounted) {
              state = AsyncValue.data(servers);
            }
          })
          .onError((_, _) {}),
    );
  }
}

final serverListProvider =
    AsyncNotifierProvider<ServerListNotifier, List<VpnServer>>(
      ServerListNotifier.new,
    );

/// 선택한 서버 id — 저장된 값을 읽고, 선택 시 저장한다.
class SelectedServerIdNotifier extends AsyncNotifier<String?> {
  SelectedServerStore get _store => ref.read(selectedServerStoreProvider);

  @override
  Future<String?> build() => _store.load();

  Future<void> select(String serverId) async {
    await _store.save(serverId);
    state = AsyncValue.data(serverId);
  }

  Future<void> clear() async {
    await _store.clear();
    state = const AsyncValue.data(null);
  }
}

final selectedServerIdProvider =
    AsyncNotifierProvider<SelectedServerIdNotifier, String?>(
      SelectedServerIdNotifier.new,
    );

/// 현재 서버 — 선택한 서버가 목록에 없으면(사라짐) 첫 번째 연결 가능 서버로 대체한다.
final currentServerProvider = Provider<VpnServer?>((ref) {
  final servers = ref.watch(serverListProvider).asData?.value ?? const [];
  final selectable = servers
      .where((server) => server.isSelectable)
      .toList(growable: false);
  if (selectable.isEmpty) {
    return null;
  }
  final selectedId = ref.watch(selectedServerIdProvider).asData?.value;
  if (selectedId == null) {
    return selectable.first;
  }
  return selectable.firstWhere(
    (server) => server.id == selectedId,
    orElse: () => selectable.first,
  );
});

/// 선택한 서버가 목록에서 사라졌는지 — Home이 이 신호를 보고 스낵바를 띄운다.
final selectedServerVanishedProvider = Provider<bool>((ref) {
  final servers = ref.watch(serverListProvider).asData?.value;
  final selectedId = ref.watch(selectedServerIdProvider).asData?.value;
  if (servers == null || servers.isEmpty || selectedId == null) {
    return false;
  }
  return !servers.any(
    (server) => server.id == selectedId && server.isSelectable,
  );
});
