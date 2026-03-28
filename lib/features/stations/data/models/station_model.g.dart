// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StationModelAdapter extends TypeAdapter<StationModel> {
  @override
  final int typeId = 0;

  @override
  StationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StationModel(
      stationuuid: fields[0] as String,
      name: fields[1] as String,
      url: fields[2] as String,
      urlResolved: fields[3] as String,
      homepage: fields[4] as String,
      favicon: fields[5] as String,
      tags: fields[6] as String,
      countrycode: fields[7] as String,
      votes: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.stationuuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.urlResolved)
      ..writeByte(4)
      ..write(obj.homepage)
      ..writeByte(5)
      ..write(obj.favicon)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.countrycode)
      ..writeByte(8)
      ..write(obj.votes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
