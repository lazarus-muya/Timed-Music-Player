
#### Project Structure

timed_app\
    commons:
        extensions/
        logic/
        providers/
        widgets/
    core/
        constants/
        errors/
        services/
        theme/
        utils/
    data/
        models/
    features/
        base/
        player/
        playlist/
        settings/
        timer/
    main.dart

# Project Prompt: Flutter Music Player with Riverpod

You are to implement a **music player app** in Flutter using **Riverpod** for state management.  
The folder structure and all data models (`Playlist`, `Track`, `PlayerTimer`, `TrackTimer`, `Settings`) are already created, so you should **skip models and folder organization**.  

## Requirements

### 1. Core Features
- Continuous music playback (play, pause, next, previous, shuffle, repeat).
- Playlist management:
  - Create, edit, delete playlists.
  - Add/remove tracks.
- Timer system:
  - **PlayerTimer** → pauses playback at a scheduled time for a given duration, then resumes automatically.
  - **TrackTimer** → overrides current playback with a special track/playlist at a scheduled time for a set duration, then resumes the previous playlist where it left off.
- Settings management:
  - Save and load preferences (theme, volume, shuffle, repeat mode).
  - Persisted using Hive or JSON.

### 2. State Management
Use **Riverpod**:
- `PlaylistProvider` – manages playlists.
- `PlayerProvider` – manages playback state (current track, status).
- `TimerProvider` – manages PlayerTimers and TrackTimers.
- `SettingsProvider` – manages app preferences.

### 3. Services
- **AudioService**
  - Wrap `just_audio` (or `audioplayers`) for track playback.
  - Supports queueing, seeking, play/pause, resume.
- **TimerService**
  - Schedule and trigger timers.
  - When timer fires, update `TimerProvider`, pause/resume/override playback.
- **PersistenceService**
  - Save/load playlists, timers, and settings from Hive/JSON.
  - Injected into providers.

### 4. UI Screens
- **Home Screen**
  - Show active playlist, current track, playback controls.
  - Show upcoming timers.
- **Now Playing Screen**
  - Detailed track info, album art, seek bar, controls.
- **Playlist Manager**
  - List playlists, create/edit/delete.
  - Add/remove tracks.
- **Timer Manager**
  - List and manage PlayerTimers + TrackTimers.
- **Settings Screen**
  - Adjust preferences (theme, volume, shuffle, repeat).
  - Persist changes.

### 5. Flow Requirements
- When a `PlayerTimer` triggers:
  - Pause playback.
  - Resume automatically after duration.
- When a `TrackTimer` triggers:
  - Pause current playback.
  - Play override playlist/track.
  - After duration, resume previous playlist from where it paused.

### 6. Additional Notes
- Use Riverpod `StateNotifier` or `AsyncNotifier` for managing state.
- Ensure persistence works seamlessly (changes reflect instantly).
- The player should survive app restarts by restoring last played playlist/track if available.
- Prioritize clean code, separation of concerns, and reactive UI updates.

---

## Deliverables
1. Implement (update if exists) all **providers** (PlaylistProvider, PlayerProvider, TimerProvider, SettingsProvider).
2. Implement (update if exists) all **services** (AudioService, TimerService, PersistenceService).
3. Implement (update if exists) the **UI screens** and wire them with providers.
4. Ensure timers and playback integrate correct


update playlist_base so that it should get current playlist and list all tracks in Expanded -> line 124.
update playlist_listitem so that when tracks are added tracklist in playlist_base should rebuild.

inside player/
implement music player logic and store its own provider in its provider folder and all common providers inside commons/providers/

also implement the following.


