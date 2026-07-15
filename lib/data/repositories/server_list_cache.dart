import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/preference_keys.dart';
import '../models/vpn_server.dart';

/// 마지막으로 성공한 서버 목록을 로컬에 보관한다.
///
/// 디자인이 로딩·캐시폴백 시트를 두지 않는 전제 — 시트는 저장된 목록으로 즉시 열리고,
/// 갱신에 실패해도 저장된 목록을 그대로 보여준다.
class ServerListCache {
  const ServerListCache();

  Future<void> save(List<VpnServer> servers) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      servers.map((server) => server.toJson()).toList(growable: false),
    );
    await preferences.setString(PreferenceKeys.cachedServerList, encoded);
  }

  Future<List<VpnServer>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(PreferenceKeys.cachedServerList);
    if (encoded == null || encoded.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map((entry) => VpnServer.fromJson(entry as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      await preferences.remove(PreferenceKeys.cachedServerList);
      return const [];
    }
  }
}
