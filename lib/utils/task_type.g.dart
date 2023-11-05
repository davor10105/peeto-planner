// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannerTaskTypeAdapter extends TypeAdapter<PlannerTaskType> {
  @override
  final int typeId = 2;

  @override
  PlannerTaskType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannerTaskType(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlannerTaskType obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.typeName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannerTaskTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
