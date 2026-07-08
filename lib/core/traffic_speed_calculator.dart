import '../data/models/vpn_traffic.dart';

/// 플러그인이 보내는 누적 총량(`totalDownload`/`totalUpload`, KB)의 차분으로
/// 다운로드·업로드 속도(bytes/s)를 계산한다.
///
/// 플러그인의 `downloadSpeed`/`uploadSpeed`는 쓰지 않는다 — 네이티브 모니터가
/// 중복 실행되며 공유 변수 경쟁으로 0.0이 섞여 나오기 때문. 총량은 매 tick의
/// 실제 카운터 값이라 경쟁의 영향을 받지 않아 신뢰할 수 있다.
class TrafficSpeedCalculator {
  /// 중복 모니터가 거의 동시에 방출하는 샘플(dt≈0)은 나눗셈이 튀므로 무시하고
  /// 직전 속도를 유지한다. 이보다 짧은 간격의 샘플은 새 기준으로 삼지 않는다.
  static const Duration _minSampleInterval = Duration(milliseconds: 500);

  double? _previousDownloadKilobytes;
  double? _previousUploadKilobytes;
  DateTime? _previousSampleTime;
  double _lastDownloadBytesPerSecond = 0;
  double _lastUploadBytesPerSecond = 0;

  VpnTraffic addSnapshot(Map<String, dynamic> snapshot, DateTime sampledAt) {
    final downloadKilobytes = _toDouble(snapshot['totalDownload']);
    final uploadKilobytes = _toDouble(snapshot['totalUpload']);
    final duration = snapshot['duration']?.toString() ?? '00:00:00';

    final previousSampleTime = _previousSampleTime;
    if (previousSampleTime == null) {
      _rememberSample(downloadKilobytes, uploadKilobytes, sampledAt);
      return VpnTraffic(
        downloadBytesPerSecond: 0,
        uploadBytesPerSecond: 0,
        duration: duration,
      );
    }

    final elapsedSeconds =
        sampledAt.difference(previousSampleTime).inMilliseconds / 1000;
    if (elapsedSeconds < _minSampleInterval.inMilliseconds / 1000) {
      return VpnTraffic(
        downloadBytesPerSecond: _lastDownloadBytesPerSecond,
        uploadBytesPerSecond: _lastUploadBytesPerSecond,
        duration: duration,
      );
    }

    _lastDownloadBytesPerSecond = _bytesPerSecond(
      downloadKilobytes,
      _previousDownloadKilobytes!,
      elapsedSeconds,
    );
    _lastUploadBytesPerSecond = _bytesPerSecond(
      uploadKilobytes,
      _previousUploadKilobytes!,
      elapsedSeconds,
    );
    _rememberSample(downloadKilobytes, uploadKilobytes, sampledAt);

    return VpnTraffic(
      downloadBytesPerSecond: _lastDownloadBytesPerSecond,
      uploadBytesPerSecond: _lastUploadBytesPerSecond,
      duration: duration,
    );
  }

  void _rememberSample(
    double downloadKilobytes,
    double uploadKilobytes,
    DateTime sampledAt,
  ) {
    _previousDownloadKilobytes = downloadKilobytes;
    _previousUploadKilobytes = uploadKilobytes;
    _previousSampleTime = sampledAt;
  }

  /// 재연결로 카운터가 리셋되면 차분이 음수가 되므로 0으로 막는다.
  double _bytesPerSecond(
    double currentKilobytes,
    double previousKilobytes,
    double elapsedSeconds,
  ) {
    final deltaKilobytes = currentKilobytes - previousKilobytes;
    if (deltaKilobytes <= 0) return 0;
    return deltaKilobytes * 1024 / elapsedSeconds;
  }

  static double _toDouble(Object? value) => value is num ? value.toDouble() : 0;
}
