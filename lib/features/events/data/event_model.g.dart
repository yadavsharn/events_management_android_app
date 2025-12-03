// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 0;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      location: fields[3] as String,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime,
      createdBy: fields[6] as String,
      images: (fields[7] as List).cast<String>(),
      videoUrl: fields[8] as String?,
      attendeesCount: fields[9] as int,
      status: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.images)
      ..writeByte(8)
      ..write(obj.videoUrl)
      ..writeByte(9)
      ..write(obj.attendeesCount)
      ..writeByte(10)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      createdBy: json['createdBy'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      videoUrl: json['videoUrl'] as String?,
      attendeesCount: (json['attendeesCount'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'createdBy': instance.createdBy,
      'images': instance.images,
      'videoUrl': instance.videoUrl,
      'attendeesCount': instance.attendeesCount,
      'status': instance.status,
    };
