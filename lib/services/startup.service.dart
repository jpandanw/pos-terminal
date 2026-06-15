import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pos_terminal/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/v7.dart';

class StartupService {
  final _dio = Dio();

  Future<bool> hasHardwareId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("hardware_id");
    return id != null && id.trim().isNotEmpty;
  }

  Future<String> getOrGenerateHardwareId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString("hardware_id");
    if (existing != null && existing.trim().isNotEmpty) return existing;

    final hardwareId = UuidV7().generate();
    await prefs.setString("hardware_id", hardwareId);
    return hardwareId;
  }

  Future<String> getHardwareId() async {
    final prefs = await SharedPreferences.getInstance();
    final hardwareId = prefs.getString("hardware_id");
    if (hardwareId == null || hardwareId.trim().isEmpty) {
      final generated = UuidV7().generate();
      await prefs.setString("hardware_id", generated);
      return generated;
    }
    return hardwareId;
  }

  Future<void> saveHardwareId(String hardwareId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("hardware_id", hardwareId.trim());
  }

  /// Check if hardware is registered on the server.
  /// GET /api/terminal/hardware/:hardwareId
  /// Returns true if registered, false if 404.
  Future<bool> isHardwareRegistered(String hardwareId) async {
    debugPrint("Checking if hardware is registered: $hardwareId");
    try {
      final response = await _dio.get(
        "$API_URL/terminals/hardwares/$hardwareId",
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint(e.toString());
      if (e.response?.statusCode == 404) {
        return false;
      }
      rethrow;
    }
  }

  /// Register hardware on the server.
  /// POST /api/terminals
  /// Body: { hardwareId, name, location }
  Future<void> registerHardware({
    required String hardwareId,
    required String name,
    String? location,
  }) async {
    await _dio.post(
      "$API_URL/terminals",
      data: {
        "hardwareId": hardwareId,
        "name": name,
        "location": location ?? "",
      },
    );
  }
}
