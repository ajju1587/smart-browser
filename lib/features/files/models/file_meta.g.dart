// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_meta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileMetaAdapter extends TypeAdapter<FileMeta> {
  @override
  final int typeId = 0;

  @override
  FileMeta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileMeta(
      id: fields[0] as String,
      sourceUrl: fields[1] as String?,
      path: fields[2] as String,
      name: fields[3] as String,
      size: fields[4] as int,
      mime: fields[5] as String,
      createdAt: fields[6] as DateTime?,
      status: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FileMeta obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sourceUrl)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.size)
      ..writeByte(5)
      ..write(obj.mime)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileMetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
