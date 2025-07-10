// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_records.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameRecords {

 int get fastestReactionTime; int get longestVisualMemorySequence; int get chimpHighScore;
/// Create a copy of GameRecords
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameRecordsCopyWith<GameRecords> get copyWith => _$GameRecordsCopyWithImpl<GameRecords>(this as GameRecords, _$identity);

  /// Serializes this GameRecords to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameRecords&&(identical(other.fastestReactionTime, fastestReactionTime) || other.fastestReactionTime == fastestReactionTime)&&(identical(other.longestVisualMemorySequence, longestVisualMemorySequence) || other.longestVisualMemorySequence == longestVisualMemorySequence)&&(identical(other.chimpHighScore, chimpHighScore) || other.chimpHighScore == chimpHighScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fastestReactionTime,longestVisualMemorySequence,chimpHighScore);

@override
String toString() {
  return 'GameRecords(fastestReactionTime: $fastestReactionTime, longestVisualMemorySequence: $longestVisualMemorySequence, chimpHighScore: $chimpHighScore)';
}


}

/// @nodoc
abstract mixin class $GameRecordsCopyWith<$Res>  {
  factory $GameRecordsCopyWith(GameRecords value, $Res Function(GameRecords) _then) = _$GameRecordsCopyWithImpl;
@useResult
$Res call({
 int fastestReactionTime, int longestVisualMemorySequence, int chimpHighScore
});




}
/// @nodoc
class _$GameRecordsCopyWithImpl<$Res>
    implements $GameRecordsCopyWith<$Res> {
  _$GameRecordsCopyWithImpl(this._self, this._then);

  final GameRecords _self;
  final $Res Function(GameRecords) _then;

/// Create a copy of GameRecords
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fastestReactionTime = null,Object? longestVisualMemorySequence = null,Object? chimpHighScore = null,}) {
  return _then(_self.copyWith(
fastestReactionTime: null == fastestReactionTime ? _self.fastestReactionTime : fastestReactionTime // ignore: cast_nullable_to_non_nullable
as int,longestVisualMemorySequence: null == longestVisualMemorySequence ? _self.longestVisualMemorySequence : longestVisualMemorySequence // ignore: cast_nullable_to_non_nullable
as int,chimpHighScore: null == chimpHighScore ? _self.chimpHighScore : chimpHighScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameRecords].
extension GameRecordsPatterns on GameRecords {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameRecords value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameRecords() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameRecords value)  $default,){
final _that = this;
switch (_that) {
case _GameRecords():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameRecords value)?  $default,){
final _that = this;
switch (_that) {
case _GameRecords() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int fastestReactionTime,  int longestVisualMemorySequence,  int chimpHighScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameRecords() when $default != null:
return $default(_that.fastestReactionTime,_that.longestVisualMemorySequence,_that.chimpHighScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int fastestReactionTime,  int longestVisualMemorySequence,  int chimpHighScore)  $default,) {final _that = this;
switch (_that) {
case _GameRecords():
return $default(_that.fastestReactionTime,_that.longestVisualMemorySequence,_that.chimpHighScore);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int fastestReactionTime,  int longestVisualMemorySequence,  int chimpHighScore)?  $default,) {final _that = this;
switch (_that) {
case _GameRecords() when $default != null:
return $default(_that.fastestReactionTime,_that.longestVisualMemorySequence,_that.chimpHighScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameRecords implements GameRecords {
  const _GameRecords({required this.fastestReactionTime, required this.longestVisualMemorySequence, required this.chimpHighScore});
  factory _GameRecords.fromJson(Map<String, dynamic> json) => _$GameRecordsFromJson(json);

@override final  int fastestReactionTime;
@override final  int longestVisualMemorySequence;
@override final  int chimpHighScore;

/// Create a copy of GameRecords
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameRecordsCopyWith<_GameRecords> get copyWith => __$GameRecordsCopyWithImpl<_GameRecords>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameRecordsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameRecords&&(identical(other.fastestReactionTime, fastestReactionTime) || other.fastestReactionTime == fastestReactionTime)&&(identical(other.longestVisualMemorySequence, longestVisualMemorySequence) || other.longestVisualMemorySequence == longestVisualMemorySequence)&&(identical(other.chimpHighScore, chimpHighScore) || other.chimpHighScore == chimpHighScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fastestReactionTime,longestVisualMemorySequence,chimpHighScore);

@override
String toString() {
  return 'GameRecords(fastestReactionTime: $fastestReactionTime, longestVisualMemorySequence: $longestVisualMemorySequence, chimpHighScore: $chimpHighScore)';
}


}

/// @nodoc
abstract mixin class _$GameRecordsCopyWith<$Res> implements $GameRecordsCopyWith<$Res> {
  factory _$GameRecordsCopyWith(_GameRecords value, $Res Function(_GameRecords) _then) = __$GameRecordsCopyWithImpl;
@override @useResult
$Res call({
 int fastestReactionTime, int longestVisualMemorySequence, int chimpHighScore
});




}
/// @nodoc
class __$GameRecordsCopyWithImpl<$Res>
    implements _$GameRecordsCopyWith<$Res> {
  __$GameRecordsCopyWithImpl(this._self, this._then);

  final _GameRecords _self;
  final $Res Function(_GameRecords) _then;

/// Create a copy of GameRecords
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fastestReactionTime = null,Object? longestVisualMemorySequence = null,Object? chimpHighScore = null,}) {
  return _then(_GameRecords(
fastestReactionTime: null == fastestReactionTime ? _self.fastestReactionTime : fastestReactionTime // ignore: cast_nullable_to_non_nullable
as int,longestVisualMemorySequence: null == longestVisualMemorySequence ? _self.longestVisualMemorySequence : longestVisualMemorySequence // ignore: cast_nullable_to_non_nullable
as int,chimpHighScore: null == chimpHighScore ? _self.chimpHighScore : chimpHighScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
