import 'package:flutter/material.dart';
import 'package:pos_terminal/config.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:pos_terminal/states/hardware.state.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/v7.dart';

final _showPassword = signal(false);
final _isLoading = signal(false);
final _errorMessage = signal<String?>(null);

@immutable
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController usernameCtrl;
  late final TextEditingController passwordCtrl;

  @override
  void initState() {
    super.initState();
    usernameCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  String _formatErrorMessage(String error) {
    // Remove "Exception: " prefix
    String message = error.replaceFirst('Exception: ', '');

    // Handle common error patterns
    if (message.contains('400') ||
        message.toLowerCase().contains('bad request') ||
        message.toLowerCase().contains('invalid')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('401') ||
        message.toLowerCase().contains('unauthorized')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('404') ||
        message.toLowerCase().contains('not found')) {
      return 'Account not found. Please check your email.';
    }
    if (message.contains('500') ||
        message.toLowerCase().contains('internal server')) {
      return 'Server error. Please try again later.';
    }
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (message.toLowerCase().contains('timeout')) {
      return 'Request timeout. Please try again.';
    }

    // Default fallback for other errors
    return 'Login failed. Please try again.';
  }

  Future<void> handleLogin(BuildContext context) async {
    // Validate inputs
    if (usernameCtrl.text.trim().isEmpty) {
      _errorMessage.value = 'Please enter your email address.';
      return;
    }

    if (passwordCtrl.text.isEmpty) {
      _errorMessage.value = 'Please enter your password.';
      return;
    }

    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      await authStateRef(
        context,
      ).login(email: usernameCtrl.text.trim(), password: passwordCtrl.text);
    } catch (e) {
      final formattedError = _formatErrorMessage(e.toString());
      _errorMessage.value = formattedError;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formattedError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 512,
          width: 512,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Watch(
                    (_) => TextField(
                      controller: usernameCtrl,
                      enabled: !_isLoading.value,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        icon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  Watch(
                    (_) => TextField(
                      obscureText: !_showPassword.value,
                      controller: passwordCtrl,
                      enabled: !_isLoading.value,
                      decoration: InputDecoration(
                        labelText: "Password",
                        icon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _showPassword.value = !_showPassword.value;
                          },
                          icon: _showPassword.value
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                      ),
                      onSubmitted: (_) => handleLogin(context),
                    ),
                  ),
                  Watch(
                    (_) => _errorMessage.value != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage.value!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Watch(
                    (_) => FilledButton(
                      onPressed: _isLoading.value
                          ? null
                          : () => handleLogin(context),
                      child: _isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("LOGIN"),
                    ),
                  ),
                  const Divider(),
                  Watch((_) {
                    final hwState = startupStateRef(context);
                    final currentId = hwState.hardwareId.value ?? 'None';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Terminal ID / Hardware ID",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                currentId,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isLoading.value
                              ? null
                              : () => _showUpdateTerminalIdDialog(context, currentId),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Change", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateTerminalIdDialog(BuildContext context, String currentId) {
    final controller = TextEditingController(text: currentId);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            return AlertDialog(
              title: const Text("Change Terminal ID"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Updating the Terminal ID will check registration status. If the ID is not registered, you will be prompted to register it.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: "Terminal ID",
                        hintText: "Enter custom terminal ID or generate one",
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.autorenew_rounded),
                          tooltip: "Generate New ID",
                          onPressed: () {
                            setDialogState(() {
                              controller.text = UuidV7().generate();
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
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("CANCEL"),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final newId = controller.text.trim();
                    Navigator.of(dialogContext).pop();
                    
                    // Call updateHardwareId from startupStateRef
                    await startupStateRef(context).updateHardwareId(newId);
                  },
                  child: const Text("UPDATE"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
