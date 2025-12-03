import 'package:event_management_realtime/features/events/domain/event_entity.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class EventModel extends EventEntity {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final String description;
  @override
  @HiveField(3)
  final String location;
  @override
  @HiveField(4)
  final DateTime startTime;
  @override
  @HiveField(5)
  final DateTime endTime;
  @override
  @HiveField(6)
  final String createdBy;
  @override
  @HiveField(7)
  final List<String> images;
  @override
  @HiveField(8)
  final String? videoUrl;
  @override
  @HiveField(9)
  final int attendeesCount;
  @override
  @HiveField(10)
  final String status;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.images,
    this.videoUrl,
    required this.attendeesCount,
    required this.status,
  }) : super(
          id: id,
          title: title,
          description: description,
          location: location,
          startTime: startTime,
          endTime: endTime,
          createdBy: createdBy,
          images: images,
          videoUrl: videoUrl,
          attendeesCount: attendeesCount,
          status: status,
        );

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  factory EventModel.fromSupabase(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      createdBy: map['created_by'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      videoUrl: map['video_url'],
      attendeesCount: map['attendees_count'] ?? 0,
      status: map['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'created_by': createdBy,
      'images': images,
      'video_url': videoUrl,
      'attendees_count': attendeesCount,
      'status': status,
    };
  }
}
