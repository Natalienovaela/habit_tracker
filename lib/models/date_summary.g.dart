// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DateSummaryAdapter extends TypeAdapter<DateSummary> {
  @override
  final int typeId = 4;

  @override
  DateSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DateSummary(
      date: fields[0] as String,
      habitCompleted: (fields[1] as List?)?.cast<Habit>(),
      habitIncompleted: (fields[2] as List?)?.cast<Habit>(),
    );
  }

  @override
  void write(BinaryWriter writer, DateSummary obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.habitCompleted)
      ..writeByte(2)
      ..write(obj.habitIncompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
