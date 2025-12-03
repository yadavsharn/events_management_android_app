import 'dart:io';
import 'package:event_management_realtime/core/utils/utils.dart';
import 'package:event_management_realtime/features/events/data/event_repository_impl.dart';
import 'package:event_management_realtime/features/events/domain/event_repository.dart';
import 'package:event_management_realtime/features/events/domain/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventControllerProvider = StateNotifierProvider<EventController, bool>((ref) {
  return EventController(
    eventRepository: ref.watch(eventRepositoryProvider),
    ref: ref,
  );
});

final getEventsProvider = StreamProvider((ref) {
  final eventController = ref.watch(eventControllerProvider.notifier);
  return eventController.getEventsStream();
});

class EventController extends StateNotifier<bool> {
  final EventRepository _eventRepository;
  final Ref _ref;

  EventController({
    required EventRepository eventRepository,
    required Ref ref,
  })  : _eventRepository = eventRepository,
        _ref = ref,
        super(false);

  Stream<List<EventEntity>> getEventsStream() {
    return _eventRepository.getEventsStream();
  }

  Future<void> createEvent({
    required BuildContext context,
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required List<File> images,
    File? video,
  }) async {
    state = true;
    final res = await _eventRepository.createEvent(
      title: title,
      description: description,
      location: location,
      startTime: startTime,
      endTime: endTime,
      images: images,
      video: video,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Event created successfully!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> deleteEvent(BuildContext context, String eventId) async {
    final res = await _eventRepository.deleteEvent(eventId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Event deleted successfully!'),
    );
  }

  Future<void> markInterested(BuildContext context, String eventId) async {
    final res = await _eventRepository.markInterested(eventId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {}, // Success, UI updates via stream
    );
  }
}
