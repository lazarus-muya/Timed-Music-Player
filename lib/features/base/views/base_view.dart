import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/commons/providers/shared_providers.dart';
import 'package:timed_app/features/base/views/pages/dashboard.dart';
import 'package:timed_app/features/playlist/views/playlist_base.dart';
import 'package:timed_app/features/player/views/now_playing_screen.dart';
import 'package:timed_app/features/timers/views/timer_manager_screen.dart';
import 'package:timed_app/features/settings/views/settings_screen.dart';

import '../widgets/footer_actions.dart';
import '../widgets/sidebar.dart';

class BaseView extends ConsumerStatefulWidget {
  const BaseView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BaseViewState();
}

class _BaseViewState extends ConsumerState<BaseView> {
  final List<Widget> pages = [
    const Dashboard(),
    const PlaylistBase(),
    const NowPlayingScreen(),
    const TimerManagerScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 0.0,
      children: [
        Expanded(
          child: Row(
            children: [
              Sidebar(),
              Expanded(child: pages[ref.watch(currentNavItemIndexProvider)]),
            ],
          ),
        ),
        ref.watch(currentNavItemIndexProvider) == 2
            ? SizedBox.shrink()
            : const FooterActions(),
      ],
    );
  }
}
