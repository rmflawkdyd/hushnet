import 'package:flutter_test/flutter_test.dart';
import 'package:hushnet_flutter/data/models/vpn_server.dart';
import 'package:hushnet_flutter/data/repositories/selected_server_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('VpnServer는 JSON 왕복이 보존된다', () {
    const original = VpnServer(
      id: 'jp-oracle-1',
      country: '일본',
      countryCode: 'JP',
      endpoint: 'jp.example:51820',
      registerUrl: 'https://jp.example',
      serverPublicKey: 'server-public',
      dns: '1.1.1.1',
      allowedIps: '0.0.0.0/0, ::/0',
      keyVersion: 3,
      status: VpnServerStatus.full,
    );

    final restored = VpnServer.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.keyVersion, 3);
    expect(restored.status, VpnServerStatus.full);
  });

  test('알 수 없는 status는 active로 폴백한다', () {
    final server = VpnServer.fromJson({
      'id': 'x',
      'country': '일본',
      'countryCode': 'JP',
      'endpoint': 'jp.example:51820',
      'registerUrl': 'https://jp.example',
      'serverPublicKey': 'server-public',
      'dns': '1.1.1.1',
      'allowedIps': '0.0.0.0/0',
      'keyVersion': 1,
      'status': 'mystery',
    });

    expect(server.status, VpnServerStatus.active);
  });

  group('SelectedServerStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('선택 서버를 저장하고 복원한다', () async {
      const store = SelectedServerStore();

      await store.save('jp-oracle-1');

      expect(await store.load(), 'jp-oracle-1');
    });

    test('clear 후에는 null을 반환한다', () async {
      const store = SelectedServerStore();
      await store.save('jp-oracle-1');

      await store.clear();

      expect(await store.load(), isNull);
    });
  });
}
