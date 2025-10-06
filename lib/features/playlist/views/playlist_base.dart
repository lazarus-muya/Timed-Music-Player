import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:timed_app/features/playlist/providers/playlist_provider.dart';
import 'package:timed_app/features/player/providers/player_provider.dart';
import 'package:timed_app/core/services/file_services.dart';
import 'package:uuid/uuid.dart';
import 'package:timed_app/commons/widgets/spacer.dart';
import 'package:timed_app/data/models/playlist.dart';
import 'package:timed_app/data/models/track.dart';

import '../../../commons/providers/shared_providers.dart';
import '../../../core/constants/colors_constants.dart';
import '../../../core/constants/config_constatnts.dart';
import '../widgets/playlist_listitem.dart';

class PlaylistBase extends ConsumerStatefulWidget {
  const PlaylistBase({super.key});

  @override
  ConsumerState<PlaylistBase> createState() => _PlaylistBaseState();
}

class _PlaylistBaseState extends ConsumerState<PlaylistBase> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uuid = Uuid();
  final playlistService = PlaylistFileService();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [_buildPlaylistsList(context), _buildTracksList(context)],
    );
  }

  Expanded _buildTracksList(BuildContext context) {
    return Expanded(
      child: ref
          .watch(playlistProvider)
          .when(
            data: (playlists) => playlists.isEmpty
                ? Center(
                    child: SizedBox(
                      width: 150.0,
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: () async {
                          _createPlaylist(context);
                        },
                        child: Text(
                          'Create Playlist',
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                    ),
                  )
                : _getCurrentPlaylist(ref)?.tracks == null ||
                      _getCurrentPlaylist(ref)?.tracks?.isEmpty == true
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'This playlist is empty',
                        style: TextStyle(color: Colors.white60, fontSize: 14.0),
                      ),
                      spacer(h: 20.0),
                      SizedBox(
                        width: 150.0,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            final files = await playlistService.getLocalMusic();
                            if (files.isEmpty) return;
                            final tracks = files
                                .where(
                                  (path) => path != null,
                                ) // Filter out null paths
                                .map((path) {
                                  final track = Track(
                                    id: _uuid.v4(),
                                    path: path!,
                                    title: basename(path),
                                  );
                                  return track;
                                })
                                .toList();

                            // Get current playlist
                            final currentPlaylist = _getCurrentPlaylist(ref);
                            if (currentPlaylist != null) {
                              final updatedTracks = <Track>[
                                ...(currentPlaylist.tracks ?? []),
                                ...tracks,
                              ];
                              final updatedPlaylist = currentPlaylist.copyWith(
                                tracks: updatedTracks,
                              );

                              // Update playlist in provider (this will also save to persistence)
                              ref
                                  .read(playlistProvider.notifier)
                                  .updatePlaylist(updatedPlaylist);
                            }
                          },
                          child: Text(
                            'Add Tracks',
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                      ),
                    ],
                  )
                : Material(
                    color: Colors.black,
                    child: ListView.builder(
                      itemCount: _getCurrentPlaylist(ref)?.tracks?.length ?? 0,
                      itemBuilder: (context, index) {
                        final playlist = _getCurrentPlaylist(ref);
                        if (playlist == null ||
                            playlist.tracks == null ||
                            index >= playlist.tracks!.length) {
                          return SizedBox.shrink();
                        }
                        final track = playlist.tracks![index];
                        final currentTrackAsync = ref.watch(
                          currentTrackProvider,
                        );
                        final isCurrentTrack = currentTrackAsync.when(
                          data: (currentTrack) => currentTrack?.id == track.id,
                          loading: () => false,
                          error: (_, __) => false,
                        );

                        return MusicListItem(
                          track: track,
                          isCurrent: isCurrentTrack,
                          onPlay: () async {
                            final currentPlaylist = _getCurrentPlaylist(ref);
                            if (currentPlaylist != null) {
                              await ref
                                  .read(playerNotifierProvider.notifier)
                                  .playPlaylist(
                                    currentPlaylist,
                                    startIndex: index,
                                  );
                            }
                          },
                          onDelete: () async {
                            final currentPlaylist = _getCurrentPlaylist(ref);
                            if (currentPlaylist != null &&
                                currentPlaylist.tracks != null &&
                                index < currentPlaylist.tracks!.length) {
                              final updatedTracks = <Track>[
                                ...(currentPlaylist.tracks ?? []),
                              ];
                              updatedTracks.removeAt(index);
                              final updatedPlaylist = currentPlaylist.copyWith(
                                tracks: updatedTracks,
                              );

                              // Update playlist in provider (this will also save to persistence)
                              ref
                                  .read(playlistProvider.notifier)
                                  .updatePlaylist(updatedPlaylist);
                            }
                          },
                        );
                      },
                    ),
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading playlists: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
    );
  }

  Container _buildPlaylistsList(BuildContext context) {
    return Container(
      height: double.infinity,
      width: PLAYLIST_WIDTH,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: BORDER_COLOR, width: 1)),
        color: Colors.black,
      ),
      child: Column(
        children: [
          Container(
            height: 60.0,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: BORDER_COLOR, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Playlists',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                IconButton(
                  onPressed: () async {
                    _createPlaylist(context);
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final playlistsAsync = ref.watch(playlistProvider);

                return playlistsAsync.when(
                  data: (playlists) => ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) => PlaylistListItem(
                      isSelected:
                          ref.watch(currentPlaylistProviderIndex) == index,
                      playlist: playlists[index],
                      onTap: () {
                        ref.watch(currentPlaylistProviderIndex.notifier).state =
                            index;
                      },
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading playlists: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Playlist? _getCurrentPlaylist(WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistProvider);
    final currentIndex = ref.watch(currentPlaylistProviderIndex);

    return playlistsAsync.when(
      data: (playlists) {
        if (playlists.isEmpty ||
            currentIndex < 0 ||
            currentIndex >= playlists.length) {
          return null;
        }
        return playlists[currentIndex];
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  void _createPlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          height: 300,
          width: 400,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Create New Playlist',
                  style: TextStyle(color: Colors.white70, fontSize: 20.0),
                ),
                spacer(h: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) =>
                        value!.isEmpty ? 'Name is required' : null,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Playlist Name',
                    ),
                  ),
                ),
                spacer(h: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 150.0,
                      height: 40.0,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150.0,
                      height: 40.0,
                      child: TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final playlist = Playlist(
                              id: _uuid.v4(),
                              name: _nameController.text,
                              tracks: [],
                            );

                            // Add playlist using provider (which handles both DB save and state update)
                            await ref
                                .read(playlistProvider.notifier)
                                .addPlaylist(playlist);

                            if (mounted) {
                              Navigator.pop(context);
                              setState(() {});
                            }
                          }
                        },
                        child: Text(
                          'Create',
                          // style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MusicListItem extends ConsumerWidget {
  const MusicListItem({
    super.key,
    required this.track,
    required this.isCurrent,
    required this.onPlay,
    required this.onDelete,
  });

  final Track track;
  final bool isCurrent;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.black,
      child: InkWell(
        onDoubleTap: onPlay,
        child: Ink(
          height: 45.0,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: const BoxDecoration(
            // border: Border(bottom: BorderSide(color: BORDER_COLOR, width: 1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.music_note,
                size: 20,
                color: isCurrent ? Colors.deepOrange : Colors.white60,
              ),
              spacer(w: 10.0),
              Expanded(
                child: Text(
                  track.title,
                  style: TextStyle(
                    color: isCurrent ? Colors.deepOrange : Colors.white60,
                    fontSize: 14.0,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outlined,
                  color: Colors.red,
                  size: 20.0,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
