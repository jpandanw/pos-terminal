import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:signals/signals_flutter.dart';

class HeldTransaction {
  final DateTime heldAt;
  final List<TransactionItem> cart;

  HeldTransaction({required this.heldAt, required this.cart});
}

class HeldTransactionState extends Disposable {
  late final heldCarts = listSignal<HeldTransaction>([]);

  void holdCurrentCart(BuildContext context) {
    final toHoldCart = makeTransactionRef.of(context).cart;

    if (toHoldCart.isEmpty) return;

    heldCarts.add(
      HeldTransaction(heldAt: DateTime.now(), cart: [...toHoldCart]),
    );
    toHoldCart.clear();
  }

  void resumeCart(BuildContext context, int index) {
    if (index < 0 || index >= heldCarts.length) return;

    final toResumeCart = heldCarts[index];

    if (toResumeCart.cart.isEmpty) return;

    heldCarts.removeAt(index);
    makeTransactionRef.of(context).cart.addAll(toResumeCart.cart);
  }

  @override
  void dispose() {
    heldCarts.dispose();
  }
}

final heldTransactionRef = Ref.scoped((ref) => HeldTransactionState());
