import 'dart:io';
import 'package:event_management_realtime/core/widgets/custom_button.dart';
import 'package:event_management_realtime/core/widgets/custom_text_field.dart';
import 'package:event_management_realtime/core/widgets/loader.dart';
import 'package:event_management_realtime/features/events/presentation/event_controller.dart';
import 'package:event_management_realtime/features/media/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateEditEventScreen extends ConsumerStatefulWidget {
  static const routeName = '/create-event';
  const CreateEditEventScreen({super.key});

  @override
  ConsumerState<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends ConsumerState<CreateEditEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2));
  final List<File> _images = [];
  File? _video;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _selectImages() async {
    final images = await ref.read(mediaServiceProvider).pickImages();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images);
      });
    }
  }

  void _selectVideo() async {
    final video = await ref.read(mediaServiceProvider).pickVideo();
    if (video != null) {
      // Compress video
      // Show loader or something? For now just await
      final compressed = await ref.read(mediaServiceProvider).compressVideo(video);
      setState(() {
        _video = compressed ?? video; // Fallback to original if compression fails
      });
    }
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      ref.read(eventControllerProvider.notifier).createEvent(
            context: context,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            location: _locationController.text.trim(),
            startTime: _startTime,
            endTime: _endTime,
            images: _images,
            video: _video,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(eventControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(controller: _titleController, hintText: 'Title'),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _descriptionController, hintText: 'Description'),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _locationController, hintText: 'Location'),
                    const SizedBox(height: 16),
                    
                    // Date Pickers (Simplified)
                      ListTile(
                        title: Text('Start Time: ${_startTime.toString().split('.')[0]}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_startTime),
                            );
                            if (time != null) {
                              setState(() {
                                _startTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      ListTile(
                        title: Text('End Time: ${_endTime.toString().split('.')[0]}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_endTime),
                            );
                            if (time != null) {
                              setState(() {
                                _endTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Media Pickers
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _selectImages,
                          icon: const Icon(Icons.image),
                          label: const Text('Add Images'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _selectVideo,
                          icon: const Icon(Icons.videocam),
                          label: const Text('Add Video'),
                        ),
                      ],
                    ),
                    
                    if (_images.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(_images[index]),
                            );
                          },
                        ),
                      ),
                      
                    if (_video != null)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Video Selected'),
                      ),

                    const SizedBox(height: 24),
                    CustomButton(text: 'Create Event', onPressed: _createEvent),
                  ],
                ),
              ),
            ),
    );
  }
}
