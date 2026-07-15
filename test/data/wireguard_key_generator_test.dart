import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hushnet_flutter/domain/services/wireguard_key_generator.dart';

void main() {
  const generator = WireGuardKeyGenerator();

  test('생성한 키는 32바이트 base64 private/public 쌍이다', () async {
    final keyPair = await generator.generate();

    expect(base64.decode(keyPair.privateKeyBase64), hasLength(32));
    expect(base64.decode(keyPair.publicKeyBase64), hasLength(32));
  });

  test('private key는 WireGuard 스칼라 클램핑 규칙을 만족한다', () async {
    final keyPair = await generator.generate();
    final privateKey = base64.decode(keyPair.privateKeyBase64);

    expect(privateKey[0] & 0x07, 0);
    expect(privateKey[31] & 0x80, 0);
    expect(privateKey[31] & 0x40, 0x40);
  });

  test('호출마다 서로 다른 키를 생성한다', () async {
    final first = await generator.generate();
    final second = await generator.generate();

    expect(first.privateKeyBase64, isNot(second.privateKeyBase64));
    expect(first.publicKeyBase64, isNot(second.publicKeyBase64));
  });
}
