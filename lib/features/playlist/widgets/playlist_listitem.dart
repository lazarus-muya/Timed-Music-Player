import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:timed_app/core/constants/colors_constants.dart';
import 'package:timed_app/core/constants/constatnts.dart';
import 'package:timed_app/core/utils/extensions.dart';
import 'package:timed_app/features/playlist/providers/playlist_provider.dart';
import '../../../commons/widgets/spacer.dart';
import '../../../data/models/playlist.dart';
import '../../../data/models/track.dart';

class PlaylistListItem extends ConsumerWidget {
  const PlaylistListItem({
    super.key,
    required this.isSelected,
    this.height,
    this.playlist,
    this.onTap,
  });

  final bool isSelected;
  final double? height;
  final Playlist? playlist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = StateProvider(
      (ref) => TextEditingController(text: playlist!.name),
    );
    return Material(
      color: isSelected
          ? context.theme.scaffoldBackgroundColor
          : Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Ink(
          height: height ?? 45.0,
          width: double.infinity,
          padding: EdgeInsets.only(left: 10.0),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: context.theme.accentColor,
                      width: 4,
                    ),
                  )
                : Border(left: BorderSide(color: Colors.transparent, width: 4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                playlist!.name,
                style: TextStyle(
                  color: context.theme.iconTheme.color,
                  fontSize: 14.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              // spacer(w: 10.0),
              const Spacer(),
              PopupMenuButton(
                padding: EdgeInsets.zero,
                iconColor: context.theme.iconTheme.color,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'Rename',
                    height: 40.0,
                    child: Text('Rename'),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Container(
                            height: 200,
                            width: 400,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              // color: context.theme.scaffoldBackgroundColor,
                              // borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Rename Playlist',
                                  style: TextStyle(
                                    color: context.theme.iconTheme.color,
                                    fontSize: 20.0,
                                  ),
                                ),
                                spacer(h: 20.0),
                                TextFormField(
                                  // initialValue: playlist!.name,
                                  controller: ref.read(nameController),
                                  style: TextStyle(
                                    color: context.theme.iconTheme.color,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: BORDER_COLOR,
                                      ),
                                    ),
                                  ),
                                ),
                                spacer(h: 20.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 100.0,
                                      height: 40.0,
                                      child: TextButton(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    spacer(w: 20.0),
                                    SizedBox(
                                      width: 100.0,
                                      height: 40.0,
                                      child: TextButton(
                                        child: Text(
                                          'Save',
                                          style: TextStyle(
                                            // color: context.theme.accentColor,
                                          ),
                                        ),
                                        onPressed: () async {
                                          final playlistService = ref.read(
                                            playlistServiceProvider,
                                          );
                                          await playlistService.updatePlaylist(
                                            playlist!
                                                .copyWith(
                                                  name: ref
                                                      .read(nameController)
                                                      .text,
                                                )
                                                .toMap(),
                                          );
                                          ref
                                              .read(playlistProvider.notifier)
                                              .refreshPlaylists();
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      ref.read(playlistProvider.notifier).refreshPlaylists();
                    },
                  ),
                  PopupMenuItem(
                    value: 'add-tracks',
                    height: 40.0,
                    onTap: () async {
                      final playlistService = ref.read(playlistServiceProvider);
                      final files = await playlistService.getLocalMusic();
                      if (files.isEmpty) return;
                      final tracks = files
                          .map(
                            (path) => Track(
                              id: uid.v4(),
                              path: path!,
                              title: basename(path),
                            ),
                          )
                          .toList();

                      // Add tracks to the specific playlist that was clicked
                      await playlistService.addTracksToPlaylist(
                        playlist!.id,
                        tracks.map((e) => e.path).toList(),
                      );

                      // Refresh playlists to update the UI
                      ref.read(playlistProvider.notifier).refreshPlaylists();
                    },
                    child: Text('Add Tracks'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    height: 40.0,
                    onTap: () async {
                      final playlistService = ref.read(playlistServiceProvider);
                      await playlistService.deletePlaylist(playlist!.id);
                      ref
                          .read(playlistProvider.notifier)
                          .removePlaylist(playlist!);
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
