import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:human_benchmark/data/model/chimp_test_result.dart';
import 'package:human_benchmark/data/model/game_records.dart';
import 'package:human_benchmark/data/model/reaction_test_result.dart';
import 'package:human_benchmark/data/model/visual_memory_test_result.dart';
import 'package:human_benchmark/data/repository/i_records_repository.dart';

part 'records_state.dart';
part 'records_cubit.freezed.dart';

class RecordsCubit extends Cubit<RecordsState> {
  final IRecordsRepository recordsRepository;

  RecordsCubit({
    required this.recordsRepository,
  }) : super(const RecordsState.initial());

  void loadRecords() async {
    final records = await recordsRepository.getGameRecords();
    emit(RecordsState.loaded(records));
    print('Loaded records: $records');
  }

  void saveReactionGameResult(ReactionTestResult result) async {
    await state.whenOrNull(
      initial: () {
        print(
          'Initial state, loading records before saving reaction game result.',
        );
      },
      loaded: (records) async {
        print('Saving reaction game result: $result');
        if (result.averageMs < records.fastestReactionTime ||
            records.fastestReactionTime == 0) {
          final newRecords = records.copyWith(
            fastestReactionTime: result.averageMs,
          );
          recordsRepository.saveGameRecords(newRecords);
          emit(RecordsState.loaded(newRecords));
        }
      },
    );
  }

  void saveVisualMemoryGameResult(VisualMemoryTestResult result) async {
    await state.whenOrNull(
      loaded: (records) async {
        if (result.tileCount > records.longestVisualMemorySequence) {
          final newRecords = records.copyWith(
            longestVisualMemorySequence: result.tileCount,
          );
          await recordsRepository.saveGameRecords(newRecords);
          emit(RecordsState.loaded(newRecords));
        }
      },
    );
  }

  void saveChimpGameResult(ChimpTestResult result) async {
    await state.whenOrNull(
      loaded: (records) async {
        if (result.highScore > records.chimpHighScore) {
          final newRecords = records.copyWith(
            chimpHighScore: result.highScore,
          );
          await recordsRepository.saveGameRecords(newRecords);
          emit(RecordsState.loaded(newRecords));
        }
      },
    );
  }
}
