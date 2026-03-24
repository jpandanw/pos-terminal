import 'package:pos_terminal/features/categories/domain/models/category.domain.dart';
import 'package:pos_terminal/features/categories/domain/repository/categories.repository.dart';
import 'package:result_dart/result_dart.dart';

class MockCategoryRepository extends CategoryRepository {
  late final List<Category> _categories;

  MockCategoryRepository() {
    _categories = _generateMockCategories();
  }

  List<Category> _generateMockCategories() {
    return [
      const Category(id: '1', name: 'Electronics'),
      const Category(id: '2', name: 'Clothing'),
      const Category(id: '3', name: 'Food & Beverages'),
      const Category(id: '4', name: 'Home & Garden'),
      const Category(id: '5', name: 'Books'),
      const Category(id: '6', name: 'Sports & Outdoors'),
      const Category(id: '7', name: 'Health & Beauty'),
      const Category(id: '8', name: 'Toys & Games'),
    ];
  }

  @override
  AsyncResult<Object> delete(String id) async {
    try {
      _categories.removeWhere((category) => category.id == id);
      return Success('Category deleted successfully');
    } catch (e) {
      return Failure(Exception('Failed to delete category: $e'));
    }
  }

  @override
  AsyncResult<List<Category>> get() async {
    try {
      return Success(_categories);
    } catch (e) {
      return Failure(Exception('Failed to fetch categories: $e'));
    }
  }

  @override
  AsyncResult<Category> getById(String id) async {
    try {
      final category = _categories.firstWhere((c) => c.id == id);
      return Success(category);
    } catch (e) {
      return Failure(Exception('Category not found: $e'));
    }
  }

  @override
  AsyncResult<Object> update(Category object) async {
    try {
      final index = _categories.indexWhere((c) => c.id == object.id);
      if (index == -1) {
        return Failure(Exception('Category not found'));
      }
      _categories[index] = object;
      return Success('Category updated successfully');
    } catch (e) {
      return Failure(Exception('Failed to update category: $e'));
    }
  }
}
