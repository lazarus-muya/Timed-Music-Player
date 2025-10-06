import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/data/models/playlist.dart';

import '../../../commons/widgets/spacer.dart';
import '../../playlist/providers/playlist_provider.dart';
import '../providers/timer_provider.dart';

class TrackTimersTab extends ConsumerWidget {
  const TrackTimersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackTimers = ref.watch(trackTimerProvider);
    final playlistsAsync = ref.watch(playlistProvider);

    if (trackTimers.isEmpty) {
      return const Center(
        child: Text(
          'No track timers created yet',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return playlistsAsync.when(
      data: (playlists) => GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          childAspectRatio: 250 / 170,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: trackTimers.length,
        itemBuilder: (context, index) {
          final timer = trackTimers[index];
          final playlist = playlists.firstWhere(
            (p) => p.id == timer.playlistId,
            orElse: () => const Playlist(id: '', name: 'Unknown'),
          );

          return Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          timer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Playlist: ',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        playlist.name,
                        style: TextStyle(color: Colors.grey[300], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  spacer(h: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Start: ',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        timer.startTime.format(context),
                        style:  TextStyle(color: Colors.grey[300], fontSize: 12),
                      ),
                    ],
                  ),
                  spacer(h: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'End: ',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        timer.endTime.format(context),
                        style:  TextStyle(color: Colors.grey[300], fontSize: 12),
                      ),
                    ],
                  ),
                  spacer(h: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration: ${_calculateDurationInMinutes(timer.startTime, timer.endTime)}m',
                        style:  TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          ref
                              .read(trackTimerProvider.notifier)
                              .deleteTrackTimer(timer.id);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.deepOrange),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading playlists: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  // Helper method to calculate duration in minutes between two TimeOfDay objects
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
