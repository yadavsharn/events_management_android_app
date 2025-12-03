import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String createdBy;
  final List<String> images;
  final String? videoUrl;
  final int attendeesCount;
  final String status; // 'upcoming', 'ongoing', 'completed'

  const EventEntity({
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
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        startTime,
        endTime,
        createdBy,
        images,
        videoUrl,
        attendeesCount,
        status,
      ];
}
