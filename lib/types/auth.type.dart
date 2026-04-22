import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.type.freezed.dart';

@freezed
abstract class Cashier with _$Cashier {
  const factory Cashier({required String id, required String name}) = _Cashier;
}
