import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/vpn_server.dart';

abstract class ServerDirectoryRepository {
  Future<List<VpnServer>> getServers();
}

class HttpServerDirectoryRepository implements ServerDirectoryRepository {
  HttpServerDirectoryRepository({required this.directoryUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String directoryUrl;
  final http.Client _client;

  @override
  Future<List<VpnServer>> getServers() async {
    final response = await _client.get(Uri.parse(directoryUrl));
    if (response.statusCode != 200) {
      throw StateError('server directory returned ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final servers = decoded['servers'] as List<dynamic>;
    return servers
        .map((entry) => VpnServer.fromJson(entry as Map<String, dynamic>))
        .toList(growable: false);
  }
}
