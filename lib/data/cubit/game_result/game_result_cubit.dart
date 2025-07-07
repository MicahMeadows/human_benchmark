import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:human_benchmark/data/model/chimp_test_result.dart';
import 'package:human_benchmark/data/model/visual_memory_test_result.dart';

part 'game_result_state.dart';
part 'game_result_cubit.freezed.dart';

class GameResultCubit extends Cubit<GameResultState> {
  GameResultCubit() : super(const GameResultState.initial());

  void reactionTestOver(int reactionTime) {
    emit(GameResultState.reactionTest(reactionTime));
  }

  void chimpTestOver(ChimpTestResult result) {
    emit(GameResultState.chimpTest(result));
  }

  void visualMemoryTestOver(VisualMemoryTestResult result) {
    emit(GameResultState.visualMemoryTest(result));
  }

  void reset() {
    emit(const GameResultState.initial());
  }
}
