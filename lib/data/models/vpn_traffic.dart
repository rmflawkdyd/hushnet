/// 다운로드·업로드 속도(bytes/s)와 경과 시간을 담는 도메인 값.
/// 속도는 [TrafficSpeedCalculator]가 플러그인 누적 총량의 차분으로 계산한다.
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
}
