import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/features/transactions/presentation/make_transaction/make_transaction_page.dart';

void main() {
  runApp(const LiteRefScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const SafeArea(child: MakeTransactionPage()),
    );
  }
}
