/// 트래픽 표기 포맷터 (회신 문서 1·2번).
/// 속도는 소수 1자리로 B/s→KB/s→MB/s→GB/s 자동 전환, 경과 시간은 mm:ss(1시간 이상 h:mm:ss).
String formatSpeed(double bytesPerSecond) {
  const units = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
  var value = bytesPerSecond;
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  return '${value.toStringAsFixed(1)} ${units[unitIndex]}';
}

/// 플러그인 duration("HH:MM:SS")을 사용자가 읽기 쉬운 형태로 재포맷한다.
/// 1시간 미만이면 앞 "00:"을 떼어 mm:ss, 1시간 이상이면 h:mm:ss.
String formatDuration(String? hhmmss) {
  if (hhmmss == null) return '00:00';
  final parts = hhmmss.split(':');
  if (parts.length != 3) return hhmmss;
  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = parts[1].padLeft(2, '0');
  final seconds = parts[2].padLeft(2, '0');
  if (hours > 0) return '$hours:$minutes:$seconds';
  return '$minutes:$seconds';
}
