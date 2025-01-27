
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _showNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark/light theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                // TODO: Implement theme switching
              });
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Show playback notifications'),
            value: _showNotifications,
            onChanged: (value) {
              setState(() {
                _showNotifications = value;
                // TODO: Implement notifications
              });
            },
          ),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('App information'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Music Player',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}