import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/v7.dart';

Future<String> getHardwareId() async {
  final prefs = await SharedPreferences.getInstance();

  final storageHwId = prefs.getString("hardware_id");

  final hardwareId = switch (storageHwId) {
    String() => storageHwId,
    null => UuidV7().generate(),
  };

  await prefs.setString("hardware_id", hardwareId);

  return hardwareId;
}
