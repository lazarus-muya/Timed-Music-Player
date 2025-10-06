import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String? themeMode;
  @HiveField(2)
  final String? repeatMode;
  @HiveField(3)
  final bool? shuffle;
  @HiveField(4)
  final bool? autoPlay;
  @HiveField(5)
  final List<Map<String, dynamic>>? playerTimers;
  @HiveField(6)
  final List<Map<String, dynamic>>? trackTimers;
  @HiveField(7)
  final List<Map<String, dynamic>>? playlists;
  @HiveField(8)
  final Map<String, dynamic>? options;

  AppSettings({
    this.id,
    this.themeMode,
    this.repeatMode,
    this.shuffle,
    this.autoPlay,
    this.playerTimers,
    this.trackTimers,
    this.playlists,
    this.options,
  });

  // copyWith
  AppSettings copyWith({
    String? id,
    String? themeMode,
    String? repeatMode,
    bool? shuffle,
    bool? autoPlay,
    List<Map<String, dynamic>>? playerTimers,
    List<Map<String, dynamic>>? trackTimers,
    List<Map<String, dynamic>>? playlists,
    Map<String, dynamic>? options,
  }) {
    return AppSettings(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffle: shuffle ?? this.shuffle,
      autoPlay: autoPlay ?? this.autoPlay,
      playerTimers: playerTimers ?? this.playerTimers,
      trackTimers: trackTimers ?? this.trackTimers,
      playlists: playlists ?? this.playlists,
      options: options ?? this.options,
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'themeMode': themeMode,
      'repeatMode': repeatMode,
      'shuffle': shuffle,
      'autoPlay': autoPlay,
      'playerTimers': playerTimers,
      'trackTimers': trackTimers,
      'playlists': playlists,
      'options': options,
    };
  }

  // fromMap
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'],
      themeMode: map['themeMode'],
      repeatMode: map['repeatMode'],
      shuffle: map['shuffle'],
      autoPlay: map['autoPlay'],
      playerTimers: map['playerTimers'] == null
          ? null
          : (map['playerTimers'] as List).cast<Map<String, dynamic>>(),
      trackTimers: map['trackTimers'] == null
          ? null
          : (map['trackTimers'] as List).cast<Map<String, dynamic>>(),
      playlists: map['playlists'] == null || map['playlists'].isEmpty
          ? []
          : (map['playlists'] as List).cast<Map<String, dynamic>>(),
      options: map['options'],
    );
  }
}
