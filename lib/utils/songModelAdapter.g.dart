// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songModelAdapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongTypeAdapter extends TypeAdapter<SongType> {
  @override
  final int typeId = 0;

  @override
  SongType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongType(
      id: fields[0] as int,
      title: fields[1] as String,
      uri: fields[2] as String,
      artist: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SongType obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.uri)
      ..writeByte(3)
      ..write(obj.artist);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
