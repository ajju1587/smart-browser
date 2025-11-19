// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SummaryAdapter extends TypeAdapter<Summary> {
  @override
  final int typeId = 1;

  @override
  Summary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Summary(
      id: fields[0] as String,
      title: fields[1] as String,
      sourceUrl: fields[2] as String?,
      content: fields[3] as String,
      language: fields[4] as String,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Summary obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.sourceUrl)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.language)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
