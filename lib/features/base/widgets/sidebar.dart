import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/commons/providers/shared_providers.dart';
import 'package:timed_app/commons/widgets/spacer.dart';
import 'package:timed_app/core/constants/config_constatnts.dart';

import '../../../core/constants/colors_constants.dart';
import 'sidebar_header.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navItems = [
      'Dashboard',
      'Playlists',
      'Now Playing',
      'Timers',
      'Settings',
    ];
    final icons = [
      Icons.home,
      Icons.playlist_play,
      Icons.music_note,
      Icons.timer,
      Icons.settings,
    ];

    return Container(
      height: double.infinity,
      width: SIDEBAR_WIDTH,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: BORDER_COLOR, width: 1)),
        color: Colors.black,
      ),
      child: Column(
        children: [
          SidebarHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final navItem = navItems[index];
                return ListTile(
                  leading: Icon(icons[index], size: 20),
                  title: Text(navItem),
                  selectedTileColor: Colors.grey[900],
                  selectedColor: Colors.deepOrange,
                  selected: ref.watch(currentNavItemIndexProvider) == index,
                  onTap: () =>
                      ref.read(currentNavItemIndexProvider.notifier).state =
                          index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

