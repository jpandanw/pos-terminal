import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../products/domain/models/products.domain.dart';

part 'cart.domain.freezed.dart';

@freezed
abstract class CartItem with _$CartItem {
  const CartItem._();
  const factory CartItem({required Product product, required int quantity}) =
      _CartItem;

  double get subTotal => product.basePrice * quantity;
}
