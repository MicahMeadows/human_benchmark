import 'package:human_benchmark/data/model/game_records.dart';

abstract class IRecordsRepository {
  Future<GameRecords> getGameRecords();
  Future<void> saveGameRecords(GameRecords records);
}
