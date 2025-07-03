import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:human_benchmark/data/chimp_test_result.dart';

part 'game_result_state.dart';
part 'game_result_cubit.freezed.dart';

class GameResultCubit extends Cubit<GameResultState> {
  GameResultCubit() : super(const GameResultState.initial());

  void chimpGameOver(ChimpTestResult result) {
    emit(GameResultState.chimp_result(result));
  }

  void reset() {
    emit(const GameResultState.initial());
  }
}
