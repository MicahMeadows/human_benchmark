// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_result_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameResultState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameResultState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameResultState()';
}


}

/// @nodoc
class $GameResultStateCopyWith<$Res>  {
$GameResultStateCopyWith(GameResultState _, $Res Function(GameResultState) __);
}


/// Adds pattern-matching-related methods to [GameResultState].
extension GameResultStatePatterns on GameResultState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _ChimpResult value)?  setChimpResult,TResult Function( _VisualMemoryResult value)?  setVisualMemoryResult,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _ChimpResult() when setChimpResult != null:
return setChimpResult(_that);case _VisualMemoryResult() when setVisualMemoryResult != null:
return setVisualMemoryResult(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _ChimpResult value)  setChimpResult,required TResult Function( _VisualMemoryResult value)  setVisualMemoryResult,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _ChimpResult():
return setChimpResult(_that);case _VisualMemoryResult():
return setVisualMemoryResult(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _ChimpResult value)?  setChimpResult,TResult? Function( _VisualMemoryResult value)?  setVisualMemoryResult,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _ChimpResult() when setChimpResult != null:
return setChimpResult(_that);case _VisualMemoryResult() when setVisualMemoryResult != null:
return setVisualMemoryResult(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( dynamic ChimpTestResult)?  setChimpResult,TResult Function( dynamic VisualMemoryResult)?  setVisualMemoryResult,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _ChimpResult() when setChimpResult != null:
return setChimpResult(_that.ChimpTestResult);case _VisualMemoryResult() when setVisualMemoryResult != null:
return setVisualMemoryResult(_that.VisualMemoryResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( dynamic ChimpTestResult)  chimpResult,required TResult Function( dynamic VisualMemoryResult)  visualMemoryResult,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _ChimpResult():
return chimpResult(_that.ChimpTestResult);case _VisualMemoryResult():
return visualMemoryResult(_that.VisualMemoryResult);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( dynamic ChimpTestResult)?  setChimpResult,TResult? Function( dynamic VisualMemoryResult)?  setVisualMemoryResult,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _ChimpResult() when setChimpResult != null:
return setChimpResult(_that.ChimpTestResult);case _VisualMemoryResult() when setVisualMemoryResult != null:
return setVisualMemoryResult(_that.VisualMemoryResult);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements GameResultState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameResultState.initial()';
}


}




/// @nodoc


class _ChimpResult implements GameResultState {
  const _ChimpResult(this.ChimpTestResult);
  

 final  dynamic ChimpTestResult;

/// Create a copy of GameResultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChimpResultCopyWith<_ChimpResult> get copyWith => __$ChimpResultCopyWithImpl<_ChimpResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChimpResult&&const DeepCollectionEquality().equals(other.ChimpTestResult, ChimpTestResult));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ChimpTestResult));

@override
String toString() {
  return 'GameResultState.setChimpResult(ChimpTestResult: $ChimpTestResult)';
}


}

/// @nodoc
abstract mixin class _$ChimpResultCopyWith<$Res> implements $GameResultStateCopyWith<$Res> {
  factory _$ChimpResultCopyWith(_ChimpResult value, $Res Function(_ChimpResult) _then) = __$ChimpResultCopyWithImpl;
@useResult
$Res call({
 dynamic ChimpTestResult
});




}
/// @nodoc
class __$ChimpResultCopyWithImpl<$Res>
    implements _$ChimpResultCopyWith<$Res> {
  __$ChimpResultCopyWithImpl(this._self, this._then);

  final _ChimpResult _self;
  final $Res Function(_ChimpResult) _then;

/// Create a copy of GameResultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ChimpTestResult = freezed,}) {
  return _then(_ChimpResult(
freezed == ChimpTestResult ? _self.ChimpTestResult : ChimpTestResult // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc


class _VisualMemoryResult implements GameResultState {
  const _VisualMemoryResult(this.VisualMemoryResult);
  

 final  dynamic VisualMemoryResult;

/// Create a copy of GameResultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisualMemoryResultCopyWith<_VisualMemoryResult> get copyWith => __$VisualMemoryResultCopyWithImpl<_VisualMemoryResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisualMemoryResult&&const DeepCollectionEquality().equals(other.VisualMemoryResult, VisualMemoryResult));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(VisualMemoryResult));

@override
String toString() {
  return 'GameResultState.setVisualMemoryResult(VisualMemoryResult: $VisualMemoryResult)';
}


}

/// @nodoc
abstract mixin class _$VisualMemoryResultCopyWith<$Res> implements $GameResultStateCopyWith<$Res> {
  factory _$VisualMemoryResultCopyWith(_VisualMemoryResult value, $Res Function(_VisualMemoryResult) _then) = __$VisualMemoryResultCopyWithImpl;
@useResult
$Res call({
 dynamic VisualMemoryResult
});




}
/// @nodoc
class __$VisualMemoryResultCopyWithImpl<$Res>
    implements _$VisualMemoryResultCopyWith<$Res> {
  __$VisualMemoryResultCopyWithImpl(this._self, this._then);

  final _VisualMemoryResult _self;
  final $Res Function(_VisualMemoryResult) _then;

/// Create a copy of GameResultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? VisualMemoryResult = freezed,}) {
  return _then(_VisualMemoryResult(
freezed == VisualMemoryResult ? _self.VisualMemoryResult : VisualMemoryResult // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
