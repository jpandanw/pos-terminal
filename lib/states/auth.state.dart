import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/types/auth.type.dart';
import 'package:signals/signals_flutter.dart';

class AuthState extends Disposable {
  late final BuildContext context;
  AuthState(this.context);

  final cashier = signal<Cashier?>(null);

  Future login({required String username, required String password}) async {
    await fetchDataRef(context).load();
    productsLoadedRef(context).load(fetchDataRef(context).products.value);

    cashier.value = Cashier(id: "CASHIER-1", name: "JAMEI PABLO");
  }

  @override
  void dispose() {
    cashier.dispose();
  }
}

final authStateRef = Ref.scoped((context) => AuthState(context));
