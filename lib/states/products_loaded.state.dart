import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:signals/signals_flutter.dart';

final productsLoadedRef = Ref.scoped((context) => ProductsLoaded());

class ProductsLoaded implements Disposable {
  late final _byId = signal<Map<String, Product>>({});
  late final _byBarcode = signal<Map<String, Product>>({});
  late final _bySKU = signal<Map<String, Product>>({});
  late final _byCategory = signal<Map<String, List<Product>>>({});

  @override
  void dispose() {
    _byId.dispose();
    _byBarcode.dispose();
    _bySKU.dispose();
    _byCategory.dispose();
  }

  void load(List<Product> products) {
    _byId.value = {for (var p in products) p.id: p};
    _byBarcode.value = {for (var p in products) if (p.barcode != null) p.barcode!: p};
    _bySKU.value = {for (var p in products) if (p.sku != null) p.sku!: p};

    // Build category map
    final categoryMap = <String, List<Product>>{};
    for (var product in products) {
      if (product.categories.isEmpty) {
        categoryMap.putIfAbsent('uncategorized', () => []).add(product);
      } else {
        for (var category in product.categories) {
          categoryMap.putIfAbsent(category.id, () => []).add(product);
        }
      }
    }
    _byCategory.value = categoryMap;
  }

  Product? getProductById(String id) => _byId.value[id];
  Product? getProductByBarcode(String barcode) => _byBarcode.value[barcode];
  Product? getProductBySKU(String sku) => _bySKU.value[sku];
  List<Product> getProductsByCategory(String categoryId) =>
      _byCategory.value[categoryId] ?? [];

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _byId.value.values.where((p) {
      final matchName = p.name.toLowerCase().contains(lowerQuery);
      final matchSKU = p.sku?.toLowerCase().contains(lowerQuery) ?? false;
      final matchBarcode =
          p.barcode?.toLowerCase().contains(lowerQuery) ?? false;
      return matchName || matchSKU || matchBarcode;
    }).toList();
  }
}
