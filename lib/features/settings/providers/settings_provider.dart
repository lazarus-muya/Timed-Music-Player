import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/services/db_service.dart';
import 'package:timed_app/data/models/app_settings.dart';

import '../../../commons/providers/shared_providers.dart';
import '../../playlist/providers/playlist_provider.dart';
import '../../timers/providers/timer_provider.dart';
import '../../player/providers/player_provider.dart';

final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  return PersistenceService();
});

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return AppSettings();
  }

  Future<void> _loadSettings() async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final settings = await persistenceService.loadSettings();
    if (settings != null) {
      state = settings;
    }
  }

  Future<void> updateThemeMode(String themeMode) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final success = await persistenceService.saveThemeMode(themeMode);
    if (success) {
      state = state.copyWith(themeMode: themeMode);
    }
  }

  Future<void> updateRepeatMode(String repeatMode) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final success = await persistenceService.saveRepeatMode(repeatMode);
    if (success) {
      state = state.copyWith(repeatMode: repeatMode);
    }
  }

  Future<void> updateShuffleMode(bool shuffle) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final success = await persistenceService.saveShuffleMode(shuffle);
    if (success) {
      state = state.copyWith(shuffle: shuffle);
    }
  }

  Future<void> updateAutoPlay(bool autoPlay) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final success = await persistenceService.saveAutoPlay(autoPlay);
    if (success) {
      state = state.copyWith(autoPlay: autoPlay);
    }
  }

  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  Future<void> clearAllData() async {
    // Stop music playback
    final audioService = ref.read(audioServiceProvider);
    await audioService.stop();
    
    // Clear database
    final persistenceService = ref.read(persistenceServiceProvider);
    await persistenceService.clearAllData();
    
    // Cancel all active timers
    final timerService = ref.read(timerServiceProvider);
    timerService.cancelAllTimers();
    
    // Reset playlist providers
    ref.invalidate(playlistProvider);
    ref.read(currentPlaylistProviderIndex.notifier).state = 0;
    ref.read(currentPlaylist.notifier).state = null;
    
    // Reset timer providers
    ref.read(playerTimerProvider.notifier).state = [];
    ref.read(trackTimerProvider.notifier).state = [];
    ref.read(timerPauseStateProvider.notifier).state = TimerPauseState();
    
    // Reset shared providers
    ref.read(currentMusicPosition.notifier).state = 0.0;
    ref.read(currentNavItemIndexProvider.notifier).state = 0;
    
    // Reset settings to default
    state = AppSettings();
  }

  String get themeMode => state.themeMode ?? 'system';
  String get repeatMode => state.repeatMode ?? 'none';
  bool get shuffleMode => state.shuffle ?? false;
  bool get autoPlay => state.autoPlay ?? false;
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
