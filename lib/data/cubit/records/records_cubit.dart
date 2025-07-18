import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:human_benchmark/data/model/game_records.dart';
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

  Future<void> handleNewGameResult(GameRecords newRecords) async {
    if (newRecords.lastChimpScore > newRecords.chimpHighScore) {
      newRecords = newRecords.copyWith(
        chimpHighScore: newRecords.lastChimpScore,
      );
    }

    if (newRecords.lastReactionScore < newRecords.fastestReactionTime ||
        newRecords.fastestReactionTime == 0) {
      newRecords = newRecords.copyWith(
        fastestReactionTime: newRecords.lastReactionScore,
      );
    }

    if (newRecords.lastVisualMemoryScore >
        newRecords.longestVisualMemorySequence) {
      newRecords = newRecords.copyWith(
        longestVisualMemorySequence: newRecords.lastVisualMemoryScore,
      );
    }

    if (newRecords.lastReactionQueueScore > newRecords.reactionQueueHighScore) {
      newRecords = newRecords.copyWith(
        reactionQueueHighScore: newRecords.lastReactionQueueScore,
      );
    }

    emit(RecordsState.loaded(newRecords));
    await recordsRepository.saveGameRecords(newRecords);
  }

  void saveReactionQueueTestResult(int score) async {
    await state.whenOrNull(
      loaded: (records) async {
        final newRecords = records.copyWith(
          lastReactionQueueScore: score,
          lastWasReactionQueue: true,
          lastWasChimp: false,
          lastWasReaction: false,
          lastWasVisualMemory: false,
        );
        await handleNewGameResult(newRecords);
      },
    );
  }

  void saveReactionGameResult(int score) async {
    await state.whenOrNull(
      initial: () {
        print(
          'Initial state, loading records before saving reaction game result.',
        );
      },
      loaded: (records) async {
        print('Saving reaction game result: $score');
        final newRecords = records.copyWith(
          // fastestReactionTime: score,
          lastReactionScore: score,
          lastWasChimp: false,
          lastWasReaction: true,
          lastWasReactionQueue: false,
          lastWasVisualMemory: false,
        );
        await handleNewGameResult(newRecords);
      },
    );
  }

  void saveVisualMemoryGameResult(int score) async {
    await state.whenOrNull(
      loaded: (records) async {
        final newRecords = records.copyWith(
          // longestVisualMemorySequence: score,
          lastVisualMemoryScore: score,
          lastWasChimp: false,
          lastWasReaction: false,
          lastWasReactionQueue: false,
          lastWasVisualMemory: true,
        );
        await handleNewGameResult(newRecords);
      },
    );
  }

  void saveChimpGameResult(int score) async {
    await state.whenOrNull(
      loaded: (records) async {
        final newRecords = records.copyWith(
          lastWasChimp: true,
          lastWasReaction: false,
          lastWasReactionQueue: false,
          lastWasVisualMemory: false,
          lastChimpScore: score,
        );
        await handleNewGameResult(newRecords);
      },
    );
  }
}
