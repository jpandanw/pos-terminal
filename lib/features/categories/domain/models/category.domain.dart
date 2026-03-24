import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.domain.freezed.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({required String id, required String name}) =
      _Category;
}
