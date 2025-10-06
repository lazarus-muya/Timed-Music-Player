import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timed_app/data/models/player_timer.dart';
import 'package:timed_app/data/models/track_timer.dart';
import 'package:timed_app/data/models/playlist.dart';
import 'package:timed_app/core/services/audio_service.dart';
import 'package:timed_app/core/services/persistence_service.dart';
import 'package:timed_app/commons/logic/player_state.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final AudioService _audioService = AudioService();
  final PersistenceService _persistenceService = PersistenceService();
  final Map<String, Timer> _activeTimers = {};
  final StreamController<PlayerTimer> _playerTimerTriggeredController =
      StreamController<PlayerTimer>.broadcast();
  final StreamController<TrackTimer> _trackTimerTriggeredController =
      StreamController<TrackTimer>.broadcast();

  // Streams
  Stream<PlayerTimer> get playerTimerTriggeredStream =>
      _playerTimerTriggeredController.stream;
  Stream<TrackTimer> get trackTimerTriggeredStream =>
      _trackTimerTriggeredController.stream;

  // Store previous state for TrackTimer restoration
  String? _previousPlaylistId;
  int? _previousTrackIndex;
  Duration? _previousPosition;

  Future<void> schedulePlayerTimer(PlayerTimer timer) async {
    if (!timer.isActive) return;

    final now = DateTime.now();
    final scheduledTime = _getNextScheduledTime(timer.time);

    if (scheduledTime.isBefore(now)) {
      // Schedule for next day
      final nextDay = scheduledTime.add(const Duration(days: 1));
      _schedulePlayerTimerAt(timer, nextDay);
    } else {
      _schedulePlayerTimerAt(timer, scheduledTime);
    }
  }

  Future<void> scheduleTrackTimer(TrackTimer timer) async {
    final now = DateTime.now();
    
    // Calculate next occurrence of the start time
    final scheduledTime = _getNextScheduledTime(timer.startTime);
    
    if (scheduledTime.isBefore(now)) {
      // Timer is in the past, don't schedule
      return;
    }
    _scheduleTrackTimerAt(timer, scheduledTime);
  }

  void _schedulePlayerTimerAt(PlayerTimer timer, DateTime scheduledTime) {
    final delay = scheduledTime.difference(DateTime.now());

    _activeTimers[timer.id] = Timer(delay, () {
      _triggerPlayerTimer(timer);
    });
  }

  void _scheduleTrackTimerAt(TrackTimer timer, DateTime scheduledTime) {
    final delay = scheduledTime.difference(DateTime.now());

    _activeTimers[timer.id] = Timer(delay, () {
      _triggerTrackTimer(timer);
    });
  }

  void _triggerPlayerTimer(PlayerTimer timer) async {
    _playerTimerTriggeredController.add(timer);

    try {
      // Only pause if music is currently playing
      if (_audioService.isPlaying) {
        await _audioService.pause();
      } else {
        //
      }

      // Schedule resume after duration
      Timer(timer.duration, () async {
        try {
          await _audioService.resume();
        } catch (e) {
          //
        }
      });
    } catch (e) {
      //
    }
  }

  void _triggerTrackTimer(TrackTimer timer) async {
    final duration = _calculateDurationInMinutes(timer.startTime, timer.endTime);
    _trackTimerTriggeredController.add(timer);

    try {
      // Ensure audio service is initialized
      await _audioService.initialize();

      // Store current state
      _previousPlaylistId = _audioService.currentPlaylist?.id;
      _previousTrackIndex = _audioService.currentTrackIndex;
      _previousPosition = _audioService.position;

      // Pause current playback if music is playing
      if (_audioService.isPlaying) {
        await _audioService.pause();
      }

      // Load and play the specified playlist
      final playlist = await _loadPlaylistById(timer.playlistId);

      if (playlist != null &&
          playlist.tracks != null &&
          playlist.tracks!.isNotEmpty) {
        // Set repeat mode for the timer playlist
        _audioService.setCycleMode(PlayerCycle.repeat);

        // Play the playlist starting from the first track
        await _audioService.playPlaylist(playlist, startIndex: 0);
      }

      // Schedule resume after duration
      Timer(Duration(minutes: duration), () async {
        try {
          await _resumePreviousPlayback();
        } catch (e) {
          //
        }
      });
    } catch (e) {
      //
    }
  }

  Future<void> _resumePreviousPlayback() async {
    try {
      if (_previousPlaylistId != null &&
          _previousTrackIndex != null &&
          _previousPosition != null) {
        // Restore previous playlist and track
        final previousPlaylist = await _loadPlaylistById(_previousPlaylistId!);
        if (previousPlaylist != null &&
            previousPlaylist.tracks != null &&
            _previousTrackIndex! < previousPlaylist.tracks!.length) {
          // Restore the previous playlist
          await _audioService.playPlaylist(
            previousPlaylist,
            startIndex: _previousTrackIndex!,
          );

          // Seek to previous position
          await _audioService.seekTo(_previousPosition!);
        } else {
          // Fallback: just resume current playback
          await _audioService.resume();
        }
      } else {
        await _audioService.resume();
      }
    } catch (e) {
      // Fallback: just try to resume
      try {
        await _audioService.resume();
      } catch (fallbackError) {
        //
      }
    }
  }

  Future<Playlist?> _loadPlaylistById(String playlistId) async {
    try {
      final playlists = await _persistenceService.loadPlaylists();

      final foundPlaylist = playlists.firstWhere(
        (playlist) => playlist.id == playlistId,
        orElse: () => throw StateError('Playlist not found'),
      );

      return foundPlaylist;
    } catch (e) {
      return null;
    }
  }

  DateTime _getNextScheduledTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  void cancelTimer(String timerId) {
    _activeTimers[timerId]?.cancel();
    _activeTimers.remove(timerId);
  }

  void cancelAllTimers() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
  }

  bool isTimerActive(String timerId) {
    return _activeTimers.containsKey(timerId);
  }

  List<String> getActiveTimerIds() {
    return _activeTimers.keys.toList();
  }

  // Helper method to calculate duration in minutes between two TimeOfDay objects
  int _calculateDurationInMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    if (endMinutes > startMinutes) {
      return endMinutes - startMinutes;
    } else {
      // Handle case where end time is next day (e.g., 23:00 to 01:00)
      return (24 * 60) - startMinutes + endMinutes;
    }
  }

  void dispose() {
    cancelAllTimers();
    _playerTimerTriggeredController.close();
    _trackTimerTriggeredController.close();
  }
}
