import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:signals/signals_core.dart';

final makeTransactionRef = Ref.scoped((context) => MakeTransactionState());

class MakeTransactionState implements Disposable {
  final cart = listSignal<TransactionItem>([]);
  final modifiers = listSignal<TransactionModifier>([]);
  final heldCarts = listSignal<List<TransactionItem>>([]);

  late final cartTotal = computed<double>(
    () => cart.fold(
      0.00,
      (acc, next) => acc + (next.product.price * next.quantity),
    ),
  );

  void holdCurrentCart() {
    if (cart.isEmpty) return;
    heldCarts.add([...cart]);
    cart.clear();
  }

  void resumeCart(int index) {
    if (index < 0 || index >= heldCarts.length) return;
    final held = heldCarts.removeAt(index);
    if (cart.isNotEmpty) {
      heldCarts.add([...cart]);
    }
    cart.value = held;
  }

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

  void setQuantity({required Product product, required int quauntity}) {}

  bool inCart({required Product product}) =>
      cart.any((i) => product.id == i.product.id);

  int indexOf({required Product product}) =>
      cart.indexWhere((i) => product.id == i.product.id);

  @override
  void dispose() {
    cart.dispose();
    modifiers.dispose();
    heldCarts.dispose();
    cartTotal.dispose();
  }
}
