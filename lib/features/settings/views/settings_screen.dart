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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings
          _buildSectionHeader('Appearance'),
          Card(
            color: Colors.grey[900]?.withValues(alpha: 0.3),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Theme Mode',
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: Text(
                    settings.themeMode ?? 'system',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
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
            color: Colors.grey[900]?.withValues(alpha: 0.3),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Repeat Mode',
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: Text(
                    settings.repeatMode ?? 'none',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                  ),
                  onTap: () => _showRepeatModeDialog(),
                ),

                SwitchListTile(
                  title: const Text(
                    'Shuffle',
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: const Text(
                    'Randomize track order',
                    style: TextStyle(color: Colors.grey),
                  ),
                  value: settings.shuffle ?? false,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateShuffleMode(value);
                  },
                  activeThumbColor: Colors.deepOrange,
                ),

                SwitchListTile(
                  title: const Text(
                    'Auto Play',
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: const Text(
                    'Automatically start playback',
                    style: TextStyle(color: Colors.grey),
                  ),
                  value: settings.autoPlay ?? false,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateAutoPlay(value);
                  },
                  activeThumbColor: Colors.deepOrange,
                ),
              ],
            ),
          ),
          spacer(h: 10.0),

          // Data Management
          _buildSectionHeader('Data Management'),
          Card(
            color: Colors.grey[900]?.withValues(alpha: 0.3),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Clear All Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'Remove all playlists, timers, and settings',
                    style: TextStyle(color: Colors.grey),
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
            color: Colors.grey[900]?.withValues(alpha: 0.3),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Version',
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: const Text(
                    '1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                ListTile(
                  title: const Text(
                    'Timed Music Player',
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: const Text(
                    'A music player with timer functionality',
                    style: TextStyle(color: Colors.grey),
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
        style: const TextStyle(
          color: Colors.white,
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
        backgroundColor: Colors.grey[900]?.withValues(alpha: 0.3),
        title: const Text(
          'Select Theme Mode',
          style: TextStyle(color: Colors.white70),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ['system', 'light', 'dark'])
              ListTile(
                title: Text(
                  mode.capitalizeFirstLetter(),
                  style: const TextStyle(color: Colors.white),
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
        backgroundColor: Colors.grey[900]?.withValues(alpha: 0.3),
        title: const Text(
          'Select Repeat Mode',
          style: TextStyle(color: Colors.white70),
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
                  style: const TextStyle(color: Colors.white),
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
        backgroundColor: Colors.grey[900]?.withValues(alpha: 0.3),
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'This action cannot be undone. All playlists, timers, and settings will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear all data functionality
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
