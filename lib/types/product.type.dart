import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.type.freezed.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({required String id, required String name}) =
      _Category;
}

enum PriceModifierType { percentage, flat }

@freezed
abstract class PriceModifier with _$PriceModifier {
  const factory PriceModifier({
    required String id,
    required String name,
    required PriceModifierType type,
    required double amount,
  }) = _PriceModifier;
}

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double basePrice,
    required double price,
    String? barcode,
    String? sku,
    required List<Category> categories,
    required List<PriceModifier> priceModifiers,
  }) = _Product;
}
