import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/services/audio_service.dart';
import 'package:timed_app/data/models/playlist.dart';
import 'package:timed_app/data/models/track.dart';
import 'package:timed_app/commons/logic/player_state.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  // Initialize asynchronously to avoid blocking
  service.initialize().catchError((error) {
    //
  });
  ref.onDispose(() {
    try {
      service.dispose();
    } catch (e) {
      //
    }
  });
  return service;
});

final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.playerStateStream;
});

final currentTrackProvider = StreamProvider<Track?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return Stream.periodic(Duration(milliseconds: 100), (_) => audioService.currentTrack);
});

final currentPlaylistProvider = StreamProvider<Playlist?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return Stream.periodic(Duration(milliseconds: 100), (_) => audioService.currentPlaylist);
});

final currentTrackIndexProvider = StreamProvider<int>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return Stream.periodic(Duration(milliseconds: 100), (_) => audioService.currentTrackIndex);
});

final playerCycleProvider = StreamProvider<PlayerCycle>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return Stream.periodic(Duration(milliseconds: 100), (_) => audioService.cycleMode);
});

final isShuffledProvider = StreamProvider<bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return Stream.periodic(Duration(milliseconds: 100), (_) => audioService.isShuffled);
});

final isPlayingProvider = StreamProvider<bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return Stream.periodic(Duration(milliseconds: 100), (_) => audioService.isPlaying);
});

final durationProvider = StreamProvider<Duration?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.durationStream;
});

final positionProvider = StreamProvider<double>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.positionStream;
});

final audioErrorProvider = StreamProvider<String>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.errorStream;
});

class PlayerNotifier extends Notifier<void> {
  @override
  void build() {
    // Initialize audio service
    ref.watch(audioServiceProvider);
  }

  Future<void> playPlaylist(Playlist playlist, {int startIndex = 0}) async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.playPlaylist(playlist, startIndex: startIndex);
    ref.invalidateSelf();
  }

  Future<String> playTrack(Track track) async {
    final audioService = ref.read(audioServiceProvider);
    final result = await audioService.playTrack(track);
    ref.invalidateSelf();
    return result;
  }

  Future<void> pause() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.pause();
    ref.invalidateSelf();
  }

  Future<void> resume() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.resume();
    ref.invalidateSelf();
  }

  Future<void> stop() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.stop();
    ref.invalidateSelf();
  }

  Future<void> next() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.next();
    ref.invalidateSelf();
  }

  Future<void> previous() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.previous();
    ref.invalidateSelf();
  }

  Future<void> seekTo(Duration position) async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.seekTo(position);
    ref.invalidateSelf();
  }

  Future<void> seekToProgress(double progress) async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.seekToProgress(progress);
    ref.invalidateSelf();
  }

  void setCycleMode(PlayerCycle mode) {
    final audioService = ref.read(audioServiceProvider);
    audioService.setCycleMode(mode);
    ref.invalidateSelf();
  }

  void toggleShuffle() {
    final audioService = ref.read(audioServiceProvider);
    audioService.toggleShuffle();
    ref.invalidateSelf();
  }
}

final playerNotifierProvider = NotifierProvider<PlayerNotifier, void>(PlayerNotifier.new);
