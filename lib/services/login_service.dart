import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../config/service_response.dart';
import '../config/token_storage.dart';

class LoginService {
  LoginService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ServiceResponse<dynamic>> login(String email, String password) async {
    final apiUrl = dotenv.env['API_URL']?.trim();

    if (apiUrl == null || apiUrl.isEmpty) {
      return const ServiceResponse(
        success: false,
        message: 'It was not possible to access the API.',
      );
    }

    try {
      final response = await _client
          .post(
            Uri.parse('${apiUrl}/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _dataFromResponse(response);
        final token = _tokenFromData(data);

        if (token == null) {
          return const ServiceResponse(
            success: false,
            message: 'The login response did not contain an access token.',
          );
        }

        await TokenStorage.saveToken(token);

        return ServiceResponse(success: true, data: data);
      }

      return ServiceResponse(
        success: false,
        message: _messageFromResponse(response) ?? 'Email or password invalid.',
      );
    } catch (_) {
      return const ServiceResponse(
        success: false,
        message: 'It was not possible to access the API. Try again.',
      );
    }
  }

  String? _tokenFromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final key in [
        'accessToken',
        'access_token',
        'token',
        'bearerToken',
      ]) {
        final value = data[key];
        if (value is String && value.isNotEmpty) return value;
      }

      for (final value in data.values) {
        final token = _tokenFromData(value);
        if (token != null) return token;
      }
    }

    if (data is List) {
      for (final value in data) {
        final token = _tokenFromData(value);
        if (token != null) return token;
      }
    }

    return null;
  }

  dynamic _dataFromResponse(http.Response response) {
    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  String? _messageFromResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final message = body['message'] ?? body['error'];
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {}
    return null;
  }
}
