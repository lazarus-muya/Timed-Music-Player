import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/timer_provider.dart';

class PlayerTimersTab extends ConsumerWidget {
  const PlayerTimersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerTimers = ref.watch(playerTimerProvider);

    if (playerTimers.isEmpty) {
      return const Center(
        child: Text(
          'No player timers created yet',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          childAspectRatio: 250 / 150,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
      itemCount: playerTimers.length,
      itemBuilder: (context, index) {
        final timer = playerTimers[index];
        return Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                    Switch(
                      value: timer.isActive,
                      onChanged: (value) {
                        ref.read(playerTimerProvider.notifier).togglePlayerTimer(timer.id);
                      },
                      activeThumbColor: Colors.deepOrange,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Time: ${timer.time.format(context)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${timer.duration.inMinutes}m',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          timer.isActive ? Icons.play_circle : Icons.pause_circle,
                          color: timer.isActive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timer.isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            color: timer.isActive ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                        ref.read(playerTimerProvider.notifier).deletePlayerTimer(timer.id);
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
    );
  }
}