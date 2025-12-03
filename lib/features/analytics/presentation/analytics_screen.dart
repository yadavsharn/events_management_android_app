import 'package:event_management_realtime/core/widgets/loader.dart';
import 'package:event_management_realtime/features/events/presentation/event_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsScreen extends ConsumerWidget {
  static const routeName = '/analytics';
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(getEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: eventsAsync.when(
        data: (events) {
          final totalEvents = events.length;
          final upcomingEvents = events.where((e) => e.status == 'upcoming').length;
          final ongoingEvents = events.where((e) => e.status == 'ongoing').length;
          final completedEvents = events.where((e) => e.status == 'completed').length;
          
          final today = DateTime.now();
          final todaysEvents = events.where((e) => 
            e.startTime.year == today.year && 
            e.startTime.month == today.month && 
            e.startTime.day == today.day
          ).length;

          // Top Locations
          final locationCounts = <String, int>{};
          for (var e in events) {
            locationCounts[e.location] = (locationCounts[e.location] ?? 0) + 1;
          }
          final topLocations = locationCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard('Total Events', totalEvents.toString(), Colors.blue),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Upcoming', upcomingEvents.toString(), Colors.orange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("Today's", todaysEvents.toString(), Colors.green)),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Event Status Distribution', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: upcomingEvents.toDouble(),
                          title: 'Upcoming',
                          color: Colors.orange,
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: ongoingEvents.toDouble(),
                          title: 'Ongoing',
                          color: Colors.blue,
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: completedEvents.toDouble(),
                          title: 'Completed',
                          color: Colors.grey,
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Top Locations', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ...topLocations.take(5).map((e) => ListTile(
                  title: Text(e.key),
                  trailing: Text('${e.value} events'),
                )),
              ],
            ),
          );
        },
        error: (err, st) => Center(child: Text(err.toString())),
        loading: () => const Loader(),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
