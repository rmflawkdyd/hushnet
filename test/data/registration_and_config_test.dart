import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:hushnet_flutter/data/models/server_registration.dart';
import 'package:hushnet_flutter/data/models/vpn_server.dart';
import 'package:hushnet_flutter/data/models/wireguard_key_pair.dart';
import 'package:hushnet_flutter/data/repositories/device_key_store.dart';
import 'package:hushnet_flutter/data/repositories/registration_repository.dart';
import 'package:hushnet_flutter/data/repositories/secure_key_value_store.dart';
import 'package:hushnet_flutter/domain/services/attestation_service.dart';
import 'package:hushnet_flutter/domain/services/connection_config_builder.dart';
import 'package:hushnet_flutter/domain/services/wireguard_config_assembler.dart';
import 'package:hushnet_flutter/domain/services/wireguard_key_generator.dart';

class _FakeRegistrationRepository implements RegistrationRepository {
  RegistrationRequest? lastRequest;
  String? lastRegisterBaseUrl;

  @override
  Future<RegistrationResponse> register(
    String registerBaseUrl,
    RegistrationRequest request,
  ) async {
    lastRegisterBaseUrl = registerBaseUrl;
    lastRequest = request;
    return const RegistrationResponse(
      assignedAddress: '10.66.66.2/32',
      dns: '1.1.1.1',
      keyVersion: 1,
    );
  }
}

class _StubAttestationProvider implements AttestationProvider {
  const _StubAttestationProvider(this.token);

  final String token;

  @override
  Future<String?> requestAttestationToken() async => token;
}

class _InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

class _FixedKeyGenerator implements WireGuardKeyGenerator {
  @override
  Future<WireGuardKeyPair> generate() async => const WireGuardKeyPair(
    privateKeyBase64: 'client-private',
    publicKeyBase64: 'client-public',
  );
}

const _server = VpnServer(
  id: 'jp-oracle-1',
  country: '일본',
  countryCode: 'JP',
  endpoint: 'jp.example:51820',
  registerUrl: 'https://jp.example',
  serverPublicKey: 'server-public',
  dns: '1.1.1.1',
  allowedIps: '0.0.0.0/0, ::/0',
  keyVersion: 1,
  status: VpnServerStatus.active,
);

