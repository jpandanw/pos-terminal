import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pos_terminal/config.dart';
import 'package:pos_terminal/services/local_sales_storage.dart';
import 'package:result_dart/result_dart.dart';

final dio = Dio();

AsyncResult<bool> postSale({
  required String terminalId,
  required String cashierId,
  required List<Map<String, dynamic>> items,
  required List<Map<String, dynamic>> modifiers,
  required double total,
  required double customerCash,
  required double customerChange,
  String? customerId,
}) async {
  try {
    final yy = (DateTime.now().year % 100).toString().padLeft(2, '0');
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final ms = (now.millisecond % 100).toString().padLeft(2, '0');
    final randomNum = Random().nextInt(1000).toString().padLeft(3, '0');
    final saleId = 'TX-$yy$mm$dd$ms-$randomNum';

    final payload = {
      "saleId": saleId,
      "hardwareId": terminalId,
      "cashierId": cashierId,
      if (customerId != null) "customerId": customerId,
      "items": items,
      "modifiers": modifiers,
      "total": total,
      "customerCash": customerCash,
      "customerChange": customerChange,
    };

    await dio.post("$API_URL/terminals/sales", data: payload);

    await LocalSalesStorage.saveSale(payload);

    return true.toSuccess();
  } catch (e) {
    debugPrint("POS ERROR: $e");
    if (e is DioException) {
      return Exception(e.response?.data?.toString() ?? e.message).toFailure();
    }
    return Exception(e.toString()).toFailure();
  }
}
