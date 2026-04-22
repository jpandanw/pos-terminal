import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:pos_terminal/views/login.view.dart';
import 'package:pos_terminal/views/make_transaction.view.dart';
import 'package:signals/signals_flutter.dart';

void main() async {
  runApp(const LiteRefScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: SafeArea(
        child: Watch(
          (_) => authStateRef(context).cashier.value == null
              ? LoginView()
              : MakeTransactionView(),
        ),
      ),
    );
  }
}
