// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackEntryAdapter extends TypeAdapter<TrackEntry> {
  @override
  final int typeId = 0;

  @override
  TrackEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackEntry(
      id: fields[0] as String,
      title: fields[1] as String,
      goals: (fields[2] as List).cast<Goal>(),
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TrackEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.goals)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
