import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pos_terminal/config.dart';
import 'package:result_dart/result_dart.dart';

final dio = Dio();

class ValidateResponse {
  final bool ok;
  final String role;

  ValidateResponse({required this.ok, required this.role});

  factory ValidateResponse.fromJson(Map<String, dynamic> json) {
    return ValidateResponse(
      ok: json['ok'] as bool,
      role: json['role'] as String,
    );
  }
}

AsyncResult<ValidateResponse> validateSupervisor({
  required String email,
  required String password,
}) async {
  try {
    debugPrint("Attempting supervisor validation with email: $email");
    final response = await dio.post(
      "$API_URL/validate",
      data: {"email": email, "password": password},
    );

    debugPrint("VALIDATE RESPONSE: ${response.data}");

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data['ok'] == true) {
        final validateResponse = ValidateResponse.fromJson(data);
        return validateResponse.toSuccess();
      } else {
        return Exception(data['reason'] ?? 'Validation failed').toFailure();
      }
    } else {
      return Exception('Unexpected response format').toFailure();
    }
  } catch (e) {
    debugPrint("Validation error: $e");
    if (e is DioException) {
      String errorMessage = 'Validation failed';
      if (e.response?.data != null) {
        if (e.response!.data is String) {
          errorMessage = e.response!.data as String;
        } else if (e.response!.data is Map) {
          errorMessage =
              e.response!.data['message'] ??
              e.response!.data['error'] ??
              e.response!.data['reason'] ??
              e.response!.data.toString();
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      return Exception(errorMessage).toFailure();
    }
    return Exception(e.toString()).toFailure();
  }
}
