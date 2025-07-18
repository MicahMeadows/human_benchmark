import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_records.freezed.dart';
part 'game_records.g.dart';

@freezed
sealed class GameRecords with _$GameRecords {
  const factory GameRecords({
    required int fastestReactionTime,
    required int longestVisualMemorySequence,
    required int chimpHighScore,
    required int reactionQueueHighScore,

    required int lastReactionScore,
    required int lastReactionQueueScore,
    required int lastChimpScore,
    required int lastVisualMemoryScore,

    required bool lastWasReaction,
    required bool lastWasReactionQueue,
    required bool lastWasChimp,
    required bool lastWasVisualMemory,
  }) = _GameRecords;

  factory GameRecords.fromJson(Map<String, dynamic> json) =>
      _$GameRecordsFromJson(json);
}
