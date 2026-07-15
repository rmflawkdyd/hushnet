import 'package:flutter_test/flutter_test.dart';
import 'package:hushnet_flutter/data/models/wireguard_key_pair.dart';
import 'package:hushnet_flutter/data/repositories/device_key_store.dart';
import 'package:hushnet_flutter/data/repositories/secure_key_value_store.dart';
import 'package:hushnet_flutter/domain/services/wireguard_key_generator.dart';

class _InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> _values = {};
  bool throwOnNextRead = false;
  int writeCount = 0;

  @override
  Future<String?> read(String key) async {
    if (throwOnNextRead) {
      throwOnNextRead = false;
      throw StateError('decrypt failure');
    }
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    writeCount++;
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}

class _SequentialKeyGenerator implements WireGuardKeyGenerator {
  int _counter = 0;

  @override
  Future<WireGuardKeyPair> generate() async {
    _counter++;
    return WireGuardKeyPair(
      privateKeyBase64: 'private-$_counter',
      publicKeyBase64: 'public-$_counter',
    );
  }
}

void main() {
  test('처음 호출 시 키를 생성해 저장하고 반환한다', () async {
    final secureStore = _InMemorySecureStore();
    final store = DeviceKeyStore(
      secureStore: secureStore,
      keyGenerator: _SequentialKeyGenerator(),
    );

    final keyPair = await store.loadOrCreate();

    expect(keyPair.privateKeyBase64, 'private-1');
    expect(secureStore.writeCount, 2);
  });

  test('이미 저장된 키가 있으면 재생성하지 않고 그대로 반환한다', () async {
    final secureStore = _InMemorySecureStore();
    final generator = _SequentialKeyGenerator();
    final first = await DeviceKeyStore(
      secureStore: secureStore,
      keyGenerator: generator,
    ).loadOrCreate();

    final second = await DeviceKeyStore(
      secureStore: secureStore,
      keyGenerator: generator,
    ).loadOrCreate();

    expect(second.privateKeyBase64, first.privateKeyBase64);
  });

  test('동시 최초 호출은 단일 생성으로 합쳐진다', () async {
    final secureStore = _InMemorySecureStore();
    final store = DeviceKeyStore(
      secureStore: secureStore,
      keyGenerator: _SequentialKeyGenerator(),
    );

    final results = await Future.wait([
      store.loadOrCreate(),
      store.loadOrCreate(),
      store.loadOrCreate(),
    ]);

    expect(results.map((keyPair) => keyPair.publicKeyBase64).toSet(), {
      'public-1',
    });
  });

  test('읽기 실패 시 키를 재생성한다', () async {
    final secureStore = _InMemorySecureStore()..throwOnNextRead = true;
    final store = DeviceKeyStore(
      secureStore: secureStore,
      keyGenerator: _SequentialKeyGenerator(),
    );

    final keyPair = await store.loadOrCreate();

    expect(keyPair.privateKeyBase64, 'private-1');
  });

  test('resetKey는 기존 키를 지우고 새 키를 생성한다', () async {
    final secureStore = _InMemorySecureStore();
    final store = DeviceKeyStore(
      secureStore: secureStore,
      keyGenerator: _SequentialKeyGenerator(),
    );
    final first = await store.loadOrCreate();

    final regenerated = await store.resetKey();

    expect(regenerated.privateKeyBase64, isNot(first.privateKeyBase64));
  });
}
