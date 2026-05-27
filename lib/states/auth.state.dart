import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/data/server/login.dart' as login_api;
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/states/held_transaction.state.dart';
import 'package:pos_terminal/types/auth.type.dart';
import 'package:signals/signals_flutter.dart';

class AuthState extends Disposable {
  late final BuildContext context;
  AuthState(this.context);

  final cashier = signal<Cashier?>(null);
  final isReady = signal<bool>(false);

  Future<void> login({required String email, required String password}) async {
    // Reset ready state
    isReady.value = false;

    final fetchRef = fetchDataRef(context);
    final productsRef = productsLoadedRef(context);
    final heldTxRef = heldTransactionRef(context);
    
    // Call the login API
    final result = await login_api.login(email: email, password: password);

    // Handle the result
    await result.fold(
      (success) async {
        // Set cashier info first
        cashier.value = Cashier(
          id: success.id,
          name: success.name,
          email: success.email,
        );

        // Load all required data before marking as ready
        await fetchRef.load();
        productsRef.load(fetchRef.products.value);
        
        // Load held transactions from local storage
        await heldTxRef.loadFromStorage(productsRef);

        // Now mark as ready to show the main app
        isReady.value = true;
      },
      (failure) {
        // Handle login failure - you might want to show a snackbar or dialog
        debugPrint('Login failed: $failure');
        throw failure;
      },
    );
  }

  void logout() {
    cashier.value = null;
    isReady.value = false;
  }

  @override
  void dispose() {
    cashier.dispose();
    isReady.dispose();
  }
}

final authStateRef = Ref.scoped((context) => AuthState(context));
