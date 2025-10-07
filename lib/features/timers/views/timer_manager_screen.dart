import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/utils/extensions.dart';
import 'package:timed_app/features/timers/widgets/player_create_dialog.dart';
import 'package:timed_app/features/timers/widgets/track_timer_create_dialog.dart';

import '../widgets/player_time_tab.dart';
import '../widgets/track_timer_tab.dart';

class TimerManagerScreen extends ConsumerStatefulWidget {
  const TimerManagerScreen({super.key});

  @override
  ConsumerState<TimerManagerScreen> createState() => _TimerManagerScreenState();
}

class _TimerManagerScreenState extends ConsumerState<TimerManagerScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  int _currentTabIndex = 0;
  final List<Widget> _tabs = [PlayerTimersTab(), TrackTimersTab()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        title: Text(
          'Timer Manager',
        ),
        // bottom: TabBar(
        //   controller: _tabController,
        //   labelColor: context.theme.accentColor,
        //   unselectedLabelColor: context.theme.iconTheme.color,
        //   indicatorColor: context.theme.accentColor,
        //   tabs: const [
        //     Tab(text: 'Player Timers',),
        //     Tab(text: 'Track Timers'),
        //   ],
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 10.0,
                children: [
                  SizedBox(
                    height: 40.0,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _currentTabIndex = 0),
                      label: Text(
                        'Music Pause Timers',
                        style: TextStyle(
                          color: _currentTabIndex == 0
                              ? context.theme.scaffoldBackgroundColor
                              : context.theme.iconTheme.color,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                        backgroundColor: _currentTabIndex == 0
                            ? context.theme.accentColor
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _currentTabIndex = 1),
                      label: Text(
                        'Track Change Timers',
                        style: TextStyle(
                          color: _currentTabIndex == 1
                              ? context.theme.scaffoldBackgroundColor
                              : context.theme.iconTheme.color,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                        backgroundColor: _currentTabIndex == 1
                            ? context.theme.accentColor
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _tabs[_currentTabIndex]),
          ],
        ),
      ),
      // body: TabBarView(
      //   controller: _tabController,
      //   children: [PlayerTimersTab(), TrackTimersTab()],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentTabIndex == 0) {
            _showCreatePlayerTimerDialog();
          } else {
            _showCreateTrackTimerDialog();
          }
        },
        backgroundColor: context.theme.accentColor,
        child: Icon(Icons.add, color: context.theme.iconTheme.color),
      ),
    );
  }

  void _showCreatePlayerTimerDialog() {
    final nameController = TextEditingController();
    final durationController = TextEditingController(text: '10');
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => PlayerCreateDialog(
        nameController: nameController,
        durationController: durationController,
        selectedTime: selectedTime,
        formKey: _formKey,
      ),
    );
  }

  void _showCreateTrackTimerDialog() {
    final nameController = TextEditingController();
    TimeOfDay selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay selectedEndTime = const TimeOfDay(hour: 10, minute: 0);
    String? selectedPlaylistId;

    showDialog(
      context: context,
      builder: (context) => TrackTimerCreateDialog(
        nameController: nameController,
        selectedStartTime: selectedStartTime,
        selectedEndTime: selectedEndTime,
        selectedPlaylistId: selectedPlaylistId,
      ),
    );
  }
}
