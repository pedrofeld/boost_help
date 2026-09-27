import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../config/service_response.dart';
import '../config/token_storage.dart';

class CreateProjectService {
  CreateProjectService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<ServiceResponse<dynamic>> createProject({
    required String name,
    required String resume,
    required String description,
    required String obstacles,
    required String city,
    required String state,
    required String sector,
    required List<String> typesOfSupportSought,
  }) async {
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

      final userId = await TokenStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        return const ServiceResponse(
          success: false,
          message: 'User data not found. Please log in again.',
        );
      }

      if (typesOfSupportSought.isEmpty) {
        return const ServiceResponse(
          success: false,
          message: 'Selecione pelo menos um tipo de apoio.',
        );
      }

      final response = await _client
          .post(
            Uri.parse('$apiUrl/projects'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'userId': userId,
              'name': name.trim(),
              'resume': resume.trim(),
              'description': description.trim(),
              'obstacles': obstacles.trim(),
              'city': city.trim(),
              'state': state.trim(),
              'sector': sector,
              'typesOfSupportSought': typesOfSupportSought,
              'status': 'DRAFT',
            }),
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
            'Não foi possível criar o projeto.',
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
