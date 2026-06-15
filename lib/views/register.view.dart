import 'package:flutter/material.dart';
import 'package:pos_terminal/states/hardware.state.dart';
import 'package:uuid/v7.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  late final TextEditingController terminalIdCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final currentId = startupStateRef(context).hardwareId.value ?? '';
      terminalIdCtrl = TextEditingController(text: currentId);
      if (currentId.trim().isEmpty) {
        terminalIdCtrl.text = UuidV7().generate();
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    locationCtrl.dispose();
    if (_isInitialized) {
      terminalIdCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await startupStateRef(context).register(
      name: nameCtrl.text.trim(),
      hardwareIdVal: terminalIdCtrl.text.trim(),
      location: locationCtrl.text.trim().isEmpty
          ? null
          : locationCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 480,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.point_of_sale_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Register Terminal",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "This device is not yet registered.\nPlease provide a name and location to continue.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: terminalIdCtrl,
                      decoration: InputDecoration(
                        labelText: "Terminal ID (Hardware ID)",
                        hintText: "Enter custom terminal ID or generate one",
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.autorenew_rounded),
                          tooltip: "Generate New ID",
                          onPressed: () {
                            setState(() {
                              terminalIdCtrl.text = UuidV7().generate();
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Terminal ID is required";
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Terminal Name",
                        hintText: "e.g. Cashier 1",
                        prefixIcon: Icon(Icons.terminal),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(
                        labelText: "Location (optional)",
                        hintText: "e.g. Ground Floor, Main Branch",
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleRegister(),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _isSubmitting ? null : _handleRegister,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.app_registration),
                      label: Text(
                        _isSubmitting ? "REGISTERING..." : "REGISTER TERMINAL",
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
