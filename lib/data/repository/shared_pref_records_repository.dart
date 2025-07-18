import 'package:human_benchmark/data/model/game_records.dart';
import 'package:human_benchmark/data/repository/i_records_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefRecordsRepository implements IRecordsRepository {
  GameRecords? currentRecords;

  @override
  Future<GameRecords> getGameRecords() async {
    if (currentRecords == null) {
      final prefs = await SharedPreferences.getInstance();
      // prefs.clear();
      final rawRecords = prefs.getString('game_records');

      if (rawRecords == null || rawRecords.isEmpty) {
        return GameRecords(
          fastestReactionTime: 0,
          chimpHighScore: 0,
          longestVisualMemorySequence: 0,
          reactionQueueHighScore: 0,

          lastChimpScore: 0,
          lastReactionQueueScore: 0,
          lastReactionScore: 0,
          lastVisualMemoryScore: 0,

          lastWasChimp: false,
          lastWasReaction: false,
          lastWasReactionQueue: false,
          lastWasVisualMemory: false,
        );
      }

      final recordsJson = json.decode(rawRecords);

      final records = GameRecords.fromJson(recordsJson);
      currentRecords = records;
    }

    print('loaded records: $currentRecords');

    return currentRecords!;
  }

  void persistCurrentRecords() async {
    if (currentRecords != null) {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = currentRecords!.toJson();
      await prefs.setString('game_records', json.encode(recordsJson));
      print('Saved records: $recordsJson');
    }
  }

  @override
  Future<void> saveGameRecords(GameRecords records) async {
    if (currentRecords == null) {
      currentRecords = records;
      persistCurrentRecords();
      return;
    }

    bool chimpIsHigher =
        records.chimpHighScore > currentRecords!.chimpHighScore;

    bool reactionIsHigher =
        records.fastestReactionTime < currentRecords!.fastestReactionTime;

    bool visualMemoryIsHigher =
        records.longestVisualMemorySequence >
        currentRecords!.longestVisualMemorySequence;

    bool reactionQueueIsHigher =
        records.reactionQueueHighScore > currentRecords!.reactionQueueHighScore;

    if (chimpIsHigher ||
        reactionIsHigher ||
        visualMemoryIsHigher ||
        reactionQueueIsHigher) {
      currentRecords = records;
      persistCurrentRecords();
      return;
    }
  }
}
