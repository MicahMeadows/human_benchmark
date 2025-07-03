part of 'game_result_cubit.dart';

@freezed
abstract class GameResultState with _$GameResultState {
  const factory GameResultState.initial() = _Initial;
  const factory GameResultState.chimp_result(ChimpTestResult) = _ChimpResult;
}
