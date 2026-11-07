import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/application_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/theme_settings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/job_list_screen.dart';
import 'services/auth_service.dart';
import 'services/job_api_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JobBoardApp());
}

class JobBoardApp extends StatelessWidget {
  const JobBoardApp({
    super.key,
    this.jobService,
    this.storageService,
    this.authService,
  });

  /// Optional overrides so tests can supply fake services.
  final JobApiService? jobService;
  final StorageService? storageService;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    final storage = storageService ?? const StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<JobProvider>(
          create: (_) =>
              JobProvider(jobService ?? JobApiService(), storage)..load(),
        ),
        ChangeNotifierProvider<ApplicationProvider>(
          create: (_) => ApplicationProvider(storage)..load(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService ?? AuthService())..load(),
        ),
        ChangeNotifierProvider<ThemeSettingsProvider>(
          create: (_) => ThemeSettingsProvider()..load(),
        ),
      ],
      child: Consumer<ThemeSettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'JobNest',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return auth.isAuthenticated
                  ? const JobListScreen()
                  : const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
