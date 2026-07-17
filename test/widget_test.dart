import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hushnet_flutter/data/models/vpn_server.dart';
import 'package:hushnet_flutter/data/models/vpn_traffic.dart';
import 'package:hushnet_flutter/domain/entities/vpn_connection_status.dart';
import 'package:hushnet_flutter/resources/strings/app_strings.dart';
import 'package:hushnet_flutter/resources/theme/app_theme.dart';
import 'package:hushnet_flutter/ui/pages/home_page.dart';
import 'package:hushnet_flutter/ui/pages/info_page.dart';
import 'package:hushnet_flutter/ui/pages/permission_gate_page.dart';
import 'package:hushnet_flutter/ui/state/server_selection_controller.dart';
import 'package:hushnet_flutter/ui/state/vpn_controller.dart';

const _servers = [
  VpnServer(
    id: 'jp-oracle-1',
    country: '일본',
    countryCode: 'JP',
    city: '도쿄',
    endpoint: 'jp.example:51820',
    registerUrl: 'https://jp.example',
    serverPublicKey: 'server-public',
    dns: '1.1.1.1',
    allowedIps: '0.0.0.0/0, ::/0',
    keyVersion: 1,
    status: VpnServerStatus.active,
  ),
  VpnServer(
    id: 'us-west-1',
    country: '미국',
    countryCode: 'US',
    city: '서부',
    endpoint: 'us.example:51820',
    registerUrl: 'https://us.example',
    serverPublicKey: 'server-public-us',
    dns: '1.1.1.1',
    allowedIps: '0.0.0.0/0, ::/0',
    keyVersion: 1,
    status: VpnServerStatus.down,
  ),
];

class _StubServerList extends ServerListNotifier {
  _StubServerList(this.servers);

  final List<VpnServer> servers;

  @override
  Future<List<VpnServer>> build() async => servers;
}

class _StubSelectedServerId extends SelectedServerIdNotifier {
  @override
  Future<String?> build() async => null;
}

Widget _homeWith(
  VpnConnectionStatus status, {
  VpnTraffic? traffic,
  List<VpnServer> servers = _servers,
}) {
  return ProviderScope(
    overrides: [
      vpnStatusProvider.overrideWith((ref) => Stream.value(status)),
      vpnTrafficProvider.overrideWith(
        (ref) => Stream.value(traffic ?? VpnTraffic.zero),
      ),
      serverListProvider.overrideWith(() => _StubServerList(servers)),
      selectedServerIdProvider.overrideWith(_StubSelectedServerId.new),
    ],
    child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
  );
}

/// 실제 기기 화면(iPhone 14, 390×844)에서 렌더링을 검증한다.
/// 이 크기에서 레이아웃이 넘치면(overflow) 테스트가 실패한다.
Future<void> _pumpPhone(WidgetTester tester, Widget widget) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(widget);
}

void main() {
  testWidgets('연결 안 됨 상태: 상태칩·연결하기·서버 선택 바가 보인다', (tester) async {
    await _pumpPhone(tester, _homeWith(VpnConnectionStatus.disconnected));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.stateDisconnectedChip), findsOneWidget);
    expect(find.text(AppStrings.actionConnect), findsOneWidget);
    expect(find.text('일본'), findsOneWidget);
    expect(find.text(AppStrings.serverChange), findsOneWidget);
  });

  testWidgets('서버 선택 바를 누르면 목록 시트가 열리고 status가 표시된다', (tester) async {
    await _pumpPhone(tester, _homeWith(VpnConnectionStatus.disconnected));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.serverChange));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.serverSheetTitle), findsOneWidget);
    expect(find.text(AppStrings.serverSheetSubtitle), findsOneWidget);
    expect(find.text('미국'), findsOneWidget);
    expect(find.text(AppStrings.serverStatusDown), findsOneWidget);
  });

  testWidgets('목록이 비면 시트는 중립 문구의 목록 없음을 보여준다', (tester) async {
    await _pumpPhone(
      tester,
      _homeWith(VpnConnectionStatus.disconnected, servers: const []),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.serverChange));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.serverEmptyTitle), findsOneWidget);
    expect(find.text(AppStrings.actionRetry), findsOneWidget);
    expect(find.text(AppStrings.serverSheetSubtitle), findsNothing);
  });

  testWidgets('연결 중 상태: 연결하는 중 칩과 취소가 보인다', (tester) async {
    await _pumpPhone(tester, _homeWith(VpnConnectionStatus.connecting));
    // 스피너 애니메이션이 무한 반복이라 pumpAndSettle 대신 고정 프레임을 진행한다.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(AppStrings.stateConnectingChip), findsOneWidget);
    expect(find.text(AppStrings.actionCancel), findsOneWidget);
  });

  testWidgets('연결됨 상태: 경과시간 칩·해제 라벨·트래픽 통계가 보인다', (tester) async {
    await _pumpPhone(
      tester,
      _homeWith(
        VpnConnectionStatus.connected,
        traffic: const VpnTraffic(
          downloadBytesPerSecond: 1258291,
          uploadBytesPerSecond: 348160,
          duration: '00:02:15',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('${AppStrings.stateConnectedChipPrefix} · 02:15'),
      findsOneWidget,
    );
    expect(find.text(AppStrings.actionDisconnect), findsOneWidget);
    expect(find.text(AppStrings.statDownload), findsOneWidget);
    expect(find.text(AppStrings.statUpload), findsOneWidget);
    expect(find.text('1.2 MB/s'), findsOneWidget);
    expect(find.text('340.0 KB/s'), findsOneWidget);
  });

  testWidgets('연결 실패 상태: 실패 칩과 다시 시도가 보인다', (tester) async {
    await _pumpPhone(tester, _homeWith(VpnConnectionStatus.error));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.stateFailedChip), findsOneWidget);
    expect(find.text(AppStrings.actionRetry), findsOneWidget);
  });

  testWidgets('권한 게이트: 제목·고지 3항목·허용 버튼이 보인다', (tester) async {
    await _pumpPhone(
      tester,
      const ProviderScope(
        child: MaterialApp(home: PermissionGatePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.permissionTitle), findsOneWidget);
    expect(find.text(AppStrings.permissionPointUsage), findsOneWidget);
    expect(find.text(AppStrings.permissionPointScope), findsOneWidget);
    expect(find.text(AppStrings.permissionPointNoLog), findsOneWidget);
    expect(find.text(AppStrings.permissionAllow), findsOneWidget);
  });

  testWidgets('정보 화면: No-log 카드·개인정보처리방침·버전이 보인다', (tester) async {
    await _pumpPhone(
      tester,
      const MaterialApp(home: InfoPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noLogCardTitle), findsOneWidget);
    expect(find.text(AppStrings.privacyPolicy), findsOneWidget);
    expect(
      find.text(AppStrings.versionFooter(AppStrings.appVersion)),
      findsOneWidget,
    );
  });
}
