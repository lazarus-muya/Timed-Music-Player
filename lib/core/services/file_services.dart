import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:timed_app/core/constants/constatnts.dart';
import 'package:timed_app/data/models/app_settings.dart';
import 'package:timed_app/data/models/playlist.dart';
import 'package:timed_app/data/models/track.dart';
import 'package:timed_app/core/services/db_service.dart';

class PlaylistFileService {
  final _persistenceService = PersistenceService();

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      return await _persistenceService.saveSettings(settings);
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  Future<AppSettings?> getSettings() async {
    try {
      return await _persistenceService.loadSettings();
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<bool> createSettings(AppSettings settings) async {
    try {
      return await _persistenceService.saveSettings(settings);
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  Future<bool> createPlaylist(Playlist playlist) async {
    try {
      return await _persistenceService.addPlaylist(playlist);
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  Future<void> addTracksToPlaylist(
    String playlistId,
    List<String> tracks,
  ) async {
    try {
      // Load all playlists to find the one to update
      final playlists = await _persistenceService.loadPlaylists();
      final playlistIndex = playlists.indexWhere((p) => p.id == playlistId);

      if (playlistIndex != -1) {
        final playlist = playlists[playlistIndex];
        // Convert string paths to Track objects
        final trackObjects = tracks
            .map(
              (path) => Track(
                id: path.hashCode.toString(),
                title: basename(path),
                path: path,
              ),
            )
            .toList();

        // Add new tracks to existing tracks, avoiding duplicates
        final existingPaths = (playlist.tracks ?? []).map((t) => t.path).toSet();
        final newTracks = trackObjects.where((track) => !existingPaths.contains(track.path)).toList();
        
        final updatedTracks = <Track>[
          ...(playlist.tracks ?? []),
          ...newTracks,
        ];
        final updatedPlaylist = playlist.copyWith(tracks: updatedTracks);

        // Save the updated playlist
        await _persistenceService.updatePlaylist(updatedPlaylist);
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<List<String?>> getLocalMusic() async {
    final results = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (results != null) {
      return results.paths.map((e) => e).toList();
    }
    return [];
  }

  Future<void> savePlaylist(Map<String, dynamic> playlist) async {}

  Future<Map<String, dynamic>?> loadPlaylist() async {
    return null;
  }

  Future<void> deletePlaylist(String id) async {
    try {
      await _persistenceService.deletePlaylist(id);
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> updatePlaylist(Map<String, dynamic> playlist) async {
    try {
      final playlistObj = Playlist.fromMap(playlist);
      await _persistenceService.updatePlaylist(playlistObj);
    } catch (e) {
      logger.e(e);
    }
  }

  Future<List<Map<String, dynamic>>?> loadAllPlaylists() async {
    try {
      final playlists = await _persistenceService.loadPlaylists();
      return playlists.map((p) => p.toMap()).toList();
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}
