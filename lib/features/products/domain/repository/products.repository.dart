import 'package:pos_terminal/common/repository.dart';
import 'package:result_dart/result_dart.dart';

import '../models/products.domain.dart' show Product;

abstract class ProductRepository extends Repository<Product> {}

abstract class ProductInMemoryRepository extends Repository<Product> {
  AsyncResult<List<Product>> search(String term);
}
