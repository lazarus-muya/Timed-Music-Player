import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/commons/widgets/spacer.dart';
import 'package:timed_app/data/models/track_timer.dart';
import 'package:timed_app/features/playlist/providers/playlist_provider.dart';
import 'package:timed_app/features/timers/providers/timer_provider.dart';
import 'package:uuid/uuid.dart';

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
        height: 500,
        width: 400,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create Track Timer',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: widget.nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Timer Name',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            // Start Time Section
            // ListTile(
            //   title: const Text(
            //     'Start Time',
            //     style: TextStyle(color: Colors.white),
            //   ),
            // subtitle: Text(
            //   '${_selectedStartTime.hour}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
            //   style: const TextStyle(color: Colors.deepOrange),
            // ),
            //   onTap: () async {
            //     final time = await showTimePicker(
            //       context: context,
            //       initialTime: _selectedStartTime,
            //     );
            //     if (time != null) {
            //       setState(() {
            //         _selectedStartTime = time;
            //         // Ensure end time is after start time
            //         if (_isEndTimeBeforeStartTime(time, _selectedEndTime)) {
            //           _selectedEndTime = TimeOfDay(
            //             hour: (time.hour + 1) % 24,
            //             minute: time.minute,
            //           );
            //         }
            //       });
            //     }
            //   },
            // ),
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
                        // Ensure end time is after start time
                        if (_isEndTimeBeforeStartTime(time, _selectedEndTime)) {
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
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.transparent),
                  label: Text(
                    '${_selectedStartTime.hour}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.deepOrange),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('End time must be after start time'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text('End Time'),
                ),
                Chip(
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.transparent),
                  label: Text(
                    '${_selectedEndTime.hour}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ),
              ],
            ),
            spacer(h: 20.0),
            // Duration Display (calculated from start and end times)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.deepOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: ${_calculateDurationInMinutes(_selectedStartTime, _selectedEndTime)} minutes',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            spacer(h: 20.0),
            Consumer(
              builder: (context, ref, child) {
                final playlistsAsync = ref.watch(playlistProvider);
                return playlistsAsync.when(
                  data: (playlists) => SizedBox(
                    height: 50.0,
                    child: DropdownButton<String>(
                      value: _selectedPlaylistId,
                      underline: Container(),
                      hint: const Text(
                        'Select Playlist',
                        style: TextStyle(color: Colors.grey),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      dropdownColor: Colors.black,
                      items: playlists.map((playlist) {
                        return DropdownMenuItem(
                          value: playlist.id,
                          child: Text(
                            playlist.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPlaylistId = value);
                      },
                    ),
                  ),
                  loading: () => const Text(
                    'Loading playlists...',
                    style: TextStyle(color: Colors.grey),
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
                      if (widget.nameController.text.isNotEmpty &&
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
