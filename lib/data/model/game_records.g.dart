// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_records.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameRecords _$GameRecordsFromJson(Map<String, dynamic> json) => _GameRecords(
  fastestReactionTime: (json['fastestReactionTime'] as num).toInt(),
  longestVisualMemorySequence: (json['longestVisualMemorySequence'] as num)
      .toInt(),
  chimpHighScore: (json['chimpHighScore'] as num).toInt(),
);

Map<String, dynamic> _$GameRecordsToJson(_GameRecords instance) =>
    <String, dynamic>{
      'fastestReactionTime': instance.fastestReactionTime,
      'longestVisualMemorySequence': instance.longestVisualMemorySequence,
      'chimpHighScore': instance.chimpHighScore,
    };
