import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timed_app/core/config/dark_theme.dart';
import 'package:timed_app/data/models/app_settings.dart';
import 'package:timed_app/features/base/views/base_view.dart';
import 'package:timed_app/core/services/persistence_service.dart';
import 'package:timed_app/core/services/timer_service.dart';
import 'package:timed_app/commons/widgets/timer_listener.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants/config_constatnts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: WINDOW_MIN_SIZE,
    minimumSize: WINDOW_MIN_SIZE,
    title: 'Timed Music Player',
    // center: true,
    backgroundColor: Colors.transparent,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final Directory appDocDir = await getApplicationSupportDirectory();
  final String hivePath = '${appDocDir.path}\\hive_data';
  await Hive.initFlutter(hivePath);
  Hive.registerAdapter(AppSettingsAdapter());

  // Initialize services
  final persistenceService = PersistenceService();
  await persistenceService.initialize();

  final timerService = TimerService();

  // Load and schedule existing timers
  final playerTimers = await persistenceService.loadPlayerTimers();
  final trackTimers = await persistenceService.loadTrackTimers();

  for (final timer in playerTimers) {
    if (timer.isActive) {
      await timerService.schedulePlayerTimer(timer);
    }
  }

  for (final timer in trackTimers) {
    await timerService.scheduleTrackTimer(timer);
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timed Music Player',
      theme: darkTheme,
      home: Scaffold(body: TimerListener(child: BaseView())),
    );
  }
}
