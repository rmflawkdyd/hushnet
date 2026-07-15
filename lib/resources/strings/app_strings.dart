/// 문구 단일 출처 (디자인 스펙 4장 — 쉬운 말). 코드에 하드코딩하지 않는다.
abstract final class AppStrings {
  static const String appName = 'Hushnet';
  static const String appVersion = '1.0.0';

  // 서버 선택 (Phase B — 다국가)
  static const String serverChange = '변경';
  static const String serverNotSelected = '서버를 고르지 않았어요';
  static const String serverSheetTitle = '서버 선택';
  static const String serverSheetSubtitle = '연결할 국가를 골라주세요';
  static const String serverStatusFull = '혼잡';
  static const String serverStatusDown = '점검 중';

  /// 목록 없음 — 빈 목록 / 수신 실패(캐시 없음) / 최초 수신 전을 함께 덮으므로
  /// "서버가 없다"고 단정하지 않는다.
  static const String serverEmptyTitle = '서버 목록을 준비하고 있어요';
  static const String serverEmptyBody = '잠시 후 다시 시도해 주세요';
  static const String serverVanished = '선택한 서버를 더 이상 쓸 수 없어 기본 서버로 바꿨어요';

  // 스플래시
  static const String splashTagline = '기록 없이, 켜면 바로 보호돼요';

  // 권한 게이트
  static const String permissionTitle = '안전하게 연결하려면\nVPN 권한이 필요해요';
  static const String permissionPointUsage = '이 권한은 VPN 연결에만 사용해요';
  static const String permissionPointScope = '모든 인터넷 연결이 암호화 서버를 거쳐요';
  static const String permissionPointNoLog = '이용 기록은 남기지 않아요';
  static const String permissionAllow = '권한 허용하기';
  static const String permissionDenied = '권한을 허용해야 앱을 사용할 수 있어요';

  // Home — 연결 안 됨
  static const String stateDisconnectedChip = '연결되지 않음';
  static const String stateDisconnectedCaption = '버튼을 눌러 안전한 연결을 시작하세요';
  static const String actionConnect = '연결하기';

  // Home — 연결 중
  static const String stateConnectingChip = '연결하는 중...';
  static const String stateConnectingCaption = '잠시만 기다려 주세요';
  static const String actionCancel = '취소';

  // Home — 연결됨
  static const String stateConnectedChipPrefix = '연결됨';
  static const String stateConnectedCaption = '안전하게 보호되고 있어요';
  static const String actionDisconnect = '연결 해제하기';
  static const String statDownload = '다운로드';
  static const String statUpload = '업로드';

  // Home — 연결 실패
  static const String stateFailedChip = '연결에 실패했어요';
  static const String stateFailedCaption = '잠시 후 다시 시도해 주세요. 계속 실패하면 문의해 주세요.';
  static const String actionRetry = '다시 시도';

  // 내부 오류 신호 (Home의 "연결 실패" 상태로 표현되며, 문구 자체는 화면에 노출되지 않음)
  static const String noConfig = '연결할 서버 설정이 아직 없어요.';
  static const String connectFailed = '연결에 실패했어요. 다시 시도해 주세요.';
  static const String disconnectFailed = '연결 해제에 실패했어요.';

  // 정보 화면
  static const String infoTitle = '정보';
  static const String noLogCardTitle = '이용 기록을 남기지 않아요';
  static const String noLogCardBody =
      '어떤 사이트에 접속했는지, 무엇을 했는지 기록하거나 저장하지 않아요.';
  static const String privacyPolicy = '개인정보처리방침';
  static String versionFooter(String version) => 'Hushnet 버전 $version';

  /// 개인정보처리방침 URL — 배포 전 확정(자리표시자 이음새, 회신 문서 5번).
  static const String privacyPolicyUrl = 'https://hushnet.example.com/privacy';
}
