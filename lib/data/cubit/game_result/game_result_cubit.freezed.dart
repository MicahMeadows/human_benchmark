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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _ChimpResult value)?  chimpTest,TResult Function( _ReactionTimeResult value)?  reactionTest,TResult Function( _VisualMemoryResult value)?  visualMemoryTest,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _ChimpResult() when chimpTest != null:
return chimpTest(_that);case _ReactionTimeResult() when reactionTest != null:
return reactionTest(_that);case _VisualMemoryResult() when visualMemoryTest != null:
return visualMemoryTest(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _ChimpResult value)  chimpTest,required TResult Function( _ReactionTimeResult value)  reactionTest,required TResult Function( _VisualMemoryResult value)  visualMemoryTest,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _ChimpResult():
return chimpTest(_that);case _ReactionTimeResult():
return reactionTest(_that);case _VisualMemoryResult():
return visualMemoryTest(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _ChimpResult value)?  chimpTest,TResult? Function( _ReactionTimeResult value)?  reactionTest,TResult? Function( _VisualMemoryResult value)?  visualMemoryTest,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _ChimpResult() when chimpTest != null:
return chimpTest(_that);case _ReactionTimeResult() when reactionTest != null:
return reactionTest(_that);case _VisualMemoryResult() when visualMemoryTest != null:
return visualMemoryTest(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( dynamic ChimpTestResult)?  chimpTest,TResult Function( int reactionTime)?  reactionTest,TResult Function( dynamic VisualMemoryResult)?  visualMemoryTest,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _ChimpResult() when chimpTest != null:
return chimpTest(_that.ChimpTestResult);case _ReactionTimeResult() when reactionTest != null:
return reactionTest(_that.reactionTime);case _VisualMemoryResult() when visualMemoryTest != null:
return visualMemoryTest(_that.VisualMemoryResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( dynamic ChimpTestResult)  chimpTest,required TResult Function( int reactionTime)  reactionTest,required TResult Function( dynamic VisualMemoryResult)  visualMemoryTest,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _ChimpResult():
return chimpTest(_that.ChimpTestResult);case _ReactionTimeResult():
return reactionTest(_that.reactionTime);case _VisualMemoryResult():
return visualMemoryTest(_that.VisualMemoryResult);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( dynamic ChimpTestResult)?  chimpTest,TResult? Function( int reactionTime)?  reactionTest,TResult? Function( dynamic VisualMemoryResult)?  visualMemoryTest,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _ChimpResult() when chimpTest != null:
return chimpTest(_that.ChimpTestResult);case _ReactionTimeResult() when reactionTest != null:
return reactionTest(_that.reactionTime);case _VisualMemoryResult() when visualMemoryTest != null:
return visualMemoryTest(_that.VisualMemoryResult);case _:
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
  return 'GameResultState.chimpTest(ChimpTestResult: $ChimpTestResult)';
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


class _ReactionTimeResult implements GameResultState {
  const _ReactionTimeResult(this.reactionTime);
  

 final  int reactionTime;

/// Create a copy of GameResultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionTimeResultCopyWith<_ReactionTimeResult> get copyWith => __$ReactionTimeResultCopyWithImpl<_ReactionTimeResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReactionTimeResult&&(identical(other.reactionTime, reactionTime) || other.reactionTime == reactionTime));
}


@override
int get hashCode => Object.hash(runtimeType,reactionTime);

@override
String toString() {
  return 'GameResultState.reactionTest(reactionTime: $reactionTime)';
}


}

/// @nodoc
abstract mixin class _$ReactionTimeResultCopyWith<$Res> implements $GameResultStateCopyWith<$Res> {
  factory _$ReactionTimeResultCopyWith(_ReactionTimeResult value, $Res Function(_ReactionTimeResult) _then) = __$ReactionTimeResultCopyWithImpl;
@useResult
$Res call({
 int reactionTime
});




}
/// @nodoc
class __$ReactionTimeResultCopyWithImpl<$Res>
    implements _$ReactionTimeResultCopyWith<$Res> {
  __$ReactionTimeResultCopyWithImpl(this._self, this._then);

  final _ReactionTimeResult _self;
  final $Res Function(_ReactionTimeResult) _then;

/// Create a copy of GameResultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reactionTime = null,}) {
  return _then(_ReactionTimeResult(
null == reactionTime ? _self.reactionTime : reactionTime // ignore: cast_nullable_to_non_nullable
as int,
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
  return 'GameResultState.visualMemoryTest(VisualMemoryResult: $VisualMemoryResult)';
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
