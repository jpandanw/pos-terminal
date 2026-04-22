import 'package:dio/dio.dart';
import 'package:pos_terminal/config.dart';
import 'package:result_dart/result_dart.dart';
import '../../types/product.type.dart';

final dio = Dio();

// Assuming Dio is passed in or fetched from a locator rather than instantiated here
AsyncResult<List<Category>> fetchCategories() async {
  try {
    final response = await dio.get("$API_URL/categories");
    final rawList = response.data as List<dynamic>;
    final categories = rawList
        .cast<Map<String, dynamic>>()
        // Assuming you add a fromJson to Category
        .map((json) => Category(id: json['id'], name: json['name']))
        .toList();
    return categories.toSuccess();
  } catch (e) {
    // Catch DioException or other parsing errors
    return Exception(e.toString()).toFailure();
  }
}