void main() {
  group('WireGuardConfigAssembler', () {
    test('조립한 config에 키·배정 IP·서버 정보가 담긴다', () {
      const assembler = WireGuardConfigAssembler();

      final config = assembler.assemble(
        server: _server,
        keyPair: const WireGuardKeyPair(
          privateKeyBase64: 'client-private',
          publicKeyBase64: 'client-public',
        ),
        registration: const RegistrationResponse(
          assignedAddress: '10.66.66.5/32',
          dns: '1.1.1.1',
          keyVersion: 1,
        ),
      );

      expect(config.wgQuickConfig, contains('PrivateKey = client-private'));
      expect(config.wgQuickConfig, contains('Address = 10.66.66.5/32'));
      expect(config.wgQuickConfig, contains('PublicKey = server-public'));
      expect(config.wgQuickConfig, contains('Endpoint = jp.example:51820'));
      expect(config.wgQuickConfig, isNot(contains('PresharedKey')));
    });

    test('presharedKey가 있으면 config에 포함된다', () {
      const assembler = WireGuardConfigAssembler();

      final config = assembler.assemble(
        server: _server,
        keyPair: const WireGuardKeyPair(
          privateKeyBase64: 'client-private',
          publicKeyBase64: 'client-public',
        ),
        registration: const RegistrationResponse(
          assignedAddress: '10.66.66.5/32',
          dns: '1.1.1.1',
          keyVersion: 1,
          presharedKey: 'psk-value',
        ),
      );

      expect(config.wgQuickConfig, contains('PresharedKey = psk-value'));
    });
  });

  test('ConnectionConfigBuilder는 키 생성→등록→조립을 연결한다', () async {
    final keyStore = DeviceKeyStore(
      secureStore: _InMemorySecureStore(),
      keyGenerator: _FixedKeyGenerator(),
    );
    final builder = ConnectionConfigBuilder(
      deviceKeyStore: keyStore,
      registrationRepository: _FakeRegistrationRepository(),
    );

    final config = await builder.buildFor(_server);

    expect(config.serverAddress, 'jp.example:51820');
    expect(config.wgQuickConfig, contains('PrivateKey = client-private'));
    expect(config.wgQuickConfig, contains('Address = 10.66.66.2/32'));
    expect(config.wgQuickConfig, contains('PublicKey = server-public'));
  });

  test('선택한 서버의 registerUrl로 등록 요청을 보낸다', () async {
    final repository = _FakeRegistrationRepository();
    final builder = ConnectionConfigBuilder(
      deviceKeyStore: DeviceKeyStore(
        secureStore: _InMemorySecureStore(),
        keyGenerator: _FixedKeyGenerator(),
      ),
      registrationRepository: repository,
    );

    await builder.buildFor(_server);

    expect(repository.lastRegisterBaseUrl, 'https://jp.example');
  });

  test('기본 provider는 attestation 토큰 없이 등록한다', () async {
    final repository = _FakeRegistrationRepository();
    final builder = ConnectionConfigBuilder(
      deviceKeyStore: DeviceKeyStore(
        secureStore: _InMemorySecureStore(),
        keyGenerator: _FixedKeyGenerator(),
      ),
      registrationRepository: repository,
    );

    await builder.buildFor(_server);

    expect(repository.lastRequest?.attestationToken, isNull);
  });

  test('provider가 준 attestation 토큰을 등록 요청에 싣는다', () async {
    final repository = _FakeRegistrationRepository();
    final builder = ConnectionConfigBuilder(
      deviceKeyStore: DeviceKeyStore(
        secureStore: _InMemorySecureStore(),
        keyGenerator: _FixedKeyGenerator(),
      ),
      registrationRepository: repository,
      attestationProvider: const _StubAttestationProvider('token-123'),
    );

    await builder.buildFor(_server);

    expect(repository.lastRequest?.attestationToken, 'token-123');
  });

  test('NoopAttestationProvider는 null 토큰을 반환한다', () async {
    const provider = NoopAttestationProvider();

    expect(await provider.requestAttestationToken(), isNull);
  });

  test('StaticAttestationProvider는 주입된 토큰을 그대로 반환한다', () async {
    const provider = StaticAttestationProvider('dev-token');

    expect(await provider.requestAttestationToken(), 'dev-token');
  });

  group('HttpRegistrationRepository', () {
    test('200 응답을 RegistrationResponse로 파싱한다', () async {
      final client = MockClient((request) async {
        expect(request.url.path, endsWith('/register'));
        return http.Response(
          jsonEncode({
            'assignedAddress': '10.66.66.9/32',
            'dns': '1.1.1.1',
            'keyVersion': 2,
          }),
          200,
        );
      });
      final repository = HttpRegistrationRepository(client: client);

      final response = await repository.register(
        'https://node.example',
        const RegistrationRequest(serverId: 's', clientPublicKey: 'k'),
      );

      expect(response.assignedAddress, '10.66.66.9/32');
      expect(response.keyVersion, 2);
    });

    test('403은 attestationRejected로 매핑된다', () async {
      final client = MockClient((_) async => http.Response('', 403));
      final repository = HttpRegistrationRepository(client: client);

      expect(
        () => repository.register(
          'https://node.example',
          const RegistrationRequest(serverId: 's', clientPublicKey: 'k'),
        ),
        throwsA(
          isA<RegistrationException>().having(
            (exception) => exception.reason,
            'reason',
            RegistrationFailureReason.attestationRejected,
          ),
        ),
      );
    });

    test('503은 serverUnavailable로 매핑된다', () async {
      final client = MockClient((_) async => http.Response('', 503));
      final repository = HttpRegistrationRepository(client: client);

      expect(
        () => repository.register(
          'https://node.example',
          const RegistrationRequest(serverId: 's', clientPublicKey: 'k'),
        ),
        throwsA(
          isA<RegistrationException>().having(
            (exception) => exception.reason,
            'reason',
            RegistrationFailureReason.serverUnavailable,
          ),
        ),
      );
    });
  });
}
