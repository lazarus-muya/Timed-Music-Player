import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/commons/widgets/spacer.dart';
import 'package:timed_app/core/utils/extensions.dart';
import 'package:timed_app/data/models/track_timer.dart';
import 'package:timed_app/features/playlist/providers/playlist_provider.dart';
import 'package:timed_app/features/timers/providers/timer_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/colors_constants.dart';

const uid = Uuid();

class TrackTimerCreateDialog extends ConsumerStatefulWidget {
  const TrackTimerCreateDialog({
    super.key,
    required this.nameController,
    required this.selectedStartTime,
    required this.selectedEndTime,
    this.selectedPlaylistId,
  });

  final TextEditingController nameController;
  final TimeOfDay selectedStartTime;
  final TimeOfDay selectedEndTime;
  final String? selectedPlaylistId;

  @override
  ConsumerState<TrackTimerCreateDialog> createState() =>
      _TrackTimerCreateDialogState();
}

class _TrackTimerCreateDialogState
    extends ConsumerState<TrackTimerCreateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  String? _selectedPlaylistId;

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.selectedStartTime;
    _selectedEndTime = widget.selectedEndTime;
    _selectedPlaylistId = widget.selectedPlaylistId;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 430,
        width: 450,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Track Timer'),
              spacer(h: 15),
              TextFormField(
                controller: widget.nameController,
                style: TextStyle(color: context.theme.iconTheme.color),
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
                decoration: InputDecoration(
                  labelText: 'Timer Name',
                  labelStyle: TextStyle(color: context.theme.iconTheme.color),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                    borderSide: BorderSide(
                      color: context.theme.iconTheme.color!.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                    borderSide: BorderSide(color: BORDER_COLOR),
                  ),
                ),
              ),
              spacer(h: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                spacing: 0.0,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedStartTime,
                      );
                      if (time != null) {
                        setState(() {
                          _selectedStartTime = time;
                          if (_isEndTimeBeforeStartTime(
                            time,
                            _selectedEndTime,
                          )) {
                            _selectedEndTime = TimeOfDay(
                              hour: (time.hour + 1) % 24,
                              minute: time.minute,
                            );
                          }
                        });
                      }
                    },
                    child: Text('Start Time'),
                  ),
                  Chip(
                    backgroundColor: context.theme.scaffoldBackgroundColor,
                    side: const BorderSide(color: Colors.transparent),
                    label: Text(
                      '${_selectedStartTime.hour}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: context.theme.iconTheme.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              spacer(h: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                spacing: 0.0,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedEndTime,
                      );
                      if (time != null) {
                        if (!_isEndTimeBeforeStartTime(
                          _selectedStartTime,
                          time,
                        )) {
                          setState(() {
                            _selectedEndTime = time;
                          });
                        } else {
                          // ignore: use_build_context_synchronously
                          context.showToast(
                            message: 'End time must be after start time',
                            isError: true,
                          );
                        }
                      }
                    },
                    child: Text('End Time'),
                  ),
                  Chip(
                    backgroundColor: context.theme.scaffoldBackgroundColor,
                    side: const BorderSide(color: Colors.transparent),
                    label: Text(
                      '${_selectedEndTime.hour}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: context.theme.iconTheme.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              spacer(h: 20.0),
              // Duration Display (calculated from start and end times)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // color: context.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: context.theme.iconTheme.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${_calculateDurationInMinutes(_selectedStartTime, _selectedEndTime)} minutes',
                      style: TextStyle(
                        color: context.theme.iconTheme.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              spacer(h: 10.0),
              Consumer(
                builder: (context, ref, child) {
                  final playlistsAsync = ref.watch(playlistProvider);
                  return playlistsAsync.when(
                    data: (playlists) => SizedBox(
                      height: 40.0,
                      child: DropdownButton<String>(
                        value: _selectedPlaylistId,
                        underline: Container(),
                        hint: Text(
                          'Select Playlist',
                          style: TextStyle(
                            color: context.theme.iconTheme.color,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        dropdownColor: context.theme.scaffoldBackgroundColor,
                        items: playlists.map((playlist) {
                          return DropdownMenuItem(
                            value: playlist.id,
                            child: Text(
                              playlist.name,
                              style: TextStyle(
                                color: context.theme.iconTheme.color,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPlaylistId = value);
                        },
                      ),
                    ),
                    loading: () => Text(
                      'Loading playlists...',
                      style: TextStyle(color: context.theme.iconTheme.color),
                    ),
                    error: (error, stack) => const Text(
                      'Error loading playlists',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150.0,
                    height: 40.0,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150.0,
                    height: 40.0,
                    child: TextButton(
                      onPressed: () {
                        // if (_formKey.currentState!.validate() &&
                        //     _isEndTimeBeforeStartTime(
                        //       _selectedStartTime,
                        //       _selectedEndTime,
                        //     )) {
                        //   final timer = TrackTimer(
                        //     id: uid.v4(),
                        //     name: widget.nameController.text,
                        //     startTime: _selectedStartTime,
                        //     endTime: _selectedEndTime,
                        //     playlistId: _selectedPlaylistId!,
                        //   );
                        //   ref
                        //       .read(trackTimerProvider.notifier)
                        //       .addTrackTimer(timer);
                        //   Navigator.pop(context);
                        // }
                        if (_formKey.currentState!.validate() &&
                            widget.nameController.text.isNotEmpty &&
                            _selectedPlaylistId != null &&
                            !_isEndTimeBeforeStartTime(
                              _selectedStartTime,
                              _selectedEndTime,
                            )) {
                          final timer = TrackTimer(
                            id: uid.v4(),
                            name: widget.nameController.text,
                            startTime: _selectedStartTime,
                            endTime: _selectedEndTime,
                            playlistId: _selectedPlaylistId!,
                          );
                          ref
                              .read(trackTimerProvider.notifier)
                              .addTrackTimer(timer);
                          Navigator.pop(context);
                        } else {
                          String errorMessage =
                              'Please fill in all required fields';
                          if (widget.nameController.text.isEmpty) {
                            errorMessage = 'Please enter a timer name';
                          } else if (_selectedPlaylistId == null) {
                            errorMessage = 'Please select a playlist';
                          } else if (_isEndTimeBeforeStartTime(
                            _selectedStartTime,
                            _selectedEndTime,
                          )) {
                            errorMessage = 'End time must be after start time';
                          }
                          context.showToast(
                            message: errorMessage,
                            isError: true,
                          );
                        }
                      },
                      child: Text(
                        'Create',
                        style: TextStyle(color: context.theme.iconTheme.color),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to check if end time is before start time
  bool _isEndTimeBeforeStartTime(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes <= startMinutes;
  }

  // Helper method to calculate duration in minutes
  int _calculateDurationInMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes > startMinutes) {
      return endMinutes - startMinutes;
    } else {
      // Handle case where end time is next day (e.g., 23:00 to 01:00)
      return (24 * 60) - startMinutes + endMinutes;
    }
  }
}
