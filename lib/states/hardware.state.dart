import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/services/local_sales_storage.dart';
import 'package:pos_terminal/services/startup.service.dart';
import 'package:signals/signals_core.dart';
import 'package:uuid/v7.dart';

final startupStateRef = Ref.scoped((context) => StartupState());

enum RegistrationStatus { loading, notRegistered, registered, error }

class StartupState implements Disposable {
  late final status = signal<RegistrationStatus>(RegistrationStatus.loading);
  late final errorMessage = signal<String?>(null);
  late final hardwareId = signal<String?>(null);

  final StartupService _service = StartupService();

  /// Initialize: generate/get hardware ID, then check if registered.
  Future<void> init() async {
    try {
      status.value = RegistrationStatus.loading;
      
      // Clean up local sales older than 2 weeks on startup
      await LocalSalesStorage.cleanUpOldSales();

      final hwId = await _service.getOrGenerateHardwareId();
      hardwareId.value = hwId;

      final isRegistered = await _service.isHardwareRegistered(hwId);
      status.value = isRegistered
          ? RegistrationStatus.registered
          : RegistrationStatus.notRegistered;
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = RegistrationStatus.error;
    }
  }

  /// Register the hardware with name, optional location, and hardware ID.
  Future<void> register({
    required String name,
    required String hardwareIdVal,
    String? location,
  }) async {
    try {
      status.value = RegistrationStatus.loading;
      final cleanId = hardwareIdVal.trim();
      final finalId = cleanId.isEmpty ? UuidV7().generate() : cleanId;

      await _service.saveHardwareId(finalId);
      hardwareId.value = finalId;

      await _service.registerHardware(
        hardwareId: finalId,
        name: name,
        location: location,
      );

      status.value = RegistrationStatus.registered;
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = RegistrationStatus.error;
    }
  }

  /// Save/update the hardware ID and re-verify registration status.
  Future<void> updateHardwareId(String newId) async {
    try {
      status.value = RegistrationStatus.loading;
      final cleanId = newId.trim();
      final finalId = cleanId.isEmpty ? UuidV7().generate() : cleanId;

      await _service.saveHardwareId(finalId);
      hardwareId.value = finalId;

      final isRegistered = await _service.isHardwareRegistered(finalId);
      status.value = isRegistered
          ? RegistrationStatus.registered
          : RegistrationStatus.notRegistered;
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = RegistrationStatus.error;
    }
  }

  @override
  void dispose() {
    status.dispose();
    errorMessage.dispose();
    hardwareId.dispose();
  }
}
