import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/utils/extensions.dart';
import 'package:timed_app/features/player/providers/player_provider.dart';
import 'package:timed_app/commons/widgets/spacer.dart';

import '../../../commons/logic/player_state.dart';
import '../../../core/constants/colors_constants.dart';

class FooterActions extends ConsumerWidget {
  const FooterActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackAsync = ref.watch(currentTrackProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final cycleModeAsync = ref.watch(playerCycleProvider);
    final isShuffledAsync = ref.watch(isShuffledProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);

    return Material(
      child: Container(
        height: 90.0,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: BORDER_COLOR, width: 1)),
          color: Colors.black,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 40.0,
              child: Row(
                children: [
                  // Shuffle Button
                  IconButton(
                    onPressed: () {
                      ref.read(playerNotifierProvider.notifier).toggleShuffle();
                    },
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: isShuffledAsync.when(
                        data: (isShuffled) =>
                            isShuffled ? context.theme.accentColor : null,
                        loading: () => null,
                        error: (_, __) => null,
                      ),
                    ),
                  ),
                  // Previous Button
                  IconButton(
                    onPressed: () {
                      ref.read(playerNotifierProvider.notifier).previous();
                    },
                    icon: Icon(Icons.skip_previous_rounded),
                  ),
                  // Play/Pause Button
                  IconButton(
                    onPressed: () async {
                      final currentTrack = currentTrackAsync.when(
                        data: (track) => track,
                        loading: () => null,
                        error: (_, __) => null,
                      );

                      // Don't allow play/pause if no track is loaded
                      if (currentTrack == null) return;

                      final isPlaying = isPlayingAsync.when(
                        data: (playing) => playing,
                        loading: () => false,
                        error: (_, __) => false,
                      );
                      if (isPlaying) {
                        await ref.read(playerNotifierProvider.notifier).pause();
                      } else {
                        await ref
                            .read(playerNotifierProvider.notifier)
                            .resume();
                      }
                    },
                    icon: Icon(
                      isPlayingAsync.when(
                        data: (isPlaying) => isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        loading: () => Icons.play_arrow_rounded,
                        error: (_, __) => Icons.play_arrow_rounded,
                      ),
                    ),
                  ),
                  // Next Button
                  IconButton(
                    onPressed: () {
                      ref.read(playerNotifierProvider.notifier).next();
                    },
                    icon: Icon(Icons.skip_next_rounded),
                  ),
                  // Repeat Button
                  IconButton(
                    onPressed: () {
                      final cycleMode = cycleModeAsync.when(
                        data: (mode) => mode,
                        loading: () => PlayerCycle.none,
                        error: (_, __) => PlayerCycle.none,
                      );
                      final newMode = cycleMode == PlayerCycle.none
                          ? PlayerCycle.repeat
                          : cycleMode == PlayerCycle.repeat
                          ? PlayerCycle.repeatOne
                          : PlayerCycle.none;
                      ref
                          .read(playerNotifierProvider.notifier)
                          .setCycleMode(newMode);
                    },
                    icon: Icon(
                      cycleModeAsync.when(
                        data: (cycleMode) => cycleMode == PlayerCycle.repeat
                            ? Icons.repeat_rounded
                            : cycleMode == PlayerCycle.repeatOne
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        loading: () => Icons.repeat_rounded,
                        error: (_, __) => Icons.repeat_rounded,
                      ),
                      color: cycleModeAsync.when(
                        data: (cycleMode) => cycleMode != PlayerCycle.none
                            ? context.theme.accentColor
                            : null,
                        loading: () => null,
                        error: (_, __) => null,
                      ),
                    ),
                  ),
                  spacer(w: 20.0),
                  // Current Track Title
                  Expanded(
                    child: Text(
                      currentTrackAsync.when(
                        data: (currentTrack) =>
                            currentTrack?.title ?? 'No track selected',
                        loading: () => 'Loading...',
                        error: (_, __) => 'No track selected',
                      ),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.theme.iconTheme.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40.0,
              child: Row(
                children: [
                  // Current Position
                  SizedBox(
                    width: 50,
                    child: Text(
                      _formatDuration(
                        positionAsync.when(
                          data: (progress) => durationAsync.when(
                            data: (duration) => duration != null
                                ? Duration(
                                    milliseconds:
                                        (duration.inMilliseconds * progress)
                                            .round(),
                                  )
                                : Duration.zero,
                            loading: () => Duration.zero,
                            error: (_, __) => Duration.zero,
                          ),
                          loading: () => Duration.zero,
                          error: (_, __) => Duration.zero,
                        ),
                      ),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  spacer(w: 10.0),
                  // Progress Slider
                  Expanded(child: _buildSlider(ref, context)),
                  spacer(w: 10.0),
                  // Total Duration
                  SizedBox(
                    width: 50,
                    child: Text(
                      _formatDuration(
                        durationAsync.when(
                          data: (duration) => duration ?? Duration.zero,
                          loading: () => Duration.zero,
                          error: (_, __) => Duration.zero,
                        ),
                      ),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(WidgetRef ref, BuildContext context) {
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);

    return positionAsync.when(
      data: (progress) => durationAsync.when(
        data: (duration) => Slider(
          value: progress.clamp(0.0, 1.0),
          min: 0.0,
          max: 1.0,
          onChanged: (value) {
            ref.read(playerNotifierProvider.notifier).seekToProgress(value);
          },
          padding: EdgeInsets.all(2),
          activeColor: context.theme.accentColor,
        ),
        loading: () => Slider(
          value: 0.0,
          min: 0.0,
          max: 1.0,
          onChanged: null,
          padding: EdgeInsets.all(2),
          activeColor: context.theme.accentColor,
        ),
        error: (_, __) => Slider(
          value: 0.0,
          min: 0.0,
          max: 1.0,
          onChanged: null,
          padding: EdgeInsets.all(2),
          activeColor: context.theme.accentColor,
        ),
      ),
      loading: () => Slider(
        value: 0.0,
        min: 0.0,
        max: 1.0,
        onChanged: null,
        padding: EdgeInsets.all(2),
        activeColor: context.theme.accentColor,
      ),
      error: (_, __) => Slider(
        value: 0.0,
        min: 0.0,
        max: 1.0,
        onChanged: null,
        padding: EdgeInsets.all(2),
        activeColor: context.theme.accentColor,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
