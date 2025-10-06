import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/commons/widgets/spacer.dart';
import 'package:timed_app/features/player/providers/player_provider.dart';
import 'package:timed_app/commons/logic/player_state.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  @override
  Widget build(BuildContext context) {
    final currentTrack = ref.watch(currentTrackProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final duration = ref.watch(durationProvider);
    final position = ref.watch(positionProvider);
    final cycleMode = ref.watch(playerCycleProvider);
    final isShuffled = ref.watch(isShuffledProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Album Art Placeholder
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  // alignment: Alignment.center,
                  constraints: const BoxConstraints(
                    maxWidth: 300,
                    maxHeight: 300,
                    minWidth: 200,
                    minHeight: 200,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/disc.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // Track Info
                currentTrack.when(
                  data: (track) => track != null
                      ? Column(
                          children: [
                            Text(
                              track.title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                // fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            if (track.artist != null)
                              Text(
                                track.artist!,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        )
                      : const SizedBox(),
                  loading: () => const Text('No track loaded...'),
                  error: (_, __) => const SizedBox(),
                ),
                // Progress Bar
                duration.when(
                  data: (duration) => position.when(
                    data: (progress) => Column(
                      children: [
                        Slider(
                          value: progress,
                          onChanged: (value) {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .seekToProgress(value);
                          },
                          activeColor: Colors.deepOrange,
                          inactiveColor: Colors.grey[600],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(
                                Duration(
                                  milliseconds:
                                      (duration!.inMilliseconds * progress)
                                          .round(),
                                ),
                              ),
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    loading: () => const Text('No track loaded...'),
                    error: (_, __) => const SizedBox(),
                  ),
                  loading: () => const Text('No track loaded...'),
                  error: (_, __) => const SizedBox(),
                ),
                spacer(h: 20),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle Button
                    IconButton(
                      onPressed: () {
                        ref
                            .read(playerNotifierProvider.notifier)
                            .toggleShuffle();
                      },
                      icon: Icon(
                        Icons.shuffle,
                        color: isShuffled.when(
                          data: (shuffled) =>
                              shuffled ? Colors.deepOrange : Colors.grey[400],
                          loading: () => Colors.grey[400],
                          error: (_, __) => Colors.grey[400],
                        ),
                        size: 30,
                      ),
                    ),

                    // Previous Button
                    IconButton(
                      onPressed: () {
                        ref.read(playerNotifierProvider.notifier).previous();
                      },
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    // Play/Pause Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          final track = currentTrack.when(
                            data: (track) => track,
                            loading: () => null,
                            error: (_, __) => null,
                          );

                          // Don't allow play/pause if no track is loaded
                          if (track == null) return;

                          final playing = isPlaying.when(
                            data: (playing) => playing,
                            loading: () => false,
                            error: (_, __) => false,
                          );
                          if (playing) {
                            ref.read(playerNotifierProvider.notifier).pause();
                          } else {
                            ref.read(playerNotifierProvider.notifier).resume();
                          }
                        },
                        icon: Icon(
                          isPlaying.when(
                            data: (playing) =>
                                playing ? Icons.pause : Icons.play_arrow,
                            loading: () => Icons.play_arrow,
                            error: (_, __) => Icons.play_arrow,
                          ),
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    // Next Button
                    IconButton(
                      onPressed: () {
                        ref.read(playerNotifierProvider.notifier).next();
                      },
                      icon: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    // Repeat Button
                    IconButton(
                      onPressed: () {
                        final mode = cycleMode.when(
                          data: (mode) => mode,
                          loading: () => PlayerCycle.none,
                          error: (_, __) => PlayerCycle.none,
                        );
                        final newMode = mode == PlayerCycle.none
                            ? PlayerCycle.repeat
                            : mode == PlayerCycle.repeat
                            ? PlayerCycle.repeatOne
                            : PlayerCycle.none;
                        ref
                            .read(playerNotifierProvider.notifier)
                            .setCycleMode(newMode);
                      },
                      icon: Icon(
                        cycleMode.when(
                          data: (mode) => mode == PlayerCycle.repeatOne
                              ? Icons.repeat_one
                              : Icons.repeat,
                          loading: () => Icons.repeat,
                          error: (_, __) => Icons.repeat,
                        ),
                        color: cycleMode.when(
                          data: (mode) => mode != PlayerCycle.none
                              ? Colors.deepOrange
                              : Colors.grey[400],
                          loading: () => Colors.grey[400],
                          error: (_, __) => Colors.grey[400],
                        ),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
