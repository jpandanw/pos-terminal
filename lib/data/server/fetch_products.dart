import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pos_terminal/config.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:result_dart/result_dart.dart';

final dio = Dio();

AsyncResult<List<Product>> fetchProducts() async {
  final response = await dio.get("$API_URL/products");

  final products = (response.data as List).map(
    (i) => Product(
      id: i['id'],
      name: i['name'],
      basePrice: double.tryParse(i['basePrice']) ?? 0,
      price: double.tryParse(i['basePrice']) ?? 0,
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
              amount: double.tryParse(m['amount']) ?? 0,
            ),
          )
          .toList(),
    ),
  );

  return products.toList().toSuccess();
}
