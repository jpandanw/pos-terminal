import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pos_terminal/config.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:result_dart/result_dart.dart';
import 'package:sembast_web/sembast_web.dart';

final dio = Dio();

// Use sembast store
final store = StoreRef.main();

Future<Database> _getDb() async {
  var factory = databaseFactoryWeb;
  return await factory.openDatabase('pos_terminal.db');
}

AsyncResult<List<Product>> fetchProducts() async {
  final db = await _getDb();
  final lastUpdateStr = await store.record('products_last_update').get(db) as String?;
  
  bool hasNewItems = true;

  if (lastUpdateStr != null) {
    try {
      final res = await dio.post("$API_URL/products/has-new-products", data: {
        "lastUpdate": lastUpdateStr,
      });
      hasNewItems = res.data['hasNewItems'] ?? true;
    } catch (e) {
      debugPrint("Failed to check for new products: $e");
      hasNewItems = false; // Fallback to local cache if offline
    }
  }

  if (hasNewItems || lastUpdateStr == null) {
    try {
      final response = await dio.get("$API_URL/products");
      final productsList = response.data as List;
      
      await db.transaction((txn) async {
        await store.record('products_data').put(txn, productsList);
        await store.record('products_last_update').put(txn, DateTime.now().toUtc().toIso8601String());
      });

      return _parseProducts(productsList).toSuccess();
    } catch (e) {
      debugPrint("Failed to fetch products: $e");
      final storedData = await store.record('products_data').get(db) as List?;
      if (storedData != null) {
        return _parseProducts(storedData).toSuccess();
      }
      return Exception("Failed to fetch products").toFailure();
    }
  } else {
    final storedData = await store.record('products_data').get(db) as List?;
    if (storedData != null) {
      return _parseProducts(storedData).toSuccess();
    } else {
      // Fallback if data is missing despite hasNewItems = false
      try {
        final response = await dio.get("$API_URL/products");
        final productsList = response.data as List;
        
        await db.transaction((txn) async {
          await store.record('products_data').put(txn, productsList);
          await store.record('products_last_update').put(txn, DateTime.now().toUtc().toIso8601String());
        });

        return _parseProducts(productsList).toSuccess();
      } catch (e) {
         return Exception("Failed to fetch products").toFailure();
      }
    }
  }
}

List<Product> _parseProducts(List data) {
  return data.map(
    (i) => Product(
      id: i['id'],
      name: i['name'],
      basePrice: double.tryParse(i['basePrice']?.toString() ?? '') ?? 0,
      price: double.tryParse(i['basePrice']?.toString() ?? '') ?? 0,
      barcode: i['barcode'],
      sku: i['sku'],
      categories: (i['categories'] as List)
          .map((c) => Category(id: c['id'], name: c['name']))
          .toList(),
      priceModifiers: (i['priceModifiers'] as List)
          .map(
            (m) => PriceModifier(
              id: m['id'],
              name: m['name'],
              type: m['type'] == "FLAT"
                  ? PriceModifierType.flat
                  : PriceModifierType.percentage,
              amount: double.tryParse(m['amount']?.toString() ?? '') ?? 0,
            ),
          )
          .toList(),
    ),
  ).toList();
}
