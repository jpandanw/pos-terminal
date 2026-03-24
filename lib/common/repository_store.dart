import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/features/categories/data/datasources/mock/mock.datasource.dart';
import 'package:pos_terminal/features/categories/domain/repository/categories.repository.dart';
import 'package:pos_terminal/features/products/data/datasources/mock/product.repositoryimpl.datasource.dart';
import 'package:pos_terminal/features/products/domain/repository/products.repository.dart';

class RepositoryStore {
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;

  RepositoryStore({
    required this.categoryRepository,
    required this.productRepository,
  });
}

final repositoryStoreRef = Ref.singleton(
  () => RepositoryStore(
    categoryRepository: MockCategoryRepository(),
    productRepository: MockProductRepository(),
  ),
);
