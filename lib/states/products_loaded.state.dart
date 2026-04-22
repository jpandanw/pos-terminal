import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:signals/signals_flutter.dart';

final productsLoadedRef = Ref.scoped((context) => ProductsLoaded());

class ProductsLoaded implements Disposable {
  late final _byId = signal<Map<String, Product>>({});
  late final _byBarcode = signal<Map<String, Product>>({});
  late final _bySKU = signal<Map<String, Product>>({});

  @override
  void dispose() {
    _byId.dispose();
    _byBarcode.dispose();
    _bySKU.dispose();
  }

  void load(List<Product> products) {
    _byId.value = {for (var p in products) p.id: p};
    _byBarcode.value = {for (var p in products) p.barcode!: p};
    _bySKU.value = {for (var p in products) p.sku!: p};
  }

  Product? getProductById(String id) => _byId.value[id];
  Product? getProductByBarcode(String barcode) => _byBarcode.value[barcode];
  Product? getProductBySKU(String sku) => _bySKU.value[sku];
}
