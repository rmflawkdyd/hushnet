/// 다운로드·업로드 속도(bytes/s)를 담는 도메인 값.
/// 속도는 [TrafficSpeedCalculator]가 플러그인 누적 총량의 차분으로 계산한다.
/// 연결됨 상태에서만 유효하다. 경과 시간은 트래픽과 분리되어
/// [connectionElapsedProvider]가 로컬 타이머로 계산한다.
class VpnTraffic {
  const VpnTraffic({
    required this.downloadBytesPerSecond,
    required this.uploadBytesPerSecond,
  });

  final double downloadBytesPerSecond;
  final double uploadBytesPerSecond;

  static const VpnTraffic zero = VpnTraffic(
    downloadBytesPerSecond: 0,
    uploadBytesPerSecond: 0,
  );
}
