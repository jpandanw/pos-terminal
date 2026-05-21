import 'package:flutter/material.dart';
import 'package:pos_terminal/data/server/validate.dart';
import 'package:pos_terminal/states/restriction.state.dart';

class SupervisorValidationDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final String actionDescription;

  const SupervisorValidationDialog({
    super.key,
    required this.onSuccess,
    this.actionDescription = "perform this restricted operation",
  });

  @override
  State<SupervisorValidationDialog> createState() => _SupervisorValidationDialogState();
}

class _SupervisorValidationDialogState extends State<SupervisorValidationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isVerified = false;
  String? _errorMessage;
  bool _showPassword = false;

  // Bypass Options State
  BypassType _selectedBypassType = BypassType.byCount;
  int _selectedCount = 5;
  int _selectedTimeMinutes = 15;
  
  final _customCountController = TextEditingController(text: "5");
  final _customTimeController = TextEditingController(text: "15");

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _customCountController.dispose();
    _customTimeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await validateSupervisor(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (success) {
        setState(() {
          _isVerified = true;
        });
      },
      (failure) {
        setState(() {
          _errorMessage = failure.toString().replaceFirst('Exception: ', '');
        });
      },
    );
  }

  void _applyBypassAndSubmit() {
    final restrictionState = restrictionStateRef(context);

    switch (_selectedBypassType) {
      case BypassType.none:
        // "This action only" -> We authorize for exactly 1 operation
        restrictionState.authorizeByCount(1);
        break;
      case BypassType.byCount:
        final count = int.tryParse(_customCountController.text) ?? _selectedCount;
        restrictionState.authorizeByCount(count);
        break;
      case BypassType.byTime:
        final mins = int.tryParse(_customTimeController.text) ?? _selectedTimeMinutes;
        restrictionState.authorizeByTime(Duration(minutes: mins));
        break;
      case BypassType.bySession:
        restrictionState.authorizeBySession();
        break;
    }

    // Call the success callback to execute the restricted operation
    widget.onSuccess();
    
    // Decrement the count since we just executed the operation
    restrictionState.useAuthorization();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 480,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isVerified 
                          ? Colors.green.withOpacity(0.1) 
                          : theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isVerified ? Icons.check_circle_outline : Icons.shield_outlined,
                      color: _isVerified ? Colors.green : theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isVerified ? "Validation Approved" : "Supervisor Validation",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isVerified 
                              ? "Select authorization scope" 
                              : "Required to ${widget.actionDescription}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              
              if (!_isVerified) ...[
                // Credentials Form
                Form(
                  key: _formKey,
                  child: Column(
                    spacing: 16,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Supervisor Email",
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter supervisor email";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter password";
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _handleVerify(),
                      ),
                    ],
                  ),
                ),
                
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isLoading ? null : _handleVerify,
                      child: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Verify Supervisor"),
                    ),
                  ],
                ),
              ] else ...[
                // Options selection Form
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Option 1: Just this action
                    RadioListTile<BypassType>(
                      title: const Text("This action only"),
                      subtitle: const Text("Allows the current remove or reduce operation once."),
                      value: BypassType.none,
                      groupValue: _selectedBypassType,
                      onChanged: (val) => setState(() => _selectedBypassType = val!),
                    ),
                    
                    // Option 2: By Count
                    RadioListTile<BypassType>(
                      title: const Text("By Count"),
                      subtitle: const Text("Allows a specific number of remove or reduce operations."),
                      value: BypassType.byCount,
                      groupValue: _selectedBypassType,
                      onChanged: (val) => setState(() => _selectedBypassType = val!),
                    ),
                    if (_selectedBypassType == BypassType.byCount)
                      Padding(
                        padding: const EdgeInsets.only(left: 72.0, bottom: 8.0, right: 16.0),
                        child: Row(
                          children: [
                            ...[3, 5, 10, 20].map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text("$c actions"),
                                selected: _selectedCount == c,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedCount = c;
                                      _customCountController.text = c.toString();
                                    });
                                  }
                                },
                              ),
                            )),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _customCountController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Custom",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Option 3: By Time
                    RadioListTile<BypassType>(
                      title: const Text("By Time"),
                      subtitle: const Text("Allows any remove or reduce operations for a limited time."),
                      value: BypassType.byTime,
                      groupValue: _selectedBypassType,
                      onChanged: (val) => setState(() => _selectedBypassType = val!),
                    ),
                    if (_selectedBypassType == BypassType.byTime)
                      Padding(
                        padding: const EdgeInsets.only(left: 72.0, bottom: 8.0, right: 16.0),
                        child: Row(
                          children: [
                            ...[5, 15, 30, 60].map((m) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(m >= 60 ? "${m ~/ 60} hr" : "$m min"),
                                selected: _selectedTimeMinutes == m,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedTimeMinutes = m;
                                      _customTimeController.text = m.toString();
                                    });
                                  }
                                },
                              ),
                            )),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _customTimeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Min",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                    // Option 4: By end of session
                    RadioListTile<BypassType>(
                      title: const Text("By end of session"),
                      subtitle: const Text("Allows all remove and reduce operations until current logout."),
                      value: BypassType.bySession,
                      groupValue: _selectedBypassType,
                      onChanged: (val) => setState(() => _selectedBypassType = val!),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _applyBypassAndSubmit,
                      child: const Text("Confirm & Apply"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
