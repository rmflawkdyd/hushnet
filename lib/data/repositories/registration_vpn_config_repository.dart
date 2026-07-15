import '../../domain/services/connection_config_builder.dart';
import '../models/vpn_server.dart';
import '../models/wireguard_config.dart';
import 'server_directory_repository.dart';
import 'vpn_config_repository.dart';

/// 선택한 서버에 기기 공개키를 등록해 연결 설정을 만든다.
///
/// 선택이 없거나 선택한 서버를 더 이상 쓸 수 없으면 첫 번째 연결 가능 서버로 대체한다.
class RegistrationVpnConfigRepository implements VpnConfigRepository {
  RegistrationVpnConfigRepository({
    required ServerDirectoryRepository serverDirectoryRepository,
    required ConnectionConfigBuilder connectionConfigBuilder,
    required Future<String?> Function() selectedServerId,
  }) : _serverDirectoryRepository = serverDirectoryRepository,
       _connectionConfigBuilder = connectionConfigBuilder,
       _selectedServerId = selectedServerId;

  final ServerDirectoryRepository _serverDirectoryRepository;
  final ConnectionConfigBuilder _connectionConfigBuilder;
  final Future<String?> Function() _selectedServerId;

  @override
  Future<WireGuardConfig?> getConfig() async {
    final servers = await _serverDirectoryRepository.getServers();
    final selectable = servers
        .where((server) => server.isSelectable)
        .toList(growable: false);
    if (selectable.isEmpty) {
      return null;
    }
    return _connectionConfigBuilder.buildFor(
      _resolveServer(selectable, await _selectedServerId()),
    );
  }

  VpnServer _resolveServer(List<VpnServer> selectable, String? selectedId) {
    if (selectedId == null) {
      return selectable.first;
    }
    return selectable.firstWhere(
      (server) => server.id == selectedId,
      orElse: () => selectable.first,
    );
  }
}
