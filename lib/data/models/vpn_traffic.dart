/// 플러그인 trafficSnapshot(Map)을 앱 도메인 값으로 감싼 모델.
/// 연결됨 상태에서만 유효하다.
class VpnTraffic {
  const VpnTraffic({
    required this.downloadBytesPerSecond,
    required this.uploadBytesPerSecond,
    required this.duration,
  });

  final double downloadBytesPerSecond;
  final double uploadBytesPerSecond;

  /// 플러그인이 계산한 경과 시간 문자열 ("HH:MM:SS").
  final String duration;

  static const VpnTraffic zero = VpnTraffic(
    downloadBytesPerSecond: 0,
    uploadBytesPerSecond: 0,
    duration: '00:00:00',
  );

  factory VpnTraffic.fromSnapshot(Map<String, dynamic> snapshot) {
    double toDouble(Object? value) =>
        value is num ? value.toDouble() : 0;
    return VpnTraffic(
      downloadBytesPerSecond: toDouble(snapshot['downloadSpeed']),
      uploadBytesPerSecond: toDouble(snapshot['uploadSpeed']),
      duration: snapshot['duration']?.toString() ?? '00:00:00',
    );
  }
}
