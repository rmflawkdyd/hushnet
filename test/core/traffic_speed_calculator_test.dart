import 'package:flutter_test/flutter_test.dart';

import 'package:hushnet_flutter/core/traffic_speed_calculator.dart';

Map<String, dynamic> _snapshot({
  required double totalDownloadKilobytes,
  required double totalUploadKilobytes,
  String duration = '00:00:00',
}) {
  return {
    'totalDownload': totalDownloadKilobytes,
    'totalUpload': totalUploadKilobytes,
    'duration': duration,
  };
}

void main() {
  final baseTime = DateTime(2026, 1, 1, 0, 0, 0);

  test('첫 샘플은 기준점만 잡고 속도 0을 반환한다', () {
    final calculator = TrafficSpeedCalculator();

    final traffic = calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 100, totalUploadKilobytes: 50),
      baseTime,
    );

    expect(traffic.downloadBytesPerSecond, 0);
    expect(traffic.uploadBytesPerSecond, 0);
  });

  test('1초 뒤 총량 증가분을 bytes/s로 계산한다', () {
    final calculator = TrafficSpeedCalculator();
    calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 100, totalUploadKilobytes: 50),
      baseTime,
    );

    final traffic = calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 200, totalUploadKilobytes: 80),
      baseTime.add(const Duration(seconds: 1)),
    );

    expect(traffic.downloadBytesPerSecond, 100 * 1024);
    expect(traffic.uploadBytesPerSecond, 30 * 1024);
  });

  test('경과 시간으로 나눠 초당 속도로 환산한다', () {
    final calculator = TrafficSpeedCalculator();
    calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 0, totalUploadKilobytes: 0),
      baseTime,
    );

    final traffic = calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 200, totalUploadKilobytes: 0),
      baseTime.add(const Duration(seconds: 2)),
    );

    expect(traffic.downloadBytesPerSecond, 100 * 1024);
  });

  test('카운터 리셋(음수 차분)은 0으로 막는다', () {
    final calculator = TrafficSpeedCalculator();
    calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 500, totalUploadKilobytes: 500),
      baseTime,
    );

    final traffic = calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 10, totalUploadKilobytes: 10),
      baseTime.add(const Duration(seconds: 1)),
    );

    expect(traffic.downloadBytesPerSecond, 0);
    expect(traffic.uploadBytesPerSecond, 0);
  });

  test('간격이 너무 짧은 샘플은 직전 속도를 유지하고 기준점을 옮기지 않는다', () {
    final calculator = TrafficSpeedCalculator();
    calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 100, totalUploadKilobytes: 0),
      baseTime,
    );
    final firstSpeed = calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 200, totalUploadKilobytes: 0),
      baseTime.add(const Duration(seconds: 1)),
    );

    final skipped = calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 200, totalUploadKilobytes: 0),
      baseTime.add(const Duration(seconds: 1, milliseconds: 10)),
    );
    expect(skipped.downloadBytesPerSecond, firstSpeed.downloadBytesPerSecond);

    final afterSkip = calculator.addSnapshot(
      _snapshot(totalDownloadKilobytes: 300, totalUploadKilobytes: 0),
      baseTime.add(const Duration(seconds: 2)),
    );
    expect(afterSkip.downloadBytesPerSecond, 100 * 1024);
  });

  test('총량 키가 없으면 0으로 처리한다', () {
    final calculator = TrafficSpeedCalculator();

    final traffic = calculator.addSnapshot(const {}, baseTime);

    expect(traffic.downloadBytesPerSecond, 0);
    expect(traffic.uploadBytesPerSecond, 0);
  });
}
