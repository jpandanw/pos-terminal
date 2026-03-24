import 'package:freezed_annotation/freezed_annotation.dart';

import '../../cart/domain/models/cart.domain.dart';
import 'transaction_modifier.domain.dart';

part 'transactions.domain.freezed.dart';

enum PaymentMethod { cash, card, ewallet }

enum ModifierType { percentage, fixed }

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required List<CartItem> cart,
    required List<TransactionModifier> modifiers,
    required double overallTotal,
    required PaymentMethod method,
  }) = _Transaction;
}
