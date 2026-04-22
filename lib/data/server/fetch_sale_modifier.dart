import 'package:dio/dio.dart';
import 'package:pos_terminal/config.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:result_dart/result_dart.dart';

final dio = Dio();

AsyncResult<List<TransactionModifier>> fetchSaleModifiers() async {
  final response = await dio.get("$API_URL/sale-modifiers");

  final list = response.data != null
      ? (response.data as List)
            .map(
              (i) => TransactionModifier(
                id: i['id'],
                name: i['name'],
                amount: double.tryParse(i['amount']) ?? 0,
                type: i['type'] == "FLAT"
                    ? TransactionModifierType.flat
                    : TransactionModifierType.percentage,
              ),
            )
            .toList()
      : [] as List<TransactionItem>;

  return Success(list.cast<TransactionModifier>());
}
