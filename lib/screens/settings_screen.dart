import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<(ThemeMode, String, String, IconData)> _themeOptions = [
    (
      ThemeMode.system,
      'System default',
      'Follow your device settings',
      Icons.settings_suggest_outlined,
    ),
    (
      ThemeMode.light,
      'Light mode',
      'Use a bright appearance',
      Icons.light_mode_outlined,
    ),
    (
      ThemeMode.dark,
      'Dark mode',
      'Use a darker appearance',
      Icons.dark_mode_outlined,
    ),
  ];

  Future<void> _selectTheme(
    BuildContext context,
    ThemeSettingsProvider settings,
    ThemeMode mode,
  ) async {
    try {
      await settings.setThemeMode(mode);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your appearance setting.'),
          ),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need your password to log in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final auth = context.read<AuthProvider>();
    Navigator.of(context).popUntil((route) => route.isFirst);
    auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ThemeSettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Account', style: theme.textTheme.titleMedium),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final profile = auth.profile;
              if (profile == null) return const SizedBox.shrink();
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
                    title: Text(profile.name),
                    subtitle: Text(profile.email),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => _signOut(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Log out'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'This profile is stored securely on this device only.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Appearance', style: theme.textTheme.titleMedium),
          ),
          for (final option in _themeOptions)
            ListTile(
              leading: Icon(option.$4),
              title: Text(option.$2),
              subtitle: Text(option.$3),
              trailing: settings.themeMode == option.$1
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              selected: settings.themeMode == option.$1,
              onTap: () => _selectTheme(context, settings, option.$1),
            ),
          if (settings.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                settings.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('About', style: theme.textTheme.titleMedium),
          ),
          const ListTile(
            leading: Icon(Icons.work_outline),
            title: Text('Job Board'),
            subtitle: Text('Browse remote jobs and manage your applications.'),
          ),
          const ListTile(
            leading: Icon(Icons.public),
            title: Text('Job listings'),
            subtitle: Text('Job data provided by Remotive.'),
          ),
        ],
      ),
    );
  }
}
