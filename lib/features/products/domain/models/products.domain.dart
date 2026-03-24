import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_terminal/features/categories/domain/models/category.domain.dart';

part 'products.domain.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    String? description,
    required double basePrice,
    required List<Category> categories,
    String? barcode,
    String? sku,
  }) = _Product;
}
