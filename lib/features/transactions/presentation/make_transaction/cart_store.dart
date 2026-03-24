import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/features/cart/domain/models/cart.domain.dart';
import 'package:pos_terminal/features/transactions/domain/transaction_modifier.domain.dart';
import 'package:signals/signals_flutter.dart';

import 'package:pos_terminal/features/products/domain/models/products.domain.dart';

class CartStore implements Disposable {
  final cartItems = listSignal<CartItem>([]);
  final modifiers = listSignal<TransactionModifier>([]);

  @override
  void dispose() {
    count.dispose();
    modifiers.dispose();
    subtotal.dispose();
    cartItems.dispose();
  }

  late final count = computed(() => cartItems.length);
  late final subtotal = computed(
    () => cartItems.fold(0.0, (acc, next) => next.subTotal + acc),
  );
  late final total = computed(
    () => modifiers.fold(subtotal, (acc, next) => );
  ) 


  void addToCart(Product product, int quantity) {
    final int index = getIndexOfProduct(product);
    if (index <= -1) {
      cartItems.add(CartItem(product: product, quantity: quantity));
      return;
    }

    cartItems[index] = CartItem(
      product: cartItems[index].product,
      quantity: cartItems[index].quantity,
    );
  }

  void reset() => cartItems.clear();

  int getIndexOfProduct(Product product) =>
      cartItems.indexWhere((cart) => cart.product.id == product.id);

  bool isInCart(Product product) => getIndexOfProduct(product) > 1;
}

final cartStoreRef = Ref.scoped((ctx) => CartStore());
