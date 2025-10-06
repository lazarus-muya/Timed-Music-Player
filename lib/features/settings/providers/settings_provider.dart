import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/services/persistence_service.dart';
import 'package:timed_app/data/models/app_settings.dart';

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

  String get themeMode => state.themeMode ?? 'system';
  String get repeatMode => state.repeatMode ?? 'none';
  bool get shuffleMode => state.shuffle ?? false;
  bool get autoPlay => state.autoPlay ?? false;
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
