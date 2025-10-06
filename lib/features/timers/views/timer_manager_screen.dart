import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late TabController _tabController;

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Timer Manager',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: const [
            Tab(text: 'Player Timers'),
            Tab(text: 'Track Timers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [PlayerTimersTab(), TrackTimersTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showCreatePlayerTimerDialog();
          } else {
            _showCreateTrackTimerDialog();
          }
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
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
