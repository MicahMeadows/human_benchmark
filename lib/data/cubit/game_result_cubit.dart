import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:human_benchmark/data/model/chimp_test_result.dart';
import 'package:human_benchmark/data/model/visual_memory_test_result.dart';

part 'game_result_state.dart';
part 'game_result_cubit.freezed.dart';

class GameResultCubit extends Cubit<GameResultState> {
  GameResultCubit() : super(const GameResultState.initial());

  void chimpGameOver(ChimpTestResult result) {
    emit(GameResultState.setChimpResult(result));
  }

  void visualMemoryGameOver(VisualMemoryTestResult result) {
    emit(GameResultState.setVisualMemoryResult(result));
  }

  void reset() {
    emit(const GameResultState.initial());
  }
}
