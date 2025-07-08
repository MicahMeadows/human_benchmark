part of 'records_cubit.dart';

@freezed
abstract class RecordsState with _$RecordsState {
  const factory RecordsState.initial() = _Initial;
  const factory RecordsState.loaded(GameRecords records) = _Loaded;
}
