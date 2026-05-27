import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_device_identifier/unique_device_identifier.dart';
import 'package:uuid/v7.dart';

Future<String> getHardwareId() async {
  final prefs = await SharedPreferences.getInstance();

  final storageHwId = prefs.getString("hardware_id");
  
  String? uniqueId;
  try {
    uniqueId = await UniqueDeviceIdentifier.getUniqueIdentifier();
  } catch (_) {
    // Ignore platform exceptions
  }

  final hardwareId = uniqueId ?? storageHwId ?? UuidV7().generate();

  if (storageHwId != hardwareId) {
    await prefs.setString("hardware_id", hardwareId);
  }

  return hardwareId;
}
