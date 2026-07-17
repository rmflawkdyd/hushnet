import 'package:flutter_test/flutter_test.dart';
import 'package:hushnet_flutter/data/models/vpn_server.dart';
import 'package:hushnet_flutter/data/repositories/cached_server_directory_repository.dart';
import 'package:hushnet_flutter/data/repositories/server_directory_repository.dart';
import 'package:hushnet_flutter/data/repositories/server_list_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDirectory implements ServerDirectoryRepository {
  _FakeDirectory({this.servers, this.error});

  final List<VpnServer>? servers;
  final Object? error;
  int callCount = 0;

  @override
  Future<List<VpnServer>> getServers() async {
    callCount += 1;
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return servers ?? const [];
  }
}

const _jp = VpnServer(
  id: 'jp-oracle-1',
  country: '일본',
  countryCode: 'JP',
  endpoint: 'jp.example:51820',
  registerUrl: 'https://jp.example',
  serverPublicKey: 'server-public',
  dns: '1.1.1.1',
  allowedIps: '0.0.0.0/0, ::/0',
  keyVersion: 1,
  status: VpnServerStatus.active,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('수신에 성공하면 목록을 캐시에 저장한다', () async {
    final repository = CachedServerDirectoryRepository(
      remote: _FakeDirectory(servers: const [_jp]),
    );

    await repository.getServers();

    const cache = ServerListCache();
    final cached = await cache.load();
    expect(cached.single.id, 'jp-oracle-1');
  });

  test('수신에 실패해도 캐시가 있으면 캐시를 돌려준다', () async {
    await const ServerListCache().save(const [_jp]);
    final repository = CachedServerDirectoryRepository(
      remote: _FakeDirectory(error: StateError('offline')),
    );

    final servers = await repository.getServers();

    expect(servers.single.id, 'jp-oracle-1');
  });

  test('수신에 실패하고 캐시도 없으면 예외를 그대로 던진다', () async {
    final repository = CachedServerDirectoryRepository(
      remote: _FakeDirectory(error: StateError('offline')),
    );

    expect(repository.getServers(), throwsStateError);
  });

  test('빈 목록을 받으면 기존 캐시를 덮어쓰지 않는다', () async {
    await const ServerListCache().save(const [_jp]);
    final repository = CachedServerDirectoryRepository(
      remote: _FakeDirectory(servers: const []),
    );

    final servers = await repository.getServers();

    expect(servers, isEmpty);
    expect((await const ServerListCache().load()).single.id, 'jp-oracle-1');
  });
}
