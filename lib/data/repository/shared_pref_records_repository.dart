import 'package:human_benchmark/data/model/game_records.dart';
import 'package:human_benchmark/data/repository/i_records_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefRecordsRepository implements IRecordsRepository {
  @override
  Future<GameRecords> getGameRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final rawRecords = prefs.getString('game_records');

    if (rawRecords == null || rawRecords.isEmpty) {
      return GameRecords(
        fastestReactionTime: 0,
        longestChimpTestSequence: 0,
        longestVisualMemorySequence: 0,
      );
    }

    final recordsJson = json.decode(rawRecords);

    final records = GameRecords.fromJson(recordsJson);
    return records;
  }

  @override
  Future<void> saveGameRecords(GameRecords records) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = records.toJson();
    await prefs.setString('game_records', json.encode(recordsJson));
    print('Saved records: $recordsJson');
  }
}
