import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/features/base/views/pages/dashboard.dart';
import 'package:timed_app/features/base/widgets/sidebar_header.dart';
import 'package:timed_app/features/playlist/views/playlist_base.dart';
import 'package:timed_app/features/player/views/now_playing_screen.dart';
import 'package:timed_app/features/timers/views/timer_manager_screen.dart';
import 'package:timed_app/features/settings/views/settings_screen.dart';

class BaseView extends ConsumerStatefulWidget {
  const BaseView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BaseViewState();
}

class _BaseViewState extends ConsumerState<BaseView> {
  int _selectedIndex = 0;

  final List<Widget> pages = [
    const Dashboard(),
    const PlaylistBase(),
    const NowPlayingScreen(),
    const TimerManagerScreen(),
    // const SettingsScreen(),
  ];

  List<IconData> icons = [
    WindowsIcons.view_dashboard,
    WindowsIcons.music_album,
    WindowsIcons.music_note,
    WindowsIcons.screen_time,
    // WindowsIcons.settings,
  ];

  List<String> titles = [
    'Dashboard',
    'Playlists',
    'Now Playing',
    'Timers',
    // 'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      contentShape: BeveledRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.zero,
      ),
      transitionBuilder: (child, animation) =>
          SuppressPageTransition(child: child),
      pane: NavigationPane(
        selected: _selectedIndex,
        onItemPressed: (value) {},
        size: NavigationPaneSize(openMaxWidth: 250, openMinWidth: 250),
        onChanged: (value) => setState(() => _selectedIndex = value),
        displayMode: PaneDisplayMode.open,
        toggleable: true,
        items: List.generate(
          icons.length,
          (index) => PaneItem(
            icon: WindowsIcon(icons[index]),
            body: pages[index],
            title: Text(titles[index]),
          ),
        ),
        footerItems: [
          PaneItem(
            title: Text("Settings"),
            icon: WindowsIcon(WindowsIcons.settings),
            body: const SettingsScreen(),
          ),
        ],
        header: SidebarHeader(),
      ),
    );
  }
}
