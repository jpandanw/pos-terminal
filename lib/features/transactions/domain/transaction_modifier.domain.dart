import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_terminal/features/transactions/domain/transactions.domain.dart';

part 'transaction_modifier.domain.freezed.dart';

@freezed
abstract class TransactionModifier with _$TransactionModifier {
  const factory TransactionModifier({
    required String id,
    required ModifierType modifierType,
    required double amount,
  }) = _TransactionModifier;
}
