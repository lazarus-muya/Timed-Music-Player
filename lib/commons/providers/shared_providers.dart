import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/config/light_theme.dart';
import 'package:timed_app/data/models/playlist.dart';
import 'package:timed_app/features/playlist/providers/playlist_provider.dart';

final currentNavItemIndexProvider = StateProvider<int>((ref) => 0);

final currentPlaylistProviderIndex = StateProvider<int>((ref) => 0);

final currentPlaylist = StateProvider<Playlist?>((ref) {
  final plistAsync = ref.watch(playlistProvider);
  final currentIndex = ref.watch(currentPlaylistProviderIndex);
  
  return plistAsync.when(
    data: (plist) {
      if (plist.isEmpty || currentIndex < 0 || currentIndex >= plist.length) {
        return null;
      }
      return plist[currentIndex];
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentMusicPosition = StateProvider<double>((ref) => 0.0);

final themeProvider = StateProvider<FluentThemeData>((ref) => lightTheme);