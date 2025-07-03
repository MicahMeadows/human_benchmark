part of 'game_result_cubit.dart';

@freezed
abstract class GameResultState with _$GameResultState {
  const factory GameResultState.initial() = _Initial;
  const factory GameResultState.setChimpResult(ChimpTestResult) = _ChimpResult;
  const factory GameResultState.setVisualMemoryResult(VisualMemoryResult) =
      _VisualMemoryResult;
}
