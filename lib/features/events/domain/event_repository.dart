import 'dart:io';
import 'package:event_management_realtime/core/utils/type_defs.dart';
import 'package:event_management_realtime/features/events/domain/event_entity.dart';

abstract class EventRepository {
  FutureEither<List<EventEntity>> getEvents();
  
  Stream<List<EventEntity>> getEventsStream();

  FutureEither<EventEntity> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required List<File> images,
    File? video,
  });

  FutureEither<void> deleteEvent(String eventId);

  FutureEither<void> markInterested(String eventId);
}
