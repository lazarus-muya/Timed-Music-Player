import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/services/timer_service.dart';
import 'package:timed_app/core/services/persistence_service.dart';
import 'package:timed_app/data/models/player_timer.dart';
import 'package:timed_app/data/models/track_timer.dart';

final timerServiceProvider = Provider<TimerService>((ref) {
  final service = TimerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  return PersistenceService();
});

class PlayerTimerNotifier extends Notifier<List<PlayerTimer>> {
  @override
  List<PlayerTimer> build() {
    _loadPlayerTimers();
    return [];
  }

  Future<void> _loadPlayerTimers() async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final timers = await persistenceService.loadPlayerTimers();
    state = timers;
  }

  Future<void> addPlayerTimer(PlayerTimer timer) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final timerService = ref.read(timerServiceProvider);
    
    final success = await persistenceService.addPlayerTimer(timer);
    
    if (success) {
      state = [...state, timer];
      if (timer.isActive) {
        await timerService.schedulePlayerTimer(timer);
      }
    }
  }

  Future<void> updatePlayerTimer(PlayerTimer timer) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final timerService = ref.read(timerServiceProvider);
    
    final success = await persistenceService.updatePlayerTimer(timer);
    if (success) {
      state = state.map((t) => t.id == timer.id ? timer : t).toList();
      
      // Cancel existing timer and schedule new one if active
      timerService.cancelTimer(timer.id);
      if (timer.isActive) {
        await timerService.schedulePlayerTimer(timer);
      }
    }
  }

  Future<void> deletePlayerTimer(String timerId) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final timerService = ref.read(timerServiceProvider);
    
    final success = await persistenceService.deletePlayerTimer(timerId);
    if (success) {
      state = state.where((t) => t.id != timerId).toList();
      timerService.cancelTimer(timerId);
    }
  }

  Future<void> togglePlayerTimer(String timerId) async {
    final timer = state.firstWhere((t) => t.id == timerId);
    final updatedTimer = timer.copyWith(isActive: !timer.isActive);
    await updatePlayerTimer(updatedTimer);
  }

  Future<void> refreshPlayerTimers() async {
    await _loadPlayerTimers();
  }
}

class TrackTimerNotifier extends Notifier<List<TrackTimer>> {
  @override
  List<TrackTimer> build() {
    _loadTrackTimers();
    return [];
  }

  Future<void> _loadTrackTimers() async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final timers = await persistenceService.loadTrackTimers();
    state = timers;
  }

  Future<void> addTrackTimer(TrackTimer timer) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final timerService = ref.read(timerServiceProvider);
    
    final success = await persistenceService.addTrackTimer(timer);
    
    if (success) {
      state = [...state, timer];
      await timerService.scheduleTrackTimer(timer);
    }
  }

  Future<void> updateTrackTimer(TrackTimer timer) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final timerService = ref.read(timerServiceProvider);
    
    final success = await persistenceService.updateTrackTimer(timer);
    if (success) {
      state = state.map((t) => t.id == timer.id ? timer : t).toList();
      
      // Cancel existing timer and schedule new one
      timerService.cancelTimer(timer.id);
      await timerService.scheduleTrackTimer(timer);
    }
  }

  Future<void> deleteTrackTimer(String timerId) async {
    final persistenceService = ref.read(persistenceServiceProvider);
    final timerService = ref.read(timerServiceProvider);
    
    final success = await persistenceService.deleteTrackTimer(timerId);
    if (success) {
      state = state.where((t) => t.id != timerId).toList();
      timerService.cancelTimer(timerId);
    }
  }

  Future<void> refreshTrackTimers() async {
    await _loadTrackTimers();
  }
}

final playerTimerProvider = NotifierProvider<PlayerTimerNotifier, List<PlayerTimer>>(PlayerTimerNotifier.new);
final trackTimerProvider = NotifierProvider<TrackTimerNotifier, List<TrackTimer>>(TrackTimerNotifier.new);

// Timer pause state provider
class TimerPauseState {
  final String? timerName;
  final Duration? remainingDuration;
  final DateTime? pauseStartTime;
  final bool isPaused;

  TimerPauseState({
    this.timerName,
    this.remainingDuration,
    this.pauseStartTime,
    this.isPaused = false,
  });

  TimerPauseState copyWith({
    String? timerName,
    Duration? remainingDuration,
    DateTime? pauseStartTime,
    bool? isPaused,
  }) {
    return TimerPauseState(
      timerName: timerName ?? this.timerName,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      pauseStartTime: pauseStartTime ?? this.pauseStartTime,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class TimerPauseStateNotifier extends Notifier<TimerPauseState> {
  @override
  TimerPauseState build() {
    return TimerPauseState();
  }

  void startPause(String? timerName, Duration duration) {
    state = TimerPauseState(
      timerName: timerName,
      remainingDuration: duration,
      pauseStartTime: DateTime.now(),
      isPaused: true,
    );
  }

  void endPause() {
    state = TimerPauseState();
  }

  void updateRemainingDuration(Duration duration) {
    if (state.isPaused) {
      state = state.copyWith(remainingDuration: duration);
    }
  }
}

final timerPauseStateProvider = NotifierProvider<TimerPauseStateNotifier, TimerPauseState>(TimerPauseStateNotifier.new);

// Stream providers for timer events
final playerTimerTriggeredProvider = StreamProvider<PlayerTimer>((ref) {
  final timerService = ref.watch(timerServiceProvider);
  return timerService.playerTimerTriggeredStream;
});

final trackTimerTriggeredProvider = StreamProvider<TrackTimer>((ref) {
  final timerService = ref.watch(timerServiceProvider);
  return timerService.trackTimerTriggeredStream;
});
