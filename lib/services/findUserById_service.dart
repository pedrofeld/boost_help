import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../config/service_response.dart';
import '../config/token_storage.dart';

class FindUserByIdService {
  FindUserByIdService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<ServiceResponse<dynamic>> findUserById(String id) async {
    final apiUrl = dotenv.env['API_URL']?.trim();

    if (apiUrl == null || apiUrl.isEmpty) {
      return const ServiceResponse(
        success: false,
        message: 'It was not possible to access the API.',
      );
    }

    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const ServiceResponse(
          success: false,
          message: 'Access token not found. Please log in again.',
        );
      }

      final response = await _client
          .get(
            Uri.parse('$apiUrl/users/${Uri.encodeComponent(id)}'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ServiceResponse(
          success: true,
          data: _dataFromResponse(response),
        );
      }

      return ServiceResponse(
        success: false,
        message:
            _messageFromResponse(response) ??
            'Não foi possível buscar os dados do usuário.',
      );
    } catch (_) {
      return const ServiceResponse(
        success: false,
        message: 'It was not possible to access the API. Try again.',
      );
    }
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
