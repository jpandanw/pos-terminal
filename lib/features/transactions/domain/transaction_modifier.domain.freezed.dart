// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_modifier.domain.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionModifier {

 String get id; ModifierType get modifierType; double get amount;
/// Create a copy of TransactionModifier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModifierCopyWith<TransactionModifier> get copyWith => _$TransactionModifierCopyWithImpl<TransactionModifier>(this as TransactionModifier, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModifier&&(identical(other.id, id) || other.id == id)&&(identical(other.modifierType, modifierType) || other.modifierType == modifierType)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,id,modifierType,amount);

@override
String toString() {
  return 'TransactionModifier(id: $id, modifierType: $modifierType, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $TransactionModifierCopyWith<$Res>  {
  factory $TransactionModifierCopyWith(TransactionModifier value, $Res Function(TransactionModifier) _then) = _$TransactionModifierCopyWithImpl;
@useResult
$Res call({
 String id, ModifierType modifierType, double amount
});




}
/// @nodoc
class _$TransactionModifierCopyWithImpl<$Res>
    implements $TransactionModifierCopyWith<$Res> {
  _$TransactionModifierCopyWithImpl(this._self, this._then);

  final TransactionModifier _self;
  final $Res Function(TransactionModifier) _then;

/// Create a copy of TransactionModifier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? modifierType = null,Object? amount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,modifierType: null == modifierType ? _self.modifierType : modifierType // ignore: cast_nullable_to_non_nullable
as ModifierType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModifier].
extension TransactionModifierPatterns on TransactionModifier {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModifier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModifier() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModifier value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModifier():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModifier value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModifier() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ModifierType modifierType,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModifier() when $default != null:
return $default(_that.id,_that.modifierType,_that.amount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ModifierType modifierType,  double amount)  $default,) {final _that = this;
switch (_that) {
case _TransactionModifier():
return $default(_that.id,_that.modifierType,_that.amount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ModifierType modifierType,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModifier() when $default != null:
return $default(_that.id,_that.modifierType,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionModifier implements TransactionModifier {
  const _TransactionModifier({required this.id, required this.modifierType, required this.amount});
  

@override final  String id;
@override final  ModifierType modifierType;
@override final  double amount;

/// Create a copy of TransactionModifier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModifierCopyWith<_TransactionModifier> get copyWith => __$TransactionModifierCopyWithImpl<_TransactionModifier>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModifier&&(identical(other.id, id) || other.id == id)&&(identical(other.modifierType, modifierType) || other.modifierType == modifierType)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,id,modifierType,amount);

@override
String toString() {
  return 'TransactionModifier(id: $id, modifierType: $modifierType, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$TransactionModifierCopyWith<$Res> implements $TransactionModifierCopyWith<$Res> {
  factory _$TransactionModifierCopyWith(_TransactionModifier value, $Res Function(_TransactionModifier) _then) = __$TransactionModifierCopyWithImpl;
@override @useResult
$Res call({
 String id, ModifierType modifierType, double amount
});




}
/// @nodoc
class __$TransactionModifierCopyWithImpl<$Res>
    implements _$TransactionModifierCopyWith<$Res> {
  __$TransactionModifierCopyWithImpl(this._self, this._then);

  final _TransactionModifier _self;
  final $Res Function(_TransactionModifier) _then;

/// Create a copy of TransactionModifier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? modifierType = null,Object? amount = null,}) {
  return _then(_TransactionModifier(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,modifierType: null == modifierType ? _self.modifierType : modifierType // ignore: cast_nullable_to_non_nullable
as ModifierType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
