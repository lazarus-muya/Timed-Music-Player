import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/utils/extensions.dart';
import 'dart:math' as math;

import '../../../../commons/logic/player_state.dart';
import '../../../../features/player/providers/player_provider.dart';
import '../../../../features/player/providers/disc_animation_provider.dart';
import '../../../../features/timers/providers/timer_provider.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Initialize the disc animation controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discAnimationProvider.notifier).initialize(this);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final timerPauseState = ref.watch(timerPauseStateProvider);
    final animationController = ref.watch(discAnimationProvider);

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (animationController != null)
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: animationController.value * 2 * math.pi,
                  child: Image.asset(
                    'assets/images/disc.png',
                    width: 400,
                    height: 400,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          // color: context.theme.iconTheme.color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.music_note,
                          size: 100,
                          color: context.theme.iconTheme.color,
                        ),
                      );
                    },
                  ),
                );
              },
            )
          else
            // Fallback when animation controller is not yet initialized
            Image.asset(
              'assets/images/disc.png',
              width: 400,
              height: 400,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: context.theme.iconTheme.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.music_note,
                    size: 100,
                    color: context.theme.iconTheme.color,
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          playerState.when(
            data: (state) => Text(
              state == PlayerState.playing ? 'Playing' : 'Stopped',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            loading: () => const Text('No Track loaded...'),
            error: (_, __) => const Text('Error'),
          ),
          const SizedBox(height: 10),
          // Timer pause status
          if (timerPauseState.isPaused &&
              timerPauseState.remainingDuration != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.theme.accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.theme.accentColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pause_circle_filled,
                    color: context.theme.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timerPauseState.timerName != null
                        ? 'Music changed - playing ${timerPauseState.timerName} for ${_formatDuration(timerPauseState.remainingDuration ?? Duration.zero)}'
                        : 'Music paused for ${_formatDuration(timerPauseState.remainingDuration ?? Duration.zero)}',
                    style: TextStyle(
                      color: context.theme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
