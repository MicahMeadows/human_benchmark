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
  reactionQueueHighScore: (json['reactionQueueHighScore'] as num).toInt(),
  lastReactionScore: (json['lastReactionScore'] as num).toInt(),
  lastReactionQueueScore: (json['lastReactionQueueScore'] as num).toInt(),
  lastChimpScore: (json['lastChimpScore'] as num).toInt(),
  lastVisualMemoryScore: (json['lastVisualMemoryScore'] as num).toInt(),
  lastWasReaction: json['lastWasReaction'] as bool,
  lastWasReactionQueue: json['lastWasReactionQueue'] as bool,
  lastWasChimp: json['lastWasChimp'] as bool,
  lastWasVisualMemory: json['lastWasVisualMemory'] as bool,
);

Map<String, dynamic> _$GameRecordsToJson(_GameRecords instance) =>
    <String, dynamic>{
      'fastestReactionTime': instance.fastestReactionTime,
      'longestVisualMemorySequence': instance.longestVisualMemorySequence,
      'chimpHighScore': instance.chimpHighScore,
      'reactionQueueHighScore': instance.reactionQueueHighScore,
      'lastReactionScore': instance.lastReactionScore,
      'lastReactionQueueScore': instance.lastReactionQueueScore,
      'lastChimpScore': instance.lastChimpScore,
      'lastVisualMemoryScore': instance.lastVisualMemoryScore,
      'lastWasReaction': instance.lastWasReaction,
      'lastWasReactionQueue': instance.lastWasReactionQueue,
      'lastWasChimp': instance.lastWasChimp,
      'lastWasVisualMemory': instance.lastWasVisualMemory,
    };
