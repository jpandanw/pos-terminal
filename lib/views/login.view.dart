import 'package:flutter/material.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:signals/signals_flutter.dart';

final _showPassword = signal(false);

@immutable
class LoginView extends StatelessWidget {
  LoginView({super.key});

  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

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
                  TextField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      icon: Icon(Icons.person),
                    ),
                  ),
                  Watch(
                    (_) => TextField(
                      obscureText: _showPassword.value,
                      controller: usernameCtrl,
                      decoration: InputDecoration(
                        labelText: "Password",
                        icon: const Icon(Icons.lock),
                        suffixIcon: TextButton.icon(
                          onPressed: () => {
                            _showPassword.value = !_showPassword.value,
                          },
                          label: _showPassword.value
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      authStateRef(context).login(
                        username: usernameCtrl.text,
                        password: passwordCtrl.text,
                      );
                    },
                    child: const Text("LOGIN"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
