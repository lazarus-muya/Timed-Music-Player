import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/core/utils/extensions.dart';
import 'package:timed_app/features/settings/providers/settings_provider.dart';

import '../../../commons/widgets/spacer.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final cardShape = BeveledRectangleBorder(
      side: BorderSide.none,
      borderRadius: BorderRadius.circular(3.0),
    );

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        surfaceTintColor: context.theme.scaffoldBackgroundColor,
        title: Text(
          'Settings',
          style: TextStyle(color: context.theme.accentColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        children: [
          // Theme Settings
          _buildSectionHeader('Appearance'),
          Card(
            color: context.theme.cardColor,
            shape: cardShape,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Theme Mode',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  subtitle: Text(
                    settings.themeMode ?? 'light',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: context.theme.iconTheme.color,
                  ),
                  onTap: () => _showThemeModeDialog(),
                ),
              ],
            ),
          ),
          spacer(h: 10.0),

          // Playback Settings
          _buildSectionHeader('Playback'),
          Card(
            color: context.theme.cardColor,
            shape: cardShape,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Repeat Mode',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  subtitle: Text(
                    settings.repeatMode ?? 'none',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: context.theme.iconTheme.color,
                  ),
                  onTap: () => _showRepeatModeDialog(),
                ),

                SwitchListTile(
                  title: Text(
                    'Shuffle',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  subtitle: Text(
                    'Randomize track order',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  value: settings.shuffle ?? false,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateShuffleMode(value);
                  },
                  activeThumbColor: context.theme.accentColor,
                ),

                SwitchListTile(
                  title: Text(
                    'Auto Play',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  subtitle: Text(
                    'Automatically start playback',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  value: settings.autoPlay ?? false,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateAutoPlay(value);
                  },
                  activeThumbColor: context.theme.accentColor,
                ),
              ],
            ),
          ),
          spacer(h: 10.0),

          // Data Management
          _buildSectionHeader('Data Management'),
          Card(
            color: context.theme.cardColor,
            shape: cardShape,
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Clear All Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: Text(
                    'Remove all playlists, timers, and settings',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  onTap: () => _showClearDataDialog(),
                ),
              ],
            ),
          ),
          spacer(h: 10.0),

          // About
          _buildSectionHeader('About'),
          Card(
            color: context.theme.cardColor,
            shape: cardShape,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Version',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  subtitle: Text(
                    '1.0.0',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                ),

                ListTile(
                  title: Text(
                    'Timed Music Player',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                  subtitle: Text(
                    'A music player with extended play, pause and music change timer functionality.',
                    style: TextStyle(color: context.theme.iconTheme.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.theme.iconTheme.color,
          fontSize: 15,
          // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showThemeModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.theme.cardColor,
        title: Text(
          'Select Theme Mode',
          style: TextStyle(color: context.theme.iconTheme.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ['light', 'dark'])
              ListTile(
                title: Text(
                  mode.capitalizeFirstLetter(),
                  style: TextStyle(color: context.theme.iconTheme.color),
                ),
                onTap: () {
                  ref.read(settingsProvider.notifier).updateThemeMode(mode);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRepeatModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.theme.cardColor,
        title: Text(
          'Select Repeat Mode',
          style: TextStyle(color: context.theme.iconTheme.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ['none', 'repeat', 'repeatOne'])
              ListTile(
                title: Text(
                  mode == 'repeatOne'
                      ? 'Repeat One'
                      : mode.capitalizeFirstLetter(),
                  style: TextStyle(color: context.theme.iconTheme.color),
                ),
                onTap: () {
                  ref.read(settingsProvider.notifier).updateRepeatMode(mode);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.theme.iconTheme.color,
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'This action cannot be undone. All playlists, timers, and settings will be permanently deleted.',
          style: TextStyle(color: context.theme.iconTheme.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.theme.iconTheme.color),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
