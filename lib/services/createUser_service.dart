import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../config/service_response.dart';

class CreateUserService {
  CreateUserService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ServiceResponse<dynamic>> createUser(
    String firstName,
    String lastName,
    String email,
    String password,
    String role,
    String city,
    String state,
    String? profession,
    String? studyArea,
    String? biography,
    String? phoneNumber,
    String? linkedIn,
    String? investorType,
    String? companyName,
    String? position,
    String? companyWebsite,
  ) async {
    final apiUrl = dotenv.env['API_URL']?.trim();

    if (apiUrl == null || apiUrl.isEmpty) {
      return const ServiceResponse(
        success: false,
        message: 'It was not possible to access the API.',
      );
    }

    try {
      final payload = <String, dynamic>{
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password,
        'role': role.trim().toUpperCase(),
        'city': city.trim(),
        'state': state.trim(),
      };

      void addOptional(String key, String? value) {
        final normalized = value?.trim();
        if (normalized != null && normalized.isNotEmpty) {
          payload[key] = normalized;
        }
      }

      addOptional('profession', profession);
      addOptional('studyArea', studyArea);
      addOptional('biography', biography);
      addOptional('phoneNumber', phoneNumber);
      addOptional('linkedIn', linkedIn);
      addOptional('investorType', investorType?.toUpperCase());
      addOptional('companyName', companyName);
      addOptional('position', position);
      addOptional('companyWebsite', companyWebsite);

      final response = await _client
          .post(
            Uri.parse('${apiUrl}/users'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ServiceResponse(
          success: true,
          data: _dataFromResponse(response),
        );
      }

      return ServiceResponse(
        success: false,
        message: _messageFromResponse(response) ?? 'Could not create account.',
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
