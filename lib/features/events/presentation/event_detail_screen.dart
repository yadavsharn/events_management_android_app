import 'dart:async';
import 'package:event_management_realtime/features/auth/presentation/auth_controller.dart';
import 'package:event_management_realtime/features/events/domain/event_entity.dart';
import 'package:event_management_realtime/features/events/presentation/event_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'event-detail';
  final String eventId;
  final EventEntity? event; // Optional, passed from list for instant load

  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.event,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.event?.videoUrl != null) {
      _initializeVideoPlayer(widget.event!.videoUrl!);
    }
    if (widget.event != null) {
      _startTimer();
    }
  }

  void _startTimer() {
    final eventStart = widget.event!.startTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (eventStart.isAfter(now)) {
        setState(() {
          _timeLeft = eventStart.difference(now);
        });
      } else {
        timer.cancel();
        setState(() {
          _timeLeft = Duration.zero;
        });
      }
    });
    // Initial set
    final now = DateTime.now();
    if (eventStart.isAfter(now)) {
      _timeLeft = eventStart.difference(now);
    }
  }

  Future<void> _initializeVideoPlayer(String url) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return 'Event Started';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '$days d $hours h $minutes m $seconds s';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isAdmin = user?.role == 'admin';

    // If event is passed, use it. Otherwise fetch (not implemented here for simplicity, assuming passed)
    // In a real app, we might fetch by ID if deep linked.
    final event = widget.event; 

    if (event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(eventControllerProvider.notifier).deleteEvent(context, event.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel (Simple PageView)
            if (event.images.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: event.images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      event.images[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ).animate().fadeIn(),
            
            // Video Player
            if (event.videoUrl != null && _chewieController != null)
              SizedBox(
                height: 250,
                child: Chewie(controller: _chewieController!),
              ).animate().fadeIn(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Countdown Timer
                  if (_timeLeft.inSeconds > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).primaryColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer),
                          const SizedBox(width: 8),
                          Text(
                            'Starts in: ${_formatDuration(_timeLeft)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale().shimmer(duration: 2.seconds),

                  const SizedBox(height: 16),

                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ).animate().slideX(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(DateFormat.yMMMd().add_jm().format(event.startTime)),
                    ],
                  ).animate().slideX(delay: 100.ms),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(event.location),
                    ],
                  ).animate().slideX(delay: 200.ms),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 4),
                  Text(event.description).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                  
                  // Interested Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(eventControllerProvider.notifier).markInterested(context, event.id);
                      },
                      icon: const Icon(Icons.star_border),
                      label: const Text('Interested'),
                    ),
                  ).animate().scale(delay: 500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
