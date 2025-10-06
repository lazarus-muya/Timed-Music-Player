import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/features/timers/providers/timer_provider.dart';
import 'dart:async';

class TimerListener extends ConsumerStatefulWidget {
  final Widget child;

  const TimerListener({super.key, required this.child});

  @override
  ConsumerState<TimerListener> createState() => _TimerListenerState();
}

class _TimerListenerState extends ConsumerState<TimerListener> {
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to player timer events
    ref.listen(playerTimerTriggeredProvider, (previous, next) {
      next.when(
        data: (timer) {
          // Start tracking pause state (PlayerTimer should show "Music paused", not "Music changed")
          ref
              .read(timerPauseStateProvider.notifier)
              .startPause(null, timer.duration);

          // Start countdown timer
          _startCountdownTimer(timer.duration);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Player Timer "${timer.name}" triggered - Pausing playback',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        loading: () {},
        error: (error, stack) {},
      );
    });

    // Listen to track timer events
    ref.listen(trackTimerTriggeredProvider, (previous, next) {
      next.when(
        data: (timer) {
          // Start tracking pause state
          ref
              .read(timerPauseStateProvider.notifier)
              .startPause(
                timer.name,
                Duration(minutes: _calculateDurationInMinutes(timer.startTime, timer.endTime)),
              );

          // Start countdown timer
          _startCountdownTimer(Duration(minutes: _calculateDurationInMinutes(timer.startTime, timer.endTime)));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Track Timer "${timer.name}" triggered - Switching playlist',
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        loading: () {},
        error: (error, stack) {},
      );
    });

    return widget.child;
  }

  void _startCountdownTimer(Duration duration) {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = duration - Duration(seconds: timer.tick);

      if (remaining.isNegative || remaining == Duration.zero) {
        // Timer finished, end pause state
        ref.read(timerPauseStateProvider.notifier).endPause();
        timer.cancel();
      } else {
        // Update remaining duration
        ref
            .read(timerPauseStateProvider.notifier)
            .updateRemainingDuration(remaining);
      }
    });
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
