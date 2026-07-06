import '../models/wireguard_config.dart';

const String _serverName = String.fromEnvironment('SERVER_NAME');
const String _serverEndpoint = String.fromEnvironment('SERVER_ENDPOINT');
const String _clientAddress = String.fromEnvironment('CLIENT_ADDRESS');
const String _dns = String.fromEnvironment('DNS');
const String _allowedIps = String.fromEnvironment('ALLOWED_IPS');
const String _clientPrivateKey = String.fromEnvironment('CLIENT_PRIVATE_KEY');
const String _serverPublicKey = String.fromEnvironment('SERVER_PUBLIC_KEY');
const String _presharedKey = String.fromEnvironment('PRESHARED_KEY');

const bool hushnetBundledConfigIsReady =
    _serverEndpoint != '' &&
    _clientAddress != '' &&
    _dns != '' &&
    _allowedIps != '' &&
    _clientPrivateKey != '' &&
    _serverPublicKey != '' &&
    _presharedKey != '';

const WireGuardConfig hushnetBundledConfig = WireGuardConfig(
  name: _serverName,
  serverAddress: _serverEndpoint,
  wgQuickConfig: _wgQuickConfig,
);

const String _wgQuickConfig = '''
[Interface]
PrivateKey = $_clientPrivateKey
Address = $_clientAddress
DNS = $_dns

[Peer]
PublicKey = $_serverPublicKey
PresharedKey = $_presharedKey
Endpoint = $_serverEndpoint
AllowedIPs = $_allowedIps
''';
