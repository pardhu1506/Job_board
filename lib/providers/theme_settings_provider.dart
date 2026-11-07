import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode_v1';

  ThemeMode _themeMode = ThemeMode.system;
  String? _errorMessage;

  ThemeMode get themeMode => _themeMode;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _themeMode = switch (preferences.getString(_themeModeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Could not load your saved appearance setting.';
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    final previousMode = _themeMode;
    _themeMode = mode;
    _errorMessage = null;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();
      final value = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      final saved = await preferences.setString(_themeModeKey, value);
      if (!saved) throw StateError('The appearance setting was not saved.');
    } catch (_) {
      _themeMode = previousMode;
      _errorMessage = 'Could not save your appearance setting.';
      notifyListeners();
      rethrow;
    }
  }
}
