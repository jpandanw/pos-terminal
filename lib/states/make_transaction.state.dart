import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:signals/signals_core.dart';

final makeTransactionRef = Ref.scoped((context) => MakeTransactionState());

class MakeTransactionState implements Disposable {
  final cart = listSignal<TransactionItem>([]);
  final modifiers = listSignal<TransactionModifier>([]);
  final customerMoney = signal<double?>(null);
  final customerId = signal<String?>(null);
  final customerName = signal<String?>(null);

  late final change = computed<double?>(() {
    if (customerMoney.value == null) return null;
    return customerMoney.value! - overallTotal.value;
  });

  late final cartTotal = computed<double>(
    () => cart.fold(
      0.00,
      (acc, next) => acc + (next.product.price * next.quantity),
    ),
  );

  late final overallTotal = computed<double>(() {
    double total = cartTotal.value;
    for (final modifier in modifiers) {
      if (modifier.type == TransactionModifierType.percentage) {
        total += cartTotal.value * (modifier.amount / 100);
      } else {
        total += modifier.amount;
      }
    }
    return total;
  });

  void addToCart({required Product product, required int quantity}) {
    final existingIndex = indexOf(product: product);
    if (existingIndex >= 0) {
      cart[existingIndex] = cart[existingIndex].copyWith(
        quantity: cart[existingIndex].quantity + quantity,
      );
      return;
    }

    cart.add(TransactionItem(product: product, quantity: quantity));
  }

  void removeFromCart({required Product product}) {
    cart.value = cart.where((i) => i.product.id != product.id).toList();
  }

  void removeFromCartByIndex(int index) {
    cart.removeAt(index);
  }

  void setQuantity({required Product product, required int quantity}) {
    if (quantity <= 0) {
      removeFromCart(product: product);
      return;
    }
    final existingIndex = indexOf(product: product);
    if (existingIndex >= 0) {
      cart[existingIndex] = cart[existingIndex].copyWith(quantity: quantity);
    } else {
      cart.add(TransactionItem(product: product, quantity: quantity));
    }
  }

  void startNewTransaction() {
    cart.clear();
    modifiers.clear();
    customerMoney.value = null;
    customerId.value = null;
    customerName.value = null;
  }

  bool inCart({required Product product}) =>
      cart.any((i) => product.id == i.product.id);

  int indexOf({required Product product}) =>
      cart.indexWhere((i) => product.id == i.product.id);

  @override
  void dispose() {
    cart.dispose();
    modifiers.dispose();
    cartTotal.dispose();
    overallTotal.dispose();
    customerMoney.dispose();
    customerId.dispose();
    customerName.dispose();
  }
}
