import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/server_registration.dart';

abstract class RegistrationRepository {
  Future<RegistrationResponse> register(
    String registerBaseUrl,
    RegistrationRequest request,
  );
}

class HttpRegistrationRepository implements RegistrationRepository {
  HttpRegistrationRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<RegistrationResponse> register(
    String registerBaseUrl,
    RegistrationRequest request,
  ) async {
    http.Response response;
    try {
      response = await _client.post(
        Uri.parse('$registerBaseUrl/register'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
    } catch (_) {
      throw const RegistrationException(RegistrationFailureReason.network);
    }

    if (response.statusCode == 200) {
      return RegistrationResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw RegistrationException(
      RegistrationException.reasonForStatus(response.statusCode),
      response.statusCode,
    );
  }
}
