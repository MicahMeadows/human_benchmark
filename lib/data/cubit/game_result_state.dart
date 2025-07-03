part of 'game_result_cubit.dart';

@freezed
abstract class GameResultState with _$GameResultState {
  const factory GameResultState.initial() = _Initial;
  const factory GameResultState.chimpTest(ChimpTestResult) = _ChimpResult;
  const factory GameResultState.reactionTest(int reactionTime) =
      _ReactionTimeResult;
  const factory GameResultState.visualMemoryTest(VisualMemoryResult) =
      _VisualMemoryResult;
}
