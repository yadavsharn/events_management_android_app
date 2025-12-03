import 'package:event_management_realtime/core/widgets/loader.dart';
import 'package:event_management_realtime/features/analytics/presentation/analytics_screen.dart';
import 'package:event_management_realtime/features/auth/presentation/auth_controller.dart';
import 'package:event_management_realtime/features/events/domain/event_entity.dart';
import 'package:event_management_realtime/features/events/presentation/create_edit_event_screen.dart';
import 'package:event_management_realtime/features/events/presentation/event_controller.dart';
import 'package:event_management_realtime/features/events/presentation/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventListScreen extends ConsumerWidget {
  static const routeName = '/events';
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isAdmin = user?.role == 'admin';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          actions: [
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.analytics),
                onPressed: () {
                  context.push(AnalyticsScreen.routeName);
                },
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut(context);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EventList(status: 'upcoming'),
            EventList(status: 'ongoing'),
            EventList(status: 'completed'),
          ],
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                onPressed: () {
                  context.pushNamed(CreateEditEventScreen.routeName);
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}

class EventList extends ConsumerWidget {
  final String status;
  const EventList({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsyncValue = ref.watch(getEventsProvider);

    return eventsAsyncValue.when(
      data: (events) {
        final filteredEvents = events.where((e) => e.status == status).toList();

        if (filteredEvents.isEmpty) {
          return const Center(child: Text('No events found.'));
        }

        return ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            return EventCard(event: event);
          },
        );
      },
      error: (err, st) => Center(child: Text(err.toString())),
      loading: () => const Loader(),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventEntity event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            EventDetailScreen.routeName,
            pathParameters: {'id': event.id},
            extra: event,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.images.isNotEmpty)
              Image.network(
                event.images.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 150, child: Center(child: Icon(Icons.error))),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().add_jm().format(event.startTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(event.location),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
