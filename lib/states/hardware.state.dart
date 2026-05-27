import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/services/local_sales_storage.dart';
import 'package:pos_terminal/services/startup.service.dart';
import 'package:signals/signals_core.dart';

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

  /// Register the hardware with name and optional location.
  Future<void> register({required String name, String? location}) async {
    try {
      status.value = RegistrationStatus.loading;
      final hwId = hardwareId.value!;

      await _service.registerHardware(
        hardwareId: hwId,
        name: name,
        location: location,
      );

      status.value = RegistrationStatus.registered;
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
