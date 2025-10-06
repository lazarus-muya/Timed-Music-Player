import 'package:hive/hive.dart';
import 'package:timed_app/core/constants/config_constatnts.dart';
import 'package:timed_app/data/models/app_settings.dart';
import 'package:timed_app/data/models/playlist.dart';
import 'package:timed_app/data/models/player_timer.dart';
import 'package:timed_app/data/models/track_timer.dart';

class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  factory PersistenceService() => _instance;
  PersistenceService._internal();

  Box<AppSettings>? _settingsBox;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _settingsBox = await Hive.openBox<AppSettings>(SETTINGS_DB_KEY);
      _isInitialized = true;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Settings persistence
  Future<bool> saveSettings(AppSettings settings) async {
    try {
      await _ensureInitialized();
      await _settingsBox!.put(SETTINGS_DB_KEY, settings);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<AppSettings?> loadSettings() async {
    try {
      await _ensureInitialized();
      final settings = _settingsBox!.get(SETTINGS_DB_KEY);
      return settings;
    } catch (e) {
      return null;
    }
  }

  // Playlist persistence
  Future<bool> savePlaylists(List<Playlist> playlists) async {
    try {
      final settings = await loadSettings() ?? AppSettings();
      final playlistsMap = playlists.map((p) {
        return p.toMap();
      }).toList();

      final updatedSettings = settings.copyWith(playlists: playlistsMap);
      return await saveSettings(updatedSettings);
    } catch (e) {
      return false;
    }
  }

  Future<List<Playlist>> loadPlaylists() async {
    try {
      final settings = await loadSettings();
      if (settings?.playlists == null) return [];

      return settings!.playlists!.map((p) {
        return Playlist.fromMap(Map<String, dynamic>.from(p));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addPlaylist(Playlist playlist) async {
    try {
      final playlists = await loadPlaylists();
      playlists.add(playlist);
      return await savePlaylists(playlists);
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePlaylist(Playlist playlist) async {
    try {
      final playlists = await loadPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlist.id);
      if (index != -1) {
        playlists[index] = playlist;
        return await savePlaylists(playlists);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final playlists = await loadPlaylists();
      playlists.removeWhere((p) => p.id == playlistId);
      return await savePlaylists(playlists);
    } catch (e) {
      return false;
    }
  }

  // PlayerTimer persistence
  Future<bool> savePlayerTimers(List<PlayerTimer> timers) async {
    try {
      await _ensureInitialized();
      final settings = await loadSettings() ?? AppSettings();
      final timersMap = timers.map((t) => t.toMap()).toList();

      final updatedSettings = settings.copyWith(playerTimers: timersMap);
      final success = await saveSettings(updatedSettings);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<List<PlayerTimer>> loadPlayerTimers() async {
    try {
      await _ensureInitialized();
      final settings = await loadSettings();
      if (settings?.playerTimers == null) {
        return [];
      }

      final timers = settings!.playerTimers!.map((t) {
        return PlayerTimer.fromMap(Map<String, dynamic>.from(t));
      }).toList();

      return timers;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addPlayerTimer(PlayerTimer timer) async {
    try {
      await _ensureInitialized();
      final timers = await loadPlayerTimers();
      timers.add(timer);
      final success = await savePlayerTimers(timers);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePlayerTimer(PlayerTimer timer) async {
    try {
      final timers = await loadPlayerTimers();
      final index = timers.indexWhere((t) => t.id == timer.id);
      if (index != -1) {
        timers[index] = timer;
        return await savePlayerTimers(timers);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePlayerTimer(String timerId) async {
    try {
      final timers = await loadPlayerTimers();
      timers.removeWhere((t) => t.id == timerId);
      return await savePlayerTimers(timers);
    } catch (e) {
      return false;
    }
  }

  // TrackTimer persistence
  Future<bool> saveTrackTimers(List<TrackTimer> timers) async {
    try {
      await _ensureInitialized();
      final settings = await loadSettings() ?? AppSettings();
      final timersMap = timers.map((t) => t.toMap()).toList();

      final updatedSettings = settings.copyWith(trackTimers: timersMap);
      final success = await saveSettings(updatedSettings);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<List<TrackTimer>> loadTrackTimers() async {
    try {
      await _ensureInitialized();
      final settings = await loadSettings();
      if (settings?.trackTimers == null) {
        return [];
      }

      final timers = settings!.trackTimers!
          .map((t) => TrackTimer.fromMap(Map<String, dynamic>.from(t)))
          .toList();
      return timers;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addTrackTimer(TrackTimer timer) async {
    try {
      await _ensureInitialized();
      final timers = await loadTrackTimers();
      timers.add(timer);
      final success = await saveTrackTimers(timers);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTrackTimer(TrackTimer timer) async {
    try {
      final timers = await loadTrackTimers();
      final index = timers.indexWhere((t) => t.id == timer.id);
      if (index != -1) {
        timers[index] = timer;
        return await saveTrackTimers(timers);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTrackTimer(String timerId) async {
    try {
      final timers = await loadTrackTimers();
      timers.removeWhere((t) => t.id == timerId);
      return await saveTrackTimers(timers);
    } catch (e) {
      return false;
    }
  }

  // App preferences persistence
  Future<bool> saveThemeMode(String themeMode) async {
    try {
      final settings = await loadSettings() ?? AppSettings();
      final updatedSettings = settings.copyWith(themeMode: themeMode);
      return await saveSettings(updatedSettings);
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveRepeatMode(String repeatMode) async {
    try {
      final settings = await loadSettings() ?? AppSettings();
      final updatedSettings = settings.copyWith(repeatMode: repeatMode);
      return await saveSettings(updatedSettings);
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveShuffleMode(bool shuffle) async {
    try {
      final settings = await loadSettings() ?? AppSettings();
      final updatedSettings = settings.copyWith(shuffle: shuffle);
      return await saveSettings(updatedSettings);
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveAutoPlay(bool autoPlay) async {
    try {
      final settings = await loadSettings() ?? AppSettings();
      final updatedSettings = settings.copyWith(autoPlay: autoPlay);
      return await saveSettings(updatedSettings);
    } catch (e) {
      return false;
    }
  }

  // Clear all data
  Future<bool> clearAllData() async {
    try {
      await _ensureInitialized();
      await _settingsBox!.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}
