import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/data/models/playlist.dart';
import 'package:timed_app/core/services/file_services.dart';
import 'package:timed_app/commons/providers/shared_providers.dart';

final playlistServiceProvider = Provider<PlaylistFileService>((ref) {
  return PlaylistFileService();
});

final playlistProvider = AsyncNotifierProvider<PlaylistProvider, List<Playlist>>(
  PlaylistProvider.new,
);

class PlaylistProvider extends AsyncNotifier<List<Playlist>> {
  @override
  Future<List<Playlist>> build() async {
    return await _loadPlaylists();
  }

  Future<List<Playlist>> _loadPlaylists() async {
    final playlistService = ref.read(playlistServiceProvider);
    final playlistsMap = await playlistService.loadAllPlaylists();
    if (playlistsMap != null) {
      try {
        final playlists = playlistsMap.map((p) {
          return Playlist.fromMap(p);
        }).toList();

        // Reset current playlist index if it's out of bounds
        final currentIndex = ref.read(currentPlaylistProviderIndex);
        if (playlists.isEmpty || currentIndex >= playlists.length) {
          ref.read(currentPlaylistProviderIndex.notifier).state = 0;
        }
        
        return playlists;
      } catch (e) {
        ref.read(currentPlaylistProviderIndex.notifier).state = 0;
        return [];
      }
    } else {
      // Reset index when no playlists
      ref.read(currentPlaylistProviderIndex.notifier).state = 0;
      return [];
    }
  }

  Future<void> addPlaylist(Playlist playlist) async {
    final playlistService = ref.read(playlistServiceProvider);
    final success = await playlistService.createPlaylist(playlist);
    if (success) {
      final currentState = await future;
      state = AsyncValue.data([...currentState, playlist]);
    }
  }

  Future<void> addListOfPlaylists(List<Playlist> playlists) async {
    // Only add playlists that don't already exist
    final currentState = await future;
    final existingIds = currentState.map((p) => p.id).toSet();
    final newPlaylists = playlists
        .where((p) => !existingIds.contains(p.id))
        .toList();
    if (newPlaylists.isNotEmpty) {
      state = AsyncValue.data([...currentState, ...newPlaylists]);
    }
  }

  Future<void> removePlaylist(Playlist playlist) async {
    final playlistService = ref.read(playlistServiceProvider);
    await playlistService.deletePlaylist(playlist.id);
    final currentState = await future;
    final newState = currentState.where((p) => p.id != playlist.id).toList();
    state = AsyncValue.data(newState);

    // Reset current playlist index if it's out of bounds
    final currentIndex = ref.read(currentPlaylistProviderIndex);
    if (newState.isEmpty || currentIndex >= newState.length) {
      ref.read(currentPlaylistProviderIndex.notifier).state = 0;
    }
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final playlistService = ref.read(playlistServiceProvider);
    await playlistService.updatePlaylist(playlist.toMap());
    final currentState = await future;
    state = AsyncValue.data(currentState.map((p) => p.id == playlist.id ? playlist : p).toList());
  }

  Future<List<Playlist>> getPlaylists() async {
    return await future;
  }

  Future<void> refreshPlaylists() async {
    final playlists = await _loadPlaylists();
    state = AsyncValue.data(playlists);
  }
}
