import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:timed_app/data/models/track.dart';
import 'package:timed_app/data/models/playlist.dart';
import 'package:timed_app/commons/logic/player_state.dart' as app_state;

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _audioPlayer;
  final StreamController<app_state.PlayerState> _playerStateController =
      StreamController<app_state.PlayerState>.broadcast();
  final StreamController<double> _positionController =
      StreamController<double>.broadcast();
  final StreamController<Duration?> _durationController =
      StreamController<Duration?>.broadcast();

  // Current playback state
  Track? _currentTrack;
  Playlist? _currentPlaylist;
  int _currentTrackIndex = 0;
  app_state.PlayerCycle _cycleMode = app_state.PlayerCycle.none;
  bool _isShuffled = false;
  List<int> _shuffledIndices = [];

  // Getters
  Track? get currentTrack => _currentTrack;
  Playlist? get currentPlaylist => _currentPlaylist;
  int get currentTrackIndex => _currentTrackIndex;
  app_state.PlayerCycle get cycleMode => _cycleMode;
  bool get isShuffled => _isShuffled;
  bool get isPlaying => _audioPlayer?.state == PlayerState.playing;
  Duration? get duration => null; // Will be updated via stream
  Duration get position => Duration.zero; // Will be updated via stream

  // Streams
  Stream<app_state.PlayerState> get playerStateStream =>
      _playerStateController.stream;
  Stream<double> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;

  Future<void> initialize() async {
    // Dispose existing player if any
    if (_audioPlayer != null) {
      try {
        await _audioPlayer!.dispose();
      } catch (e) {
        //
      }
    }

    // Create new audio player
    _audioPlayer = AudioPlayer();

    // Listen to player state changes
    _audioPlayer!.onPlayerStateChanged.listen((playerState) {
      switch (playerState) {
        case PlayerState.playing:
          _playerStateController.add(app_state.PlayerState.playing);
          break;
        case PlayerState.paused:
          _playerStateController.add(app_state.PlayerState.paused);
          break;
        case PlayerState.stopped:
          _playerStateController.add(app_state.PlayerState.stopped);
          break;
        case PlayerState.completed:
          _handleTrackCompleted();
          break;
        case PlayerState.disposed:
          _playerStateController.add(app_state.PlayerState.stopped);
          break;
      }
    });

    // Listen to position changes
    _audioPlayer!.onPositionChanged.listen((position) {
      _audioPlayer!.getDuration().then((duration) {
        if (duration != null) {
          final progress = position.inMilliseconds / duration.inMilliseconds;
          _positionController.add(progress);
        }
      });
    });

    // Listen to duration changes
    _audioPlayer!.onDurationChanged.listen((duration) {
      _durationController.add(duration);
    });
  }

  Future<void> playPlaylist(Playlist playlist, {int startIndex = 0}) async {
    if (playlist.tracks == null || playlist.tracks!.isEmpty) {
      return;
    }

    _currentPlaylist = playlist;
    _currentTrackIndex = startIndex;
    _isShuffled = false;
    _shuffledIndices.clear();

    await _playCurrentTrack();
  }

  Future<void> playTrack(Track track) async {
    if (_audioPlayer == null) {
      return;
    }

    _currentTrack = track;
    try {
      await _audioPlayer!.play(DeviceFileSource(track.path));
    } catch (e) {
      _playerStateController.add(app_state.PlayerState.stopped);
    }
  }

  Future<void> pause() async {
    if (_audioPlayer != null) {
      try {
        await _audioPlayer!.pause();
      } catch (e) {
        rethrow;
      }
    } else {
      //
    }
  }

  Future<void> resume() async {
    if (_audioPlayer != null) {
      try {
        await _audioPlayer!.resume();
      } catch (e) {
        rethrow;
      }
    } else {
      //
    }
  }

  Future<void> stop() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
    }
    _currentTrack = null;
    _currentPlaylist = null;
    _currentTrackIndex = 0;
    _playerStateController.add(app_state.PlayerState.stopped);
  }

  Future<void> next() async {
    if (_currentPlaylist == null || _currentPlaylist!.tracks == null) return;

    if (_isShuffled) {
      final shuffledIndex = _shuffledIndices.indexOf(_currentTrackIndex);
      if (shuffledIndex < _shuffledIndices.length - 1) {
        _currentTrackIndex = _shuffledIndices[shuffledIndex + 1];
      } else if (_cycleMode == app_state.PlayerCycle.repeat) {
        _currentTrackIndex = _shuffledIndices[0];
      } else {
        return; // End of playlist
      }
    } else {
      if (_currentTrackIndex < _currentPlaylist!.tracks!.length - 1) {
        _currentTrackIndex++;
      } else if (_cycleMode == app_state.PlayerCycle.repeat) {
        _currentTrackIndex = 0;
      } else {
        return; // End of playlist
      }
    }

    await _playCurrentTrack();
  }

  Future<void> previous() async {
    if (_currentPlaylist == null || _currentPlaylist!.tracks == null) return;

    if (_isShuffled) {
      final shuffledIndex = _shuffledIndices.indexOf(_currentTrackIndex);
      if (shuffledIndex > 0) {
        _currentTrackIndex = _shuffledIndices[shuffledIndex - 1];
      } else if (_cycleMode == app_state.PlayerCycle.repeat) {
        _currentTrackIndex = _shuffledIndices.last;
      } else {
        return; // Beginning of playlist
      }
    } else {
      if (_currentTrackIndex > 0) {
        _currentTrackIndex--;
      } else if (_cycleMode == app_state.PlayerCycle.repeat) {
        _currentTrackIndex = _currentPlaylist!.tracks!.length - 1;
      } else {
        return; // Beginning of playlist
      }
    }

    await _playCurrentTrack();
  }

  Future<void> seekTo(Duration position) async {
    if (_audioPlayer != null) {
      await _audioPlayer!.seek(position);
    }
  }

  Future<void> seekToProgress(double progress) async {
    if (_audioPlayer != null) {
      final duration = await _audioPlayer!.getDuration();
      if (duration != null) {
        final position = Duration(
          milliseconds: (duration.inMilliseconds * progress).round(),
        );
        await seekTo(position);
      }
    }
  }

  void setCycleMode(app_state.PlayerCycle mode) {
    _cycleMode = mode;
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled && _currentPlaylist != null) {
      _generateShuffledIndices();
    }
  }

  void _generateShuffledIndices() {
    if (_currentPlaylist?.tracks == null) return;

    _shuffledIndices = List.generate(
      _currentPlaylist!.tracks!.length,
      (index) => index,
    );
    _shuffledIndices.shuffle();
  }

  Future<void> _playCurrentTrack() async {
    if (_currentPlaylist?.tracks == null ||
        _currentTrackIndex >= _currentPlaylist!.tracks!.length) {
      return;
    }

    _currentTrack = _currentPlaylist!.tracks![_currentTrackIndex];
    await playTrack(_currentTrack!);
  }

  void _handleTrackCompleted() {
    if (_cycleMode == app_state.PlayerCycle.repeatOne) {
      // Repeat current track
      _playCurrentTrack();
    } else {
      // Move to next track
      next();
    }
  }

  void dispose() {
    if (_audioPlayer != null) {
      _audioPlayer!.dispose();
      _audioPlayer = null;
    }
    _playerStateController.close();
    _positionController.close();
    _durationController.close();
  }
}
