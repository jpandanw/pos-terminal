import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/common/repository_store.dart';
import 'package:result_dart/result_dart.dart';
import 'package:signals/signals_flutter.dart';

class ProductListStore implements Disposable {
  final fetchProducts = computedAsync(
    () async => await repositoryStoreRef.instance.productRepository
        .get()
        .getOrElse((_) => []),
  );

  @override
  void dispose() {
    fetchProducts.dispose();
  }
}

final productListStoreRef = Ref.scoped((ctx) => ProductListStore());
