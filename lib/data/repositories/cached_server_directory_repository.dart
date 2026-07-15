import '../models/vpn_server.dart';
import 'server_directory_repository.dart';
import 'server_list_cache.dart';

/// 서버 목록을 받아오되, 성공하면 캐시에 저장하고 실패하면 캐시로 되돌아간다.
///
/// 캐시마저 비어 있을 때만 예외를 다시 던진다 — 이때 UI는 "목록 없음"을 보여준다.
class CachedServerDirectoryRepository implements ServerDirectoryRepository {
  const CachedServerDirectoryRepository({
    required ServerDirectoryRepository remote,
    ServerListCache cache = const ServerListCache(),
  }) : _remote = remote,
       _cache = cache;

  final ServerDirectoryRepository _remote;
  final ServerListCache _cache;

  @override
  Future<List<VpnServer>> getServers() async {
    try {
      final servers = await _remote.getServers();
      if (servers.isNotEmpty) {
        await _cache.save(servers);
      }
      return servers;
    } catch (_) {
      final cached = await _cache.load();
      if (cached.isEmpty) {
        rethrow;
      }
      return cached;
    }
  }

  Future<List<VpnServer>> loadCached() => _cache.load();
}
