import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pos_terminal/config.dart';
import 'package:result_dart/result_dart.dart';

final dio = Dio();

class LoginResponse {
  final String id;
  final String name;
  final String email;

  LoginResponse({required this.id, required this.name, required this.email});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

AsyncResult<LoginResponse> login({
  required String email,
  required String password,
}) async {
  try {
    debugPrint("Attempting login with email: $email");
    final response = await dio.post(
      "$API_URL/login",
      data: {"email": email, "password": password},
    );

    debugPrint("LOGIN  RESPONSE: ${response.data}");

    // Handle different response types
    if (response.data is Map<String, dynamic>) {
      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return loginResponse.toSuccess();
    } else if (response.data is String) {
      // If response is a string, treat it as an error or invalid format
      return Exception('Invalid response format: ${response.data}').toFailure();
    } else {
      return Exception(
        'Unexpected response type: ${response.data.runtimeType}',
      ).toFailure();
    }
  } catch (e) {
    debugPrint("Login error: $e");
    if (e is DioException) {
      // Try to extract error message from response
      String errorMessage = 'Login failed';

      if (e.response?.data != null) {
        if (e.response!.data is String) {
          errorMessage = e.response!.data as String;
        } else if (e.response!.data is Map) {
          errorMessage =
              e.response!.data['message'] ??
              e.response!.data['error'] ??
              e.response!.data.toString();
        } else {
          errorMessage = e.response!.data.toString();
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return Exception(errorMessage).toFailure();
    }
    return Exception(e.toString()).toFailure();
  }
}
