import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_terminal/types/product.type.dart';

part 'transactions.type.freezed.dart';

@freezed
abstract class TransactionItem with _$TransactionItem {
  const factory TransactionItem({
    required Product product,
    required int quantity,
  }) = _TransactionItem;
}

enum TransactionModifierType { percentage, flat }

@freezed
abstract class TransactionModifier with _$TransactionModifier {
  const factory TransactionModifier({
    required String id,
    required String name,
    required double amount,
    required TransactionModifierType type,
  }) = _TransactionModifier;
}

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required List<TransactionItem> items,
    required double total,
  }) = _Transaction;
}
