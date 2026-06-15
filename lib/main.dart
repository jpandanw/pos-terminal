import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:pos_terminal/states/hardware.state.dart';
import 'package:pos_terminal/states/theme.state.dart';
import 'package:pos_terminal/views/login.view.dart';
import 'package:pos_terminal/views/make_transaction.view.dart';
import 'package:pos_terminal/views/register.view.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      fullScreen: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setFullScreen(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const LiteRefScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final themeState = themeStateRef(context);

      return MaterialApp(
        title: 'POS Terminal',
        themeMode: themeState.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeState.seedColor.value,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeState.seedColor.value,
            brightness: Brightness.dark,
          ),
        ),
        home: SafeArea(
          child: Builder(
            builder: (context) {
              // Kick off init once
              if (!_initialized) {
                _initialized = true;
                Future.microtask(() => startupStateRef(context).init());
              }

              return Watch((_) {
                final authState = authStateRef(context);
                final isLoggedIn = authState.cashier.value != null;
                final isReady = authState.isReady.value;

                if (!isLoggedIn) {
                  return const LoginView();
                }

                return Watch((_) {
                  final regStatus = startupStateRef(context).status.value;

                  return switch (regStatus) {
                    RegistrationStatus.loading => const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                    RegistrationStatus.notRegistered => const RegisterView(),
                    RegistrationStatus.error => Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Failed to check registration",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              startupStateRef(context).errorMessage.value ??
                                  "Unknown error",
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => startupStateRef(context).init(),
                              icon: const Icon(Icons.refresh),
                              label: const Text("RETRY"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RegistrationStatus.registered => Builder(
                      builder: (context) {
                        if (!isReady) {
                          return const Scaffold(
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Loading data...'),
                                ],
                              ),
                            ),
                          );
                        }
                        return const MakeTransactionView();
                      },
                    ),
                  };
                });
              });
            },
          ),
        ),
      );
    });
  }
}
