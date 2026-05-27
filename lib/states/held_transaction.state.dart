import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class HeldTransaction {
  final DateTime heldAt;
  final List<TransactionItem> cart;

  HeldTransaction({required this.heldAt, required this.cart});
}

class HeldTransactionState extends Disposable {
  late final heldCarts = listSignal<HeldTransaction>([]);

  static const String _storageKey = 'held_transactions_v1';

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> data = heldCarts.map((h) => {
      'heldAt': h.heldAt.toIso8601String(),
      'cart': h.cart.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
      }).toList(),
    }).toList();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Future<void> loadFromStorage(ProductsLoaded productsState) async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);
    if (savedData == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(savedData);
      
      final loadedCarts = <HeldTransaction>[];
      
      for (final h in decoded) {
        final heldAt = DateTime.parse(h['heldAt']);
        final cartList = h['cart'] as List<dynamic>;
        
        final resolvedCart = <TransactionItem>[];
        for (final item in cartList) {
          final product = productsState.getProductById(item['productId']);
          if (product != null) {
            resolvedCart.add(TransactionItem(product: product, quantity: item['quantity']));
          }
        }
        
        if (resolvedCart.isNotEmpty) {
          loadedCarts.add(HeldTransaction(heldAt: heldAt, cart: resolvedCart));
        }
      }
      
      heldCarts.value = loadedCarts;
    } catch (e) {
      debugPrint('Error loading held transactions: $e');
    }
  }

  void holdCurrentCart(BuildContext context) {
    final toHoldCart = makeTransactionRef.of(context).cart;

    if (toHoldCart.isEmpty) return;

    heldCarts.add(
      HeldTransaction(heldAt: DateTime.now(), cart: [...toHoldCart]),
    );
    toHoldCart.clear();
    _saveToStorage();
  }

  void resumeCart(BuildContext context, int index) {
    if (index < 0 || index >= heldCarts.length) return;

    final toResumeCart = heldCarts[index];

    if (toResumeCart.cart.isEmpty) return;

    heldCarts.removeAt(index);
    makeTransactionRef.of(context).cart.addAll(toResumeCart.cart);
    _saveToStorage();
  }

  @override
  void dispose() {
    heldCarts.dispose();
  }
}

final heldTransactionRef = Ref.scoped((ref) => HeldTransactionState());
